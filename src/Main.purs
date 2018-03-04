module Main where

import Prelude

import Control.Monad.Aff (Aff, Canceler, makeAff, launchAff_, liftEff')
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Eff.Uncurried (EffFn1, runEffFn1)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Random (RANDOM, random)
import Data.Either (Either(..))

foreign import data IPFS :: Effect
foreign import data IPFSObject :: Type

foreign import getIpfs
  :: String
  -> IPFSObject

foreign import ipfsOnceReadyImpl
  :: forall a eff
   . (forall x e. x -> Either e x)
  -> IPFSObject
  -> (Either Error a -> Eff eff Unit)
  -> Eff eff (Canceler eff)

foreign import doTheThing
  :: forall eff
   . EffFn1
       ( random :: RANDOM
       , console :: CONSOLE
       , ipfs :: IPFS
       | eff
       )
     IPFSObject
     Unit

ipfsOnceReady :: forall eff. IPFSObject -> Aff (ipfs :: IPFS | eff) Unit
ipfsOnceReady = makeAff <<< ipfsOnceReadyImpl Right

repo :: forall eff. Eff (random :: RANDOM | eff) String
repo = map (\x -> "ipfs/yjs-demo/" <> show x) random

main :: forall e. Eff (console :: CONSOLE, ipfs :: IPFS, random :: RANDOM | e) Unit
main = launchAff_ do
  repoName <- liftEff' repo
  let ipfs' = getIpfs repoName

  -- ipfsOnceReady ipfs'
  liftEff' (runEffFn1 doTheThing ipfs')

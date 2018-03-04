module Main where

import Prelude

import Control.Monad.Aff (Aff, launchAff_, liftEff')
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Uncurried (EffFn1, runEffFn1)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Random (RANDOM, random)

foreign import data IPFS :: Effect
foreign import data IPFSObject :: Type

foreign import getIpfs
  :: String
  -> IPFSObject

foreign import ipfsIdImpl
  :: forall eff
   . IPFSObject
  -> EffFnAff (ipfs :: IPFS | eff) String

foreign import ipfsOnceReadyImpl
  :: forall eff
   . IPFSObject
  -> EffFnAff (ipfs :: IPFS | eff) Unit

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
ipfsOnceReady = fromEffFnAff <<< ipfsOnceReadyImpl

ipfsId :: forall eff. IPFSObject -> Aff (ipfs :: IPFS | eff) String
ipfsId = fromEffFnAff <<< ipfsIdImpl

repo :: forall eff. Eff (random :: RANDOM | eff) String
repo = map (\x -> "ipfs/yjs-demo/" <> show x) random

main :: forall e. Eff (console :: CONSOLE, ipfs :: IPFS, random :: RANDOM | e) Unit
main = launchAff_ do
  repoName <- liftEff' repo
  let ipfs' = getIpfs repoName

  ipfsOnceReady ipfs'
  ipfsAddress <- ipfsId ipfs'

  liftEff' $ log ("IPFS node ready with address " <> ipfsAddress)
  liftEff' (runEffFn1 doTheThing ipfs')

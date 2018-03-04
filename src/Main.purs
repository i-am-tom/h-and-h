module Main where

import Prelude

import Control.Monad.Aff (Aff, launchAff_, liftEff')
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Uncurried (EffFn1, runEffFn1)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Random (RANDOM, random)
import Data.Foldable (for_)
import DOM (DOM)
import DOM.Classy.ParentNode (querySelector)
import DOM.HTML (window)
import DOM.Node.ParentNode (QuerySelector(..))
import DOM.HTML.Window (document)
import DOM.Node.Types (Element, ElementId(..), documentToNonElementParentNode)

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

foreign import bindToTextField
  :: forall eff
   . Y
  -> Element
  -> Eff
       ( random :: RANDOM
       , console :: CONSOLE
       , ipfs :: IPFS
       | eff
       )
     Unit

ipfsOnceReady :: forall eff. IPFSObject -> Aff (ipfs :: IPFS | eff) Unit
ipfsOnceReady = fromEffFnAff <<< ipfsOnceReadyImpl

ipfsId :: forall eff. IPFSObject -> Aff (ipfs :: IPFS | eff) String
ipfsId = fromEffFnAff <<< ipfsIdImpl

repo :: forall eff. Eff (random :: RANDOM | eff) String
repo = map (\x -> "ipfs/yjs-demo/" <> show x) random

---

foreign import data Y :: Type

foreign import data YConfig :: Type
foreign import makeYConfig :: IPFSObject -> String -> YConfig

foreign import setupYImpl
  :: forall eff
   . YConfig
  -> EffFnAff (ipfs :: IPFS | eff) Y

setupY :: forall eff. YConfig -> Aff (ipfs :: IPFS | eff) Y
setupY = fromEffFnAff <<< setupYImpl

main
  :: forall e
   . Eff
       ( console :: CONSOLE
       , dom :: DOM
       , ipfs :: IPFS
       , random :: RANDOM
       | e
       ) Unit
main = launchAff_ do
  repoName <- liftEff' repo
  let ipfs' = getIpfs repoName

  ipfsOnceReady ipfs'
  ipfsAddress <- ipfsId ipfs'
  let yConfig = makeYConfig ipfs' "hardy-and-harding"

  liftEff' $ log ("IPFS node ready with address " <> ipfsAddress)

  y <- setupY yConfig

  liftEff' do
    window' <- window
    document' <- document window'

    textField <- querySelector (QuerySelector "#textfield") document'
    for_ textField (bindToTextField y)

module Utils
  ( getCanvasImageSourceById
  , getImageDimensions
  , canvasToDataURL_
  , createCanvasElement
  , onWindowLoad
  , always
  , aspectRatio
  ) where

import Prelude

import DOM (DOM())
import DOM.HTML (window)
import DOM.HTML.Window (document)
import DOM.HTML.Types (htmlDocumentToDocument, windowToEventTarget)
import DOM.Node.Document (createElement)
import DOM.Node.Types (Element())
import DOM.Event.EventTarget (eventListener, addEventListener)
import DOM.Event.EventTypes (load)
import DOM.Event.Types (Event())

import Data.Maybe
import Data.Function (Fn3(), runFn3)

import Control.Monad.Eff (Eff())
import Control.Bind ((=<<))

import Graphics.Canvas (Canvas(), CanvasElement(), CanvasImageSource())

import Types

foreign import getCanvasImageSourceByIdImpl :: forall r eff. Fn3 String (CanvasImageSource -> r) r (Eff (canvas :: Canvas | eff) r)

getCanvasImageSourceById :: forall eff. String -> Eff (canvas :: Canvas | eff) (Maybe CanvasImageSource)
getCanvasImageSourceById elId = runFn3 getCanvasImageSourceByIdImpl elId Just Nothing

foreign import getImageDimensions :: forall eff. CanvasImageSource -> Eff (dom :: DOM | eff) Size2D

foreign import canvasToDataURL_ :: forall eff. String -> Number -> CanvasElement -> Eff (canvas :: Canvas | eff) String

createCanvasElement :: forall eff. Eff (dom :: DOM | eff) CanvasElement
createCanvasElement = do
  doc <- htmlDocumentToDocument <$> (document =<< window)
  elementToCanvasElement <$> createElement "canvas" doc

onWindowLoad :: forall m eff. Eff (dom :: DOM | eff) Unit -> Eff (dom :: DOM | eff) Unit
onWindowLoad eff = addEventListener load (eventListener $ always eff) false <<< windowToEventTarget =<< window

always :: forall a b. a -> b -> a
always a b = a

aspectRatio :: Size2D -> Number
aspectRatio {w:w,h:h} = w / h

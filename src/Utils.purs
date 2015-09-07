module Utils
  ( htmlElementToCanvasImageSource
  , querySelector
  , getCanvasImageSource
  , getImageSize
  , canvasToDataURL_
  , unsafeDataUrlToBlob
  , createCanvasElement
  , onWindowLoad
  , always
  , aspectRatio
  ) where

import Prelude

import DOM (DOM())
import DOM.HTML (window)
import DOM.HTML.Window (document)
import DOM.HTML.Types (HTMLElement(), htmlElementToEventTarget, htmlDocumentToDocument, windowToEventTarget)
import DOM.Node.Document (createElement)
import DOM.Node.Types (Element())
import DOM.Event.EventTarget (eventListener, addEventListener)
import DOM.Event.EventTypes (load, click)
import DOM.Event.Types (Event())
import DOM.File.Types (Blob())

import Data.Maybe
import Data.Function (Fn3(), runFn3)

import Control.Monad.Eff (Eff())
import Control.Bind ((=<<))

import Graphics.Canvas (Canvas(), CanvasElement(), CanvasImageSource())

import Types

foreign import htmlElementToCanvasImageSourceImpl :: forall r eff. Fn3 HTMLElement (CanvasImageSource -> r) r r

htmlElementToCanvasImageSource :: forall eff. HTMLElement -> Maybe CanvasImageSource
htmlElementToCanvasImageSource el = runFn3 htmlElementToCanvasImageSourceImpl el Just Nothing

foreign import querySelectorImpl :: forall r eff. Fn3 String (HTMLElement -> r) r (Eff (dom :: DOM | eff) r)

querySelector :: forall eff. String -> Eff (dom :: DOM | eff) (Maybe HTMLElement)
querySelector selector = runFn3 querySelectorImpl selector Just Nothing

getCanvasImageSource :: forall eff. String -> Eff (dom :: DOM | eff) (Maybe CanvasImageSource)
getCanvasImageSource selector = return <<< flip bind htmlElementToCanvasImageSource =<< querySelector selector

foreign import getImageSize :: forall eff a. CanvasImageSource -> Eff (dom :: DOM | eff) (Size2D a)

foreign import canvasToDataURL_ :: forall eff. String -> Number -> CanvasElement -> Eff (canvas :: Canvas | eff) String

foreign import unsafeDataUrlToBlob :: String -> Blob

createCanvasElement :: forall eff. Eff (dom :: DOM | eff) CanvasElement
createCanvasElement = do
  doc <- htmlDocumentToDocument <$> (document =<< window)
  elementToCanvasElement <$> createElement "canvas" doc

onWindowLoad :: forall m eff. Eff (dom :: DOM | eff) Unit -> Eff (dom :: DOM | eff) Unit
onWindowLoad eff = addEventListener load (eventListener $ always eff) false <<< windowToEventTarget =<< window

always :: forall a b. a -> b -> a
always a b = a

aspectRatio :: forall a. Size2D a -> Number
aspectRatio {w:w,h:h} = w / h

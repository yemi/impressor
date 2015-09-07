module Utils
  ( htmlElementToCanvasImageSource
  , getImageSize
  , canvasToDataURL_
  , unsafeDataUrlToBlob
  , createCanvasElement
  , aspectRatio
  ) where

import Prelude

import DOM (DOM())
import DOM.HTML (window)
import DOM.HTML.Window (document)
import DOM.HTML.Types (HTMLElement(), htmlDocumentToDocument)
import DOM.Node.Document (createElement)
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

foreign import getImageSize :: forall eff a. CanvasImageSource -> Eff (dom :: DOM | eff) (Size2D a)

foreign import canvasToDataURL_ :: forall eff. String -> Number -> CanvasElement -> Eff (canvas :: Canvas | eff) String

foreign import unsafeDataUrlToBlob :: String -> Blob

createCanvasElement :: forall eff. Eff (dom :: DOM | eff) CanvasElement
createCanvasElement = do
  doc <- htmlDocumentToDocument <$> (document =<< window)
  elementToCanvasElement <$> createElement "canvas" doc

aspectRatio :: forall a. Size2D a -> Number
aspectRatio {w:w,h:h} = w / h

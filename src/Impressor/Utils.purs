module Impressor.Utils
  ( getImageSize
  , canvasToDataURL_
  , unsafeDataUrlToBlob
  , createCanvasElement
  , createBlankImageData
  , aspectRatio
  , aspectRatio'
  ) where

import Prelude

import DOM (DOM())
import DOM.HTML (window)
import DOM.HTML.Window (document)
import DOM.HTML.Types (htmlDocumentToDocument)
import DOM.Node.Document (createElement)
import DOM.File.Types (Blob())

import Data.Maybe(maybe)
import Data.Maybe.Unsafe(fromJust)

import Control.Monad.Eff (Eff())
import Control.Bind ((=<<))

import Graphics.Canvas
  ( Canvas()
  , CanvasElement()
  , CanvasImageSource()
  , ImageData()
  , getContext2D
  , setCanvasWidth
  , setCanvasHeight
  , getImageData
  )

import Impressor.Types

foreign import getImageSize :: forall eff a. CanvasImageSource -> Eff (dom :: DOM | eff) (Size2D a)

foreign import canvasToDataURL_ :: forall eff. String -> Number -> CanvasElement -> Eff (canvas :: Canvas | eff) String

foreign import unsafeDataUrlToBlob :: String -> Blob

createCanvasElement :: forall eff. Eff (dom :: DOM | eff) CanvasElement
createCanvasElement = do
  doc <- htmlDocumentToDocument <$> (document =<< window)
  elementToCanvasElement <$> createElement "canvas" doc

createBlankImageData :: forall a eff. Size2D a -> Eff (dom :: DOM, canvas :: Canvas | eff) ImageData
createBlankImageData { w:w, h:h } = do
  canvas <- createCanvasElement
  ctx <- getContext2D canvas
  setCanvasWidth w canvas
  setCanvasHeight h canvas
  getImageData ctx 0.0 0.0 w h

aspectRatio :: forall a. Size2D a -> Number
aspectRatio { w:w, h:h } = w / h

aspectRatio' :: Number -> TargetSize -> Number
aspectRatio' sourceRatio (TargetSize { w:w, h:h }) = w / (maybe (w / sourceRatio) id h)

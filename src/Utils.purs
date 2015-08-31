module Utils where

import Prelude

import DOM
import DOM.HTML
import DOM.HTML.Window
import DOM.HTML.Types
import DOM.Node.Document
import DOM.Node.Types

import Control.Monad.Eff
import Control.Bind

import Graphics.Canvas

import Types

foreign import getImageById :: forall eff. String -> Eff (dom :: DOM | eff) CanvasImageSource

foreign import getImageDimensions :: forall eff. CanvasImageSource -> Eff (dom :: DOM | eff) ImageDimensions

foreign import elementToCanvasElement :: Element -> CanvasElement

createCanvasElement :: forall eff. Eff (dom :: DOM | eff) CanvasElement
createCanvasElement = do
  doc <- htmlDocumentToDocument <$> (document =<< window)
  elementToCanvasElement <$> createElement "canvas" doc

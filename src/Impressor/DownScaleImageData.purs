module Impressor.DownScaleImageData (downScaleImageData) where

import Prelude
import Data.Function (Fn3(), runFn3)
import Graphics.Canvas (CanvasElement(), Canvas(), ImageData())

downScaleImageData :: forall eff. Number -> ImageData -> ImageData -> ImageData
downScaleImageData scale srcImageData blankTargetImageData = runFn3 downScaleImageDataImpl scale srcImageData blankTargetImageData

foreign import downScaleImageDataImpl :: forall r eff. Fn3 Number ImageData ImageData ImageData

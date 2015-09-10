module Impressor.DownScaleImage (downScaleImage) where

import Prelude
import Data.Function (Fn3(), runFn3)
import Graphics.Canvas (CanvasElement(), Canvas(), ImageData())

downScaleImage :: forall eff. Number -> ImageData -> ImageData -> ImageData
downScaleImage scale srcImageData blankTargetImageData = runFn3 downScaleImageImpl scale srcImageData blankTargetImageData

foreign import downScaleImageImpl :: forall r eff. Fn3 Number ImageData ImageData ImageData

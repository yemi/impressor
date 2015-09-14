module Impressor.Workers (downScaleImageWorker) where

import Prelude
import Graphics.Canvas (ImageData())
import Control.Monad.Eff (Eff())
import Control.Monad.Aff (PureAff(), makeAff)

downScaleImageWorker :: Number -> ImageData -> ImageData -> PureAff ImageData
downScaleImageWorker scale srcImageData blankTargetImageData =
  makeAff (\error success -> downScaleImageWorkerImpl success scale srcImageData blankTargetImageData)

foreign import downScaleImageWorkerImpl :: forall e. (ImageData -> Eff e Unit) -> Number -> ImageData -> ImageData -> Eff e Unit

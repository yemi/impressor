module Impressor.DownScale (downScaleCanvas) where

import Prelude
import DOM
import Data.Function (Fn2(), runFn2)
import Control.Monad.Eff (Eff())
import Graphics.Canvas (CanvasElement(), Canvas())

foreign import downScaleCanvasImpl :: forall r eff. Fn2 Number CanvasElement (Eff (dom :: DOM, canvas :: Canvas | eff) CanvasElement)

downScaleCanvas :: forall eff. Number -> CanvasElement -> Eff (dom :: DOM, canvas :: Canvas | eff) CanvasElement
downScaleCanvas scale canvas = runFn2 downScaleCanvasImpl scale canvas

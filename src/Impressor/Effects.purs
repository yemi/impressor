module Impressor.Effects where

import DOM (DOM())
import Graphics.Canvas (Canvas())
import Control.Monad.Eff.Exception (EXCEPTION())

type ImpressorEffects eff = (dom :: DOM, canvas :: Canvas, err :: EXCEPTION | eff)

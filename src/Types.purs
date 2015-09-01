module Types
  ( Size2D()
  , CroppingProps()
  , CanvasPackage()
  ) where

import Prelude

import Graphics.Canvas (CanvasElement(), Context2D(), CanvasImageSource())

type Size2D = { w :: Number, h :: Number }

type CroppingProps = { left :: Number, top :: Number, w :: Number, h :: Number }

type CanvasPackage = { el :: CanvasElement , ctx :: Context2D , img :: CanvasImageSource }

module Types
  ( Size2D()
  , CroppingProps()
  , CanvasPackage()
  , elementToCanvasElement
  ) where

import Prelude

import DOM.Node.Types (Element())

import Graphics.Canvas (CanvasElement(), Context2D(), CanvasImageSource())

type Size2D = { w :: Number, h :: Number }

type CroppingProps = { left :: Number, top :: Number, w :: Number, h :: Number }

type CanvasPackage = { el :: CanvasElement , ctx :: Context2D , img :: CanvasImageSource }

foreign import elementToCanvasElement :: Element -> CanvasElement

newtype Opts = Opts { image :: CanvasImageSource, sizes :: Array String }  

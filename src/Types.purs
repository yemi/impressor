module Types
  ( Size2D()
  , CroppingProps()
  , CanvasPackage()
  , ImageProps(ImageProps)
  , ProcessedImage()
  , elementToCanvasElement
  ) where

import Prelude
import DOM.Node.Types (Element())
import DOM.File.Types (Blob())
import Graphics.Canvas (CanvasElement(), Context2D(), CanvasImageSource())
import Data.Foreign (Foreign())
import Data.Foreign.Class (IsForeign, read, readProp)

type Size2D a =
  { w :: Number
  , h :: Number
  | a }

type CroppingProps = Size2D
  ( left :: Number
  , top :: Number
  )

type CanvasPackage =
  { el :: CanvasElement
  , ctx :: Context2D
  , img :: CanvasImageSource
  }

type ProcessedImage =
  { name :: String
  , blob :: Blob
  }

newtype ImageProps = ImageProps (Size2D ( name :: String ))

instance isForeignImageProps :: IsForeign ImageProps where
  read obj =
    ImageProps <$> ({ w: _
                    , h: _
                    , name: _
                    } <$> readProp "width" obj
                      <*> readProp "height" obj
                      <*> readProp "name" obj)

foreign import elementToCanvasElement :: Element -> CanvasElement

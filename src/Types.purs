module Types
  ( Size2D()
  , CroppingProps()
  , CanvasPackage()
  , ImageProps(ImageProps)
  , Opts(Opts)
  , elementToCanvasElement
  ) where

import Prelude
import DOM.Node.Types (Element())
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

newtype Opts = Opts
  { image :: String
  , sizes :: Array ImageProps
  }

newtype ImageProps = ImageProps (Size2D ( name :: String ))

instance isForeignOpts :: IsForeign Opts where
  read obj =
    Opts <$> ({ image: _
              , sizes: _
              } <$> readProp "image" obj
                <*> readProp "sizes" obj)

instance isForeignImageProps :: IsForeign ImageProps where
  read obj =
    ImageProps <$> ({ w: _
                    , h: _
                    , name: _
                    } <$> readProp "width" obj
                      <*> readProp "height" obj
                      <*> readProp "name" obj)

foreign import elementToCanvasElement :: Element -> CanvasElement

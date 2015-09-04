module Types
  ( Size2D()
  , CroppingProps()
  , CanvasPackage()
  , ImageProps()
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

type CroppingProps =
  { left :: Number
  , top :: Number
  , w :: Number
  , h :: Number
  }

type CanvasPackage =
  { el :: CanvasElement
  , ctx :: Context2D
  , img :: CanvasImageSource
  }

type ImageProps =
  { w :: Number
  , h :: Number
  , suffix :: String
  }

newtype Opts = Opts
  { image :: CanvasImageSource
  , sizes :: Array ImageProps
  }

instance isForeignCanvasImageSource :: IsForeign CanvasImageSource where
  read img = img

instance isForeignOpts :: IsForeign Opts where
  read obj =
    Opts <$> ({ image: _
              , sizes: _
              } <$> readProp "image" obj
                <*> readProp "sizes" obj)

foreign import elementToCanvasElement :: Element -> CanvasElement

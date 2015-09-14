module Impressor.Types
  ( Size2D()
  , CroppingProps()
  , CanvasPackage()
  , TargetSize(..)
  , ProcessedImage()
  , ForeignCanvasImageSource(..)
  , ParsedArgs(..)
  , elementToCanvasElement
  ) where

import Prelude

import DOM.Node.Types (Element())
import DOM.File.Types (Blob())
import DOM.HTML.Types (HTMLElement())

import Graphics.Canvas (CanvasElement(), Context2D(), CanvasImageSource())

import Data.Foreign (Foreign(), F(), ForeignError(..))
import Data.Foreign.Class (IsForeign, read, readProp)
import Data.Foreign.NullOrUndefined (NullOrUndefined(..), runNullOrUndefined)
import Data.Maybe (Maybe(..))
import Data.Either(Either(..))
import Data.Function (Fn3(), runFn3)

type Size2D a =
  { w :: Number
  , h :: Number
  | a }

type CroppingProps = Size2D
  ( left :: Number
  , top :: Number
  )

type CanvasPackage =
  { canvas :: CanvasElement
  , ctx :: Context2D
  , img :: CanvasImageSource
  }

type ProcessedImage =
  { name :: String
  , blob :: Blob
  }

newtype TargetSize = TargetSize
  { w :: Number
  , h :: Maybe Number
  , name :: String
  }

newtype ParsedArgs = ParsedArgs
  { img :: ForeignCanvasImageSource
  , sizes :: Array TargetSize
  }

newtype ForeignCanvasImageSource = ForeignCanvasImageSource CanvasImageSource

instance isForeignTargetSize :: IsForeign TargetSize where
  read obj =
    TargetSize <$> ({ w: _
                    , h: _
                    , name: _
                    } <$> readProp "width" obj
                      <*> (runNullOrUndefined <$> readProp "height" obj :: F (NullOrUndefined Number))
                      <*> readProp "name" obj)

instance isForeignForeignCanvasImageSource :: IsForeign ForeignCanvasImageSource where
  read img = ForeignCanvasImageSource <$> readCanvasImageSource img

foreign import elementToCanvasElement :: Element -> CanvasElement

readCanvasImageSource :: Foreign -> F CanvasImageSource
readCanvasImageSource img = runFn3 readCanvasImageSourceImpl img (Left <<< TypeMismatch "canvas image source element") Right

foreign import readCanvasImageSourceImpl :: forall e. Fn3 Foreign (String -> e) (CanvasImageSource -> e) e

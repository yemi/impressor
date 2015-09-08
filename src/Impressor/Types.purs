module Impressor.Types
  ( Size2D()
  , CroppingProps()
  , CanvasPackage()
  , ImageSize(..)
  , ProcessedImage()
  , elementToCanvasElement
  , htmlElementToCanvasImageSource
  ) where

import Prelude

import DOM.Node.Types (Element())
import DOM.File.Types (Blob())
import DOM.HTML.Types (HTMLElement())

import Graphics.Canvas (CanvasElement(), Context2D(), CanvasImageSource())

import Data.Foreign (Foreign(), F())
import Data.Foreign.Class (IsForeign, read, readProp)
import Data.Foreign.NullOrUndefined (NullOrUndefined(..), runNullOrUndefined)
import Data.Maybe
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

newtype ImageSize = ImageSize
  { w :: Number
  , h :: Maybe Number
  , name :: String
  }

instance isForeignImageSize :: IsForeign ImageSize where
  read obj =
    ImageSize <$> ({ w: _
                   , h: _
                   , name: _
                   } <$> readProp "width" obj
                     <*> (runNullOrUndefined <$> readProp "height" obj :: F (NullOrUndefined Number))
                     <*> readProp "name" obj)

foreign import elementToCanvasElement :: Element -> CanvasElement

foreign import htmlElementToCanvasImageSourceImpl :: forall r eff. Fn3 HTMLElement (CanvasImageSource -> r) r r

htmlElementToCanvasImageSource :: forall eff. HTMLElement -> Maybe CanvasImageSource
htmlElementToCanvasImageSource el = runFn3 htmlElementToCanvasImageSourceImpl el Just Nothing

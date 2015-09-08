module Impressor where

import Prelude

import DOM (DOM())
import DOM.File.Types(Blob())

import Data.Traversable (traverse)
import Data.Maybe
import Data.Maybe.Unsafe(fromJust)
import Data.Foreign (Foreign(), ForeignError(), F(), unsafeFromForeign)
import Data.Foreign.Class (read)
import Data.Either (Either(..), either)
import Data.Monoid
import Data.Functor (($>))

import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Exception (EXCEPTION(), error, throwException)

import Graphics.Canvas
  ( Canvas()
  , CanvasElement()
  , Context2D()
  , CanvasImageSource()
  , getContext2D
  , setCanvasWidth
  , setCanvasHeight
  , drawImageFull
  , clearRect
  )

import Impressor.DownScale (downScaleCanvas)

import Impressor.Utils
import Impressor.Types

imageQuality :: Number
imageQuality = 0.80

croppingProps :: forall a b. Size2D a -> ImageSize -> CroppingProps
croppingProps src target = { left: left, top: top, w: width, h: height }
  where

  targetAspectRatio = aspectRatio' (aspectRatio src) target
  srcHasHigherAspectRatioThanTarget = aspectRatio src > targetAspectRatio
  left = if srcHasHigherAspectRatioThanTarget then ( src.w - ( src.h * targetAspectRatio )) / 2.0 else 0.0
  top = if srcHasHigherAspectRatioThanTarget then 0.0 else ( src.h - ( src.w / targetAspectRatio )) / 2.0
  width = if srcHasHigherAspectRatioThanTarget then src.h * targetAspectRatio else src.w
  height = if srcHasHigherAspectRatioThanTarget then src.h else src.w / targetAspectRatio

createImages :: forall a eff. CanvasPackage -> (Size2D a) -> Array ImageSize -> Eff (dom :: DOM, canvas :: Canvas | eff) (Array ProcessedImage)
createImages { canvas:canvas, ctx:ctx, img:img } srcSize targetSizes = traverse createImage targetSizes
  where

  createImage :: ImageSize -> Eff (dom :: DOM, canvas :: Canvas | eff) ProcessedImage
  createImage (ImageSize targetSize) = do
    setCanvasWidth maxWidth canvas
    setCanvasHeight maxHeight canvas
    drawImageFull ctx
                  img
                  croppingProps'.left -- Amount to crop from the left
                  croppingProps'.top -- Amount to crop from the top
                  croppingProps'.w -- Width of the cropped, unscaled image
                  croppingProps'.h -- Height of the cropped, unscaled image
                  0.0 -- Left padding
                  0.0 -- Top padding
                  maxWidth -- Scale it up to target width or don't scale at all
                  maxHeight -- Scale it up to target height or don't scale at all

    -- For better image quality, use the downScaleCanvas algorithm when scaling down images
    canvas' <- if srcScale > 1.0 then downScaleCanvas (1.0 / srcScale) canvas else pure canvas
    dataUrl <- canvasToDataURL_ "image/jpeg" imageQuality canvas'
    clearRect ctx { x:0.0, y:0.0, w:targetSize.w, h:targetHeight } -- Clear the canvas
    return { name: targetSize.name, blob: unsafeDataUrlToBlob dataUrl }

    where
    croppingProps' = croppingProps srcSize (ImageSize targetSize)
    targetHeight = maybe (targetSize.w / aspectRatio srcSize) id targetSize.h
    maxWidth = if croppingProps'.w <= targetSize.w then targetSize.w else croppingProps'.w
    maxHeight = if croppingProps'.h <= targetHeight then targetHeight else croppingProps'.h
    srcScale = croppingProps'.w / targetSize.w

impress :: forall eff. Foreign -> Foreign -> Eff (dom :: DOM, canvas :: Canvas, err :: EXCEPTION | eff) (Array ProcessedImage)
impress img sizes = either parsingErrorHandler (createImages' parsedImg) parsedSizes
  where

  parsedSizes :: F (Array ImageSize)
  parsedSizes = read sizes

  parsedImg :: CanvasImageSource
  parsedImg = unsafeFromForeign img

  parsingErrorHandler :: forall m eff. (Monoid m) => ForeignError -> Eff (err :: EXCEPTION | eff) m
  parsingErrorHandler err = (throwException <<< error <<< show $ err) $> mempty

  createImages' :: forall eff. CanvasImageSource -> Array ImageSize -> Eff (dom :: DOM, canvas :: Canvas | eff) (Array ProcessedImage)
  createImages' img targetSizes = do
    canvas <- createCanvasElement
    ctx <- getContext2D canvas
    srcSize <- getImageSize img
    createImages { canvas:canvas, ctx:ctx, img:img } srcSize targetSizes

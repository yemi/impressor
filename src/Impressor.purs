module Impressor where

import Prelude

import DOM (DOM())
import DOM.File.Types(Blob())

import Data.Foldable (for_)
import Data.Traversable (traverse)
import Data.Maybe
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

import Utils
import Types

imageQuality :: Number
imageQuality = 0.85

croppingProps :: forall a b. (Size2D a) -> (Size2D b) -> CroppingProps
croppingProps src target = { left: left, top: top, w: width, h: height }
  where

  srcHasHigherAspectRatioThanTarget = aspectRatio src > aspectRatio target
  left = if srcHasHigherAspectRatioThanTarget then ( src.w - ( src.h * aspectRatio target )) / 2.0 else 0.0
  top = if srcHasHigherAspectRatioThanTarget then 0.0 else ( src.h - ( src.w / aspectRatio target )) / 2.0
  width = if srcHasHigherAspectRatioThanTarget then src.h * aspectRatio target else src.w
  height = if srcHasHigherAspectRatioThanTarget then src.h else src.w / aspectRatio target

createImages :: forall a eff. CanvasPackage -> (Size2D a) -> Array ImageProps -> Eff (dom :: DOM, canvas :: Canvas | eff) (Array ProcessedImage)
createImages {el:el,ctx:ctx,img:img} srcSize targetSizes = traverse createImage targetSizes
  where

  createImage :: ImageProps -> Eff (dom :: DOM, canvas :: Canvas | eff) ProcessedImage
  createImage (ImageProps targetSize) = do
    setCanvasWidth maxWidth el
    setCanvasHeight maxHeight el
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

    -- For better image quality, use the downScaleCanvas algorithm for downscaling of images
    el' <- if srcScale > 1.0 then downScaleCanvas (1.0 / srcScale) el else pure el
    dataUrl <- canvasToDataURL_ "image/jpeg" imageQuality el'
    clearRect ctx { x:0.0, y:0.0, w:targetSize.w, h:targetSize.h } -- Clear the canvas
    return { name: targetSize.name, blob: unsafeDataUrlToBlob dataUrl }

    where
    croppingProps' = croppingProps srcSize targetSize
    maxWidth = if croppingProps'.w <= targetSize.w then targetSize.w else croppingProps'.w
    maxHeight = if croppingProps'.h <= targetSize.h then targetSize.h else croppingProps'.h
    srcScale = croppingProps'.w / targetSize.w

impress :: forall eff. Foreign -> Foreign -> Eff (dom :: DOM, canvas :: Canvas, err :: EXCEPTION | eff) (Array ProcessedImage)
impress img sizes = either parsingErrorHandler (createImages' parsedImg) parsedSizes
  where

  parsedSizes :: F (Array ImageProps)
  parsedSizes = read sizes

  parsedImg :: CanvasImageSource
  parsedImg = unsafeFromForeign img

  parsingErrorHandler :: forall m eff. (Monoid m) => ForeignError -> Eff (err :: EXCEPTION | eff) m
  parsingErrorHandler err = (throwException <<< error <<< show $ err) $> mempty

  createImages' :: forall eff. CanvasImageSource -> Array ImageProps -> Eff (dom :: DOM, canvas :: Canvas | eff) (Array ProcessedImage)
  createImages' img targetSizes = do
    el <- createCanvasElement
    ctx <- getContext2D el
    srcSize <- getImageSize img
    createImages { el:el, ctx:ctx, img:img } srcSize targetSizes

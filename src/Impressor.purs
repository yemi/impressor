module Impressor where

import Prelude
import DOM (DOM())
import Math (max)

import Data.Traversable (traverse)
import Data.Maybe (maybe)
import Data.Maybe.Unsafe(fromJust)
import Data.Foreign (Foreign(), ForeignError(), F(), unsafeFromForeign)
import Data.Foreign.Class (read)
import Data.Either (Either(..), either)
import Data.Monoid
import Data.Functor (($>))

import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION(), error, throwException)
import Control.Monad.Aff (launchAff)
import Control.Monad.Aff.Console (log)

import Graphics.Canvas
  ( Canvas()
  , CanvasElement()
  , Context2D()
  , CanvasImageSource()
  , getContext2D
  , getImageData
  , putImageData
  , setCanvasWidth
  , setCanvasHeight
  , drawImageFull
  , clearRect
  )

import Impressor.DownScaleImage (downScaleImage)
import Impressor.Utils
import Impressor.Types

imageQuality :: Number
imageQuality = 0.80

croppingProps :: forall a. Size2D a -> TargetSize -> CroppingProps
croppingProps src target = { left: left, top: top, w: width, h: height }
  where

  targetAspectRatio = aspectRatio' (aspectRatio src) target
  srcHasHigherAspectRatioThanTarget = aspectRatio src > targetAspectRatio
  left = if srcHasHigherAspectRatioThanTarget then ( src.w - ( src.h * targetAspectRatio )) / 2.0 else 0.0
  top = if srcHasHigherAspectRatioThanTarget then 0.0 else ( src.h - ( src.w / targetAspectRatio )) / 2.0
  width = if srcHasHigherAspectRatioThanTarget then src.h * targetAspectRatio else src.w
  height = if srcHasHigherAspectRatioThanTarget then src.h else src.w / targetAspectRatio

createImages :: forall a eff. CanvasPackage -> Size2D a -> Array TargetSize -> Eff (dom :: DOM, canvas :: Canvas | eff) (Array ProcessedImage)
createImages { canvas:canvas, ctx:ctx, img:img } srcSize targetSizes = traverse createImage targetSizes
  where

  createImage :: TargetSize -> Eff (dom :: DOM, canvas :: Canvas | eff) ProcessedImage
  createImage (TargetSize targetSize) = do

    -- | Set canvas size to be the same as max targetSize srcSize so we can get image data for
    -- | the entire, cropped but non down scaled, image
    setCanvasWidth maxWidth canvas
    setCanvasHeight maxHeight canvas

    -- | Draw the cropped, non down scaled image to the context
    drawImageFull ctx
                  img -- Source image
                  croppingProps'.left -- Amount to crop from the left
                  croppingProps'.top -- Amount to crop from the top
                  croppingProps'.w -- Width of the cropped, unscaled image
                  croppingProps'.h -- Height of the cropped, unscaled image
                  0.0 -- Left padding
                  0.0 -- Top padding
                  maxWidth -- Scale it up to target width or don't scale at all
                  maxHeight -- Scale it up to target height or don't scale at all

    -- | Get image data for the cropped, non down scaled image
    srcImageData <- getImageData ctx 0.0 0.0 maxWidth maxHeight

    -- | Since we have our srcImageData, prepare final image output by matching the canvas size with the target size
    -- | TODO: dont call these functions if there is no need to down scale the image
    setCanvasWidth targetWidth canvas
    setCanvasHeight targetHeight canvas

    -- | Create a blank image data object for the down scaling algorithm
    -- | TODO: dont call this function if there is no need to down scale the image
    blankTargetImageData <- createBlankImageData { w:targetWidth, h:targetHeight }

    -- | For better image quality, use the downScaleImage algorithm when scaling down images
    let resImageData = if srcScale > 1.0 then downScaleImage (1.0 / srcScale) srcImageData blankTargetImageData else srcImageData

    -- | Draw the resulting image to the context
    putImageData ctx resImageData 0.0 0.0

    -- | Get data URL from the resulting canvas and return our processed image
    dataUrl <- canvasToDataURL_ "image/jpeg" imageQuality canvas
    return { name: targetSize.name, blob: unsafeDataUrlToBlob dataUrl }

    where
    croppingProps' = croppingProps srcSize (TargetSize targetSize)
    targetHeight = maybe (targetSize.w / aspectRatio srcSize) id targetSize.h
    targetWidth = targetSize.w
    srcScale = croppingProps'.w / targetWidth
    maxWidth = max targetWidth croppingProps'.w
    maxHeight = max targetHeight croppingProps'.h

impress :: forall eff. Foreign -> Foreign -> Eff (dom :: DOM, canvas :: Canvas, err :: EXCEPTION | eff) (Array ProcessedImage)
impress img sizes = either parsingErrorHandler (createImages' parsedImg) parsedSizes
  where

  parsedSizes :: F (Array TargetSize)
  parsedSizes = read sizes

  parsedImg :: CanvasImageSource
  parsedImg = unsafeFromForeign img

  parsingErrorHandler :: forall m eff. (Monoid m) => ForeignError -> Eff (err :: EXCEPTION | eff) m
  parsingErrorHandler err = (throwException <<< error <<< show $ err) $> mempty

  createImages' :: forall eff. CanvasImageSource -> Array TargetSize -> Eff (dom :: DOM, canvas :: Canvas | eff) (Array ProcessedImage)
  createImages' img targetSizes = do
    canvas <- createCanvasElement
    ctx <- getContext2D canvas
    srcSize <- getImageSize img
    createImages { canvas:canvas, ctx:ctx, img:img } srcSize targetSizes

main = launchAff $ do
  srcImageData <- liftEff $ createBlankImageData { w:600.0, h:400.0 }
  blankTargetImageData <- liftEff $ createBlankImageData { w:300.0, h:200.0 }
  resImageData <- downScaleImageWorker 0.5 srcImageData blankTargetImageData
  log "färdi!"

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
import Data.Function (Fn1(), runFn1)

import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION(), error, throwException)
import Control.Monad.Aff (Aff(), launchAff, runAff)

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

import Impressor.Workers (downScaleImageWorker)
import Impressor.Utils
import Impressor.Types
import Impressor.Effects

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

createImages :: forall a eff. CanvasPackage -> Size2D a -> Array TargetSize -> Aff (dom :: DOM, canvas :: Canvas | eff) (Array ProcessedImage)
createImages { canvas:canvas, ctx:ctx, img:img } srcSize targetSizes = traverse createImage targetSizes
  where

  createImage :: TargetSize -> Aff (dom :: DOM, canvas :: Canvas | eff) ProcessedImage
  createImage (TargetSize targetSize) = do

    -- | Set canvas size to be the same as max targetSize srcSize so we can get image data for
    -- | the entire, cropped but non down scaled, image
    liftEff $ setCanvasWidth maxWidth canvas >>= setCanvasHeight maxHeight

    -- | Draw the cropped, non down scaled image to the context
    liftEff $ drawImageFull ctx
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
    srcImageData <- liftEff $ getImageData ctx 0.0 0.0 maxWidth maxHeight

    -- | Get the resulting image data
    resImageData <- if srcScale > 1.0
      then do
        -- | Prepare final image output by matching the canvas size with the target size.
        liftEff $ setCanvasWidth targetWidth canvas >>= setCanvasHeight targetHeight

        -- | Create a blank image data object for the down scaling algorithm
        blankTargetImageData <- liftEff $ createBlankImageData { w:targetWidth, h:targetHeight }

        -- | For better image quality, use the downScaleImage algorithm when down scaling images
        downScaleImageWorker (1.0 / srcScale) srcImageData blankTargetImageData
      else
        -- | If there is no need for down scaling, use the source image data we already have
        pure srcImageData

    -- | Draw the resulting image to the context
    liftEff $ putImageData ctx resImageData 0.0 0.0

    -- | Get data URL from the resulting canvas and return our processed image
    dataUrl <- liftEff $ canvasToDataURL_ "image/jpeg" imageQuality canvas
    return { name: targetSize.name, blob: unsafeDataUrlToBlob dataUrl }

    where
    croppingProps' = croppingProps srcSize (TargetSize targetSize)
    targetHeight = maybe (targetSize.w / aspectRatio srcSize) id targetSize.h
    targetWidth = targetSize.w
    maxWidth = max targetWidth croppingProps'.w
    maxHeight = max targetHeight croppingProps'.h
    srcScale = croppingProps'.w / targetWidth

impress :: forall eff. Foreign ->
                       Foreign ->
                       Fn1 (Array ProcessedImage) (Eff (ImpressorEffects eff) Unit) ->
                       Eff (ImpressorEffects eff) Unit
impress img sizes cb = either parsingErrorHandler createImages' parsedArgs
  where

  parsedArgs :: F ParsedArgs
  parsedArgs =
    ParsedArgs <$> ({ img: _
                    , sizes: _
                    } <$> read img :: F ForeignCanvasImageSource
                      <*> read sizes :: F (Array TargetSize))

  parsingErrorHandler :: forall eff. ForeignError -> Eff (err :: EXCEPTION | eff) Unit
  parsingErrorHandler err = (throwException <<< error <<< show $ err) $> unit

  createImages' :: ParsedArgs -> Eff (ImpressorEffects eff) Unit
  createImages' (ParsedArgs { img:(ForeignCanvasImageSource img), sizes:targetSizes }) = do
    canvas <- createCanvasElement
    ctx <- getContext2D canvas
    srcSize <- getImageSize img
    runAff (throwException)
           (runFn1 cb)
           (createImages { canvas:canvas, ctx:ctx, img:img } srcSize targetSizes)

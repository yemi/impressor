module Impressor where

import Prelude

import DOM (DOM())

import Data.Foldable (for_)
import Data.Traversable (traverse)
import Data.Maybe
import Data.Foreign (Foreign(), ForeignError(), F())
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
  , getContext2D
  , setCanvasWidth
  , setCanvasHeight
  , drawImageFull
  , clearRect
  )

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

createImages :: forall a eff. CanvasPackage -> (Size2D a) -> Array ImageProps -> Eff (canvas :: Canvas | eff) (Array String)
createImages {el:el,ctx:ctx,img:img} srcSize targetSizes = traverse createImage targetSizes
  where

  createImage :: ImageProps -> Eff (canvas :: Canvas | eff) String
  createImage (ImageProps targetSize) = do
    setCanvasWidth targetSize.w el
    setCanvasHeight targetSize.h el
    processImage targetSize -- Draw the processed image to the canvas
    dataUrl <- canvasToDataURL_ "image/jpeg" imageQuality el
    clearRect ctx { x:0.0, y:0.0, w:targetSize.w, h:targetSize.h } -- Clear the canvas
    return dataUrl

  processImage :: forall b. (Size2D b) -> Eff (canvas :: Canvas | eff ) Context2D
  processImage targetSize = do
    let croppingProps' = croppingProps srcSize targetSize
    drawImageFull ctx
                  img
                  croppingProps'.left -- Amount to crop from the left
                  croppingProps'.top -- Amount to crop from the top
                  croppingProps'.w -- Width of the cropped, unscaled image
                  croppingProps'.h -- Height of the cropped, unscaled image
                  0.0 -- Left padding
                  0.0 -- Top padding
                  targetSize.w -- Scale it up/down to target width
                  targetSize.h -- Scale it up/down to target height

impress :: forall eff. Foreign -> Eff (dom :: DOM, canvas :: Canvas, err :: EXCEPTION | eff) (Array String)
impress opts = either parsingErrorHandler createImages' parsedOpts
  where

  parsedOpts :: F Opts
  parsedOpts = read opts

  parsingErrorHandler :: forall m eff. (Monoid m) => ForeignError -> Eff (err :: EXCEPTION | eff) m
  parsingErrorHandler err = (throwException <<< error <<< show $ err) $> mempty

  createImages' :: forall eff. Opts -> Eff (dom :: DOM, canvas :: Canvas | eff) (Array String)
  createImages' (Opts {sizes:targetSizes}) = do
    el <- createCanvasElement
    ctx <- getContext2D el
    Just img <- getCanvasImageSource "#image"
    srcSize <- getImageSize img
    createImages { el:el, ctx:ctx, img:img } srcSize targetSizes

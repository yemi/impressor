module Impressor where

import Prelude

import DOM (DOM())

import Data.Foldable (for_)
import Data.List (List(), toList)
import Data.Traversable (traverse)
import Data.Maybe

import Control.Monad.Eff (Eff(), foreachE)
import Control.Monad.Eff.Console (log, CONSOLE())

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

{-
Image width: 610px
Image height: 405px
Image ratio: 1.51:1

Target width: 1000px
Target height: 600px
Target ratio: 1.67:1
-}

imageQuality :: Number
imageQuality = 0.85

targetSizes :: List Size2D
targetSizes = toList [{ w: 1000.0, h: 600.0 }, { w: 800.0, h: 200.0 }, { w: 610.0, h: 405.0 }]

croppingProps :: Size2D -> Size2D -> CroppingProps
croppingProps src target = { left: left, top: top, w: width, h: height }
  where

  srcHasHigherAspectRatioThanTarget = aspectRatio src > aspectRatio target
  left = if srcHasHigherAspectRatioThanTarget then ( src.w - ( src.h * aspectRatio target )) / 2.0 else 0.0
  top = if srcHasHigherAspectRatioThanTarget then 0.0 else ( src.h - ( src.w / aspectRatio target )) / 2.0
  width = if srcHasHigherAspectRatioThanTarget then src.h * aspectRatio target else src.w
  height = if srcHasHigherAspectRatioThanTarget then src.h else src.w / aspectRatio target

createImages :: forall eff. CanvasPackage -> Size2D -> List Size2D -> Eff (canvas :: Canvas | eff) (List String)
createImages {el:el,ctx:ctx,img:img} srcSize targetSizes = traverse createImage targetSizes
  where

  createImage :: forall eff. Size2D -> Eff (canvas :: Canvas | eff) String
  createImage targetSize = do
    setCanvasWidth targetSize.w el
    setCanvasHeight targetSize.h el
    processImage targetSize -- Draw the processed image to the canvas
    dataUrl <- canvasToDataURL_ "image/jpeg" imageQuality el
    clearRect ctx { x:0.0, y:0.0, w:targetSize.w, h:targetSize.h } -- Clear the canvas
    return dataUrl

  processImage :: forall eff. Size2D -> Eff (canvas :: Canvas | eff ) Context2D
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
                  targetSize.w -- Scale it up to target width
                  targetSize.h -- Scale it up to target height

main :: forall eff. Eff (dom :: DOM, canvas :: Canvas, console :: CONSOLE | eff) Unit
main = onWindowLoad do
  el <- createCanvasElement
  ctx <- getContext2D el
  Just img <- getCanvasImageSourceById "image"
  srcSize <- getImageSize img
  imgs <- createImages { el:el, ctx:ctx, img:img } srcSize targetSizes

  for_ imgs \img' -> do
    log { img'

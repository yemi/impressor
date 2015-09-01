module Impressor where

import Prelude

import DOM (DOM())

import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Console (log, CONSOLE())

import Graphics.Canvas
  ( Canvas()
  , CanvasElement()
  , Context2D()
  , getContext2D
  , setCanvasWidth
  , setCanvasHeight
  , drawImageFull
  , canvasToDataURL
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

targetSizes :: Size2D
targetSizes = { w: 1000.0, h: 600.0 }

aspectRatio :: Size2D -> Number
aspectRatio src = src.w / src.h

croppingProps :: Size2D -> Size2D -> CroppingProps
croppingProps src target = { left: left, top: top, w: width, h: height }
  where
  isWiderThanTarget = aspectRatio src > aspectRatio target
  left = if isWiderThanTarget then ( src.w - ( src.h * aspectRatio target )) / 2.0 else 0.0
  top = if isWiderThanTarget then 0.0 else ( src.h - ( src.w / aspectRatio target )) / 2.0
  width = if isWiderThanTarget then src.h * aspectRatio target else src.w
  height = if isWiderThanTarget then 0.0 else src.w / aspectRatio target

processImage :: forall eff. CanvasPackage -> Size2D -> Size2D -> Eff (canvas :: Canvas, dom :: DOM | eff ) Context2D
processImage canvas srcSize targetSize = do
  setCanvasWidth targetSize.w canvas.el
  setCanvasHeight targetSize.h canvas.el

  let croppingProps' = croppingProps srcSize targetSize
  drawImageFull canvas.ctx
                canvas.img
                croppingProps'.left
                croppingProps'.top
                croppingProps'.w
                croppingProps'.h
                0.0
                0.0
                targetSize.w
                targetSize.h

main :: forall eff. Eff (dom :: DOM, canvas :: Canvas, console :: CONSOLE | eff) Unit
main = onWindowLoad do
  el <- createCanvasElement
  ctx <- getContext2D el
  img <- getImageById "image"
  srcSize <- getImageDimensions img

  processImage {el:el,ctx:ctx,img:img} srcSize targetSizes

  dataUrl <- canvasToDataURL el
  log dataUrl

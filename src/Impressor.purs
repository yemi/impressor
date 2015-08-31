module Impressor where

import Prelude

import DOM

import Control.Bind
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Console (log, CONSOLE())

import Graphics.Canvas

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

sizes :: ImageDimensions
sizes = { w: 1000.0, h: 600.0 }

aspectRatio :: ImageDimensions -> Number
aspectRatio src = src.w / src.h

croppingProps :: ImageDimensions -> ImageDimensions -> CroppingProps
croppingProps src target = { top: top, left: left, w: width, h: height }
    where
    isWiderThanTarget = aspectRatio src > aspectRatio target
    width = if isWiderThanTarget then target.h / aspectRatio src else target.w
    height = if isWiderThanTarget then target.h else target.w / aspectRatio src
    top = if isWiderThanTarget then 0.0 else (target.h / 2.0) - (src.h / 2.0)
    left = if isWiderThanTarget then (target.w / 2.0) - (src.w / 2.0) else 0.0

processImage :: forall eff. ImageDimensions -> Eff (canvas :: Canvas, dom :: DOM | eff ) String
processImage size = do
  canvas <- createCanvasElement
  ctx <- getContext2D canvas
  image <- getImageById "image"
  imageDimensions <- getImageDimensions image

  setCanvasWidth size.w canvas
  setCanvasHeight size.h canvas

  let props = croppingProps imageDimensions size
  drawImageFull ctx image 0.0 0.0 props.w props.h props.left props.top size.w size.h
  canvasToDataURL canvas

main :: forall eff. Eff (dom :: DOM, canvas :: Canvas, console :: CONSOLE | eff) Unit
main = do
  dataUrl <- processImage sizes
  log dataUrl

module Types
  ( ImageDimensions()
  , CroppingProps()
  ) where

import Prelude

type ImageDimensions = { w :: Number, h :: Number }

type CroppingProps = { top :: Number, left :: Number, w :: Number, h :: Number }

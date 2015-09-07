module View.Widget where

import Prelude hiding (top, bottom)
import Math (min, max)
import DOM

import Control.Monad.Aff (Aff(), launchAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Free (liftFI)

import Data.Either (Either(..))
import Data.Functor (($>))
import Data.Maybe
import Data.Maybe.Unsafe(fromJust)

import Graphics.Canvas

import Halogen
import Halogen.Query.StateF (modify)
import Halogen.Util (appendToBody)
import Halogen.HTML.Core (Prop())
import qualified Halogen.HTML as H
import qualified Halogen.HTML.Events as E
import qualified Halogen.HTML.Properties as P
import qualified Halogen.HTML.CSS as P

import Css.Stylesheet (Css())
import Css.Size
import Css.Geometry

import Utils (getImageById)

previewWidth = 200.0

-- | The state of the application
type State = { zoom :: Number }

initialState :: State
initialState = { zoom: 1.0 }

-- | Inputs to the state machine.
data Input a
  = ZoomIn a
  | ZoomOut a
  | Save Number a

-- | The effects used in the app.
type AppEffects = HalogenEffects (canvas :: Canvas)

-- | The definition for the app's main UI component.
ui :: forall eff p. Component State Input (Aff AppEffects) p
ui = component render eval
  where

  render :: Render State Input p
  render st =
    H.div_
      [ H.h1_ [ H.text "Image cropp" ]
      , H.canvas [ P.id_ "canvas" ]
      , H.div_
        [ H.img [ P.src "resources/prad-bitt.jpg", P.id_ "image", P.style $ getImageSize st.zoom ] ]
      , H.div_
        [ H.button [ E.onClick (E.input_ ZoomIn) ]
          [ H.text "+" ]
        , H.button [ E.onClick (E.input_ ZoomOut) ]
          [ H.text "-" ]
        , H.button [ E.onClick (E.input_ (Save st.zoom)) ]
          [ H.text "Save that shi" ]
        ]
      , H.h2_ [ H.text $ show st.zoom ]
      ]

  eval :: Eval Input State Input (Aff AppEffects)
  eval (ZoomIn next) = modify (\st -> st { zoom = min 3.0 (st.zoom + 0.2) }) $> next
  eval (ZoomOut next) = modify (\st -> st { zoom = max 1.0 (st.zoom - 0.2) }) $> next
  eval (Save zoom next) = pure next

getImageSize :: forall i. Number -> Css
getImageSize zoom = width $ px $ previewWidth * zoom

-- | Run the app.
main :: Eff AppEffects Unit
main = launchAff $ do
  app <- runUI ui initialState
  appendToBody app.node

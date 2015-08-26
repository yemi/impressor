module Impressor where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Aff (Aff(), launchAff)
import Control.Monad.Aff.Console (log)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Free (liftFI)
import qualified Control.Monad.Eff.Console as C

import Data.Either (Either(..))
import Data.Foldable (foldMap)
import Data.Foreign.Class (readProp)
import Data.Functor (($>))
import Data.Maybe (Maybe(..))

import DOM.HTML.Types (HTMLElement())

import Halogen
import Halogen.Query.StateF (modify)
import Halogen.Util (appendToBody)
import Halogen.HTML.Events.Types (Event(), MouseEvent())
import qualified Halogen.HTML as H
import qualified Halogen.HTML.Events as E
import qualified Halogen.HTML.Events.Forms as E
import qualified Halogen.HTML.Properties as P

-- | The state of the application
type State = { isDragging :: Boolean }

initialState :: State
initialState = { isDragging: false }

-- | Inputs to the state machine.
data Input a
  = StartDragging (Event MouseEvent) a

-- | The effects used in the app.
type AppEffects = HalogenEffects ()

-- | The definition for the app's main UI component.
ui :: forall eff p. Component State Input (Aff AppEffects) p
ui = component render eval
  where

  render :: Render State Input p
  render st =
    H.div_ $ [ H.h1_ [ H.text "Image cropp" ]
             , H.button [ E.onMouseDown (E.input StartDragging)]
                     [ H.text (if st.isDragging then "Dragz" else "Nodragz") ]
             ]

  eval :: Eval Input State Input (Aff AppEffects)
  eval (StartDragging ev next) = do
    modify (_ { isDragging = true })
    liftFI $ log <<< show $ ev.button
    pure next

-- | Run the app.
main :: Eff AppEffects Unit
main = launchAff $ do
  app <- runUI ui initialState
  appendToBody app.node

module Renderer where

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import Prelude
import React.Basic.DOM as R
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Hooks (Component, component)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

main ∷ Effect Unit
main = do
  doc ← document =<< window
  root ← getElementById "root" $ toNonElementParentNode doc
  case root of
    Nothing → throw "Could not find root."
    Just container → do
      reactRoot ← createRoot container
      app ← mkApp
      renderRoot reactRoot (app {})

mkApp ∷ Component {}
mkApp = do
  component "Example" \_ → React.do
    pure $ R.div_ [ R.text "Hello!" ]

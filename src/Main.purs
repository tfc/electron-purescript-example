module Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Electron (BrowserWindowConfig, appendSwitch, loadFile, newBrowserWindow, openHttpsInBrowserAndBlockOtherURLs, setWindowOpenHandlerToExternal, showWhenReadyToShow, waitUntilAppReady)
import Node.Path (FilePath)
import Node.Path as Path

main ∷ Effect Unit
main = launchAff_ do
  waitUntilAppReady
  openHttpsInBrowserAndBlockOtherURLs # liftEffect
  appendSwitch "enable-features" "CSSContainerQueries" # liftEffect
  options ← mkOptions # liftEffect
  window ← newBrowserWindow options # liftEffect
  window # showWhenReadyToShow # liftEffect
  window # loadFile "index.html"
  window # setWindowOpenHandlerToExternal # liftEffect

foreign import dirnameImpl ∷ Effect FilePath

mkOptions ∷ Effect BrowserWindowConfig
mkOptions = ado
  dirName ← dirnameImpl
  in
    { width: 800
    , height: 600
    , backgroundColor: "white"
    , show: false
    , webPreferences:
        { preload: Path.concat [ dirName, "preload.js" ]
        , nodeIntegration: true
        , enableRemoteModule: true
        , contextIsolation: true
        , sandbox: true
        , nodeIntegrationInWorker: true
        , worldSafeExecuteJavaScript: true
        }
    }

{-# LANGUAGE OverloadedStrings #-}
module Main where

import GlitterSky
import qualified GlitterSky.Tracker as T

import Network.HTTP.Client.TLS (newTlsManager)
import Network.Wai.Middleware.Static
import Web.Scotty

main :: IO ()
main = do
  mngr <- newTlsManager
  trackers <- T.newTrackers

  scotty 8888 $ do
    get "/" $ text "hello scotty"

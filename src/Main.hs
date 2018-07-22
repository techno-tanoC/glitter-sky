{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import qualified GlitterSky.Container as C
import qualified GlitterSky.Download as D
import qualified GlitterSky.Progress as P
import qualified GlitterSky.Tracker as T

import Control.Concurrent.MVar
import Control.Monad.IO.Class
import Data.Aeson (FromJSON, ToJSON)
import GHC.Generics
import Network.HTTP.Client
import Network.HTTP.Client.TLS (newTlsManager)
import Network.Wai.Middleware.Cors
import Web.Scotty

data Cancel = Cancel {
  id :: String
} deriving Generic

instance FromJSON Cancel

data Push = Push {
  name :: String,
  url :: String,
  ext :: String
} deriving (Show, Generic)

instance FromJSON Push

main :: IO ()
main = do
  mngr <- newTlsManager
  trackers <- T.newTrackers :: IO (T.Trackers P.Progress)
  let dest = "sky"

  scotty 8888 $ do
    middleware simpleCors

    get "/" $ do
      ps <- liftIO $ C.extract trackers
      json ps

    post "/push" $ do
      Push n u e <- jsonData
      liftIO $ D.startDownload mngr trackers dest (parseRequest_ u) (n, e)
      return ()

    -- options "/cancel" $ return ()
    post "/cancel" $ do
      Cancel i <- jsonData
      liftIO $ T.cancel i trackers
      return ()

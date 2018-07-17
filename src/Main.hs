{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified GlitterSky.Renamer as Renamer
import qualified GlitterSky.HTTP as HTTP
import qualified GlitterSky.Tracker as T
import qualified GlitterSky.Progress as P

import Control.Concurrent.MVar
import qualified Control.Concurrent as C
import qualified Data.ByteString as BS
import Network.HTTP.Client
import Network.HTTP.Client.TLS (newTlsManager)

main :: IO ()
main = do
  mngr <- newTlsManager
  trackers <- T.newTrackers

  let req = ""
  id <- T.startTracker P.newProgress trackers $ \pg -> do
    withResponse req mngr $ \res -> do
      case HTTP.findCL res of
        Just cl -> P.setCL pg cl
        Nothing -> return ()
      HTTP.readAll (responseBody res) $ \bs -> do
        P.progress pg $ BS.length bs
        readMVar pg >>= print
      putStrLn "end"

  readLn :: IO String
  return ()

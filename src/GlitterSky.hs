{-# LANGUAGE OverloadedStrings #-}
module GlitterSky where

import qualified GlitterSky.File as File
import qualified GlitterSky.HTTP as HTTP
import qualified GlitterSky.Progress as P
import qualified GlitterSky.Renamer as Renamer
import qualified GlitterSky.Tracker as T

import Control.Monad
import Control.Concurrent
import Control.Concurrent.MVar
import qualified Data.ByteString as BS
import qualified System.IO as IO
import Network.HTTP.Client

processChunk :: MVar P.Progress -> IO.Handle -> BS.ByteString -> IO ()
processChunk pg h bs = do
  P.progress pg $ BS.length bs
  BS.hPut h bs
  -- print pg

download :: Manager
         -> String
         -> MVar P.Progress
         -> Request
         -> (Renamer.Name, Renamer.Ext)
         -> IO ()
download mngr dest pg req (name, ext) = do
  withResponse req mngr $ \res -> do
    case HTTP.findCL res of
      Just cl -> P.setCL pg cl
      Nothing -> return ()

    File.actBinaryTempFile
      (\path handle -> HTTP.readAll (responseBody res) $ processChunk pg handle)
      (\path -> Renamer.copy path (dest, name, ext))
  return ()

startDownload :: Manager
              -> T.Trackers P.Progress
              -> String
              -> Request
              -> (Renamer.Name, Renamer.Ext)
              -> IO ()
startDownload mngr trackers dest req (name, ext) = do
  T.startTracker trackers (P.newProgress name) $ \pg -> do
    download mngr dest pg req (name, ext)

  return ()

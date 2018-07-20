{-# LANGUAGE OverloadedStrings #-}
module Main where

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
import Network.HTTP.Client.TLS (newTlsManager)

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

main :: IO ()
main = do
  mngr <- newTlsManager
  trackers <- T.newTrackers

  let dest = "/sky"
  let req = ""

  -- pg <- newMVar P.newProgress
  -- download mngr dest pg req ("test", "mp4")

  id <- T.startTracker trackers P.newProgress $ \pg -> do
    download mngr dest pg req ("test", "mp4")

  forM_ [1..30] $ \_ -> do
    T.collect trackers >>= print
    threadDelay (1 * 1000 * 1000)

  return ()

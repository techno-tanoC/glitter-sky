{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified GlitterSky.File as File
import qualified GlitterSky.HTTP as HTTP
import qualified GlitterSky.Progress as P
import qualified GlitterSky.Renamer as Renamer
import qualified GlitterSky.Tracker as T

import Control.Concurrent.MVar
import qualified Control.Concurrent as C
import qualified Data.ByteString as BS
import Network.HTTP.Client
import Network.HTTP.Client.TLS (newTlsManager)
import qualified System.IO as IO

main :: IO ()
main = do
  mngr <- newTlsManager
  trackers <- T.newTrackers

  let req = "https://cdn.img-conv.gamerch.com/img.gamerch.com/imascg-slstage-wiki/1454616481001.jpg"
  let dest = "/sky"
  T.startTracker trackers P.newProgress $ \pg -> do
    withResponse req mngr $ \res -> do
      case HTTP.findCL res of
        Just cl -> P.setCL pg cl
        Nothing -> return ()

      File.actBinaryTempFile
        (\path handle -> HTTP.readAll (responseBody res) $ processChunk pg handle)
        (\path -> do
          putStrLn path
          Renamer.copy path (dest, "morikubo", "jpg"))
      putStrLn "end"

  readLn :: IO String
  return ()

processChunk :: MVar P.Progress -> IO.Handle -> BS.ByteString -> IO ()
processChunk pg h bs = do
  P.progress pg $ BS.length bs
  BS.hPut h bs
  readMVar pg >>= print

module GlitterSky.Progress where

import Control.Concurrent.MVar

data Progress = Progress {
  name :: String,
  contentLength :: Int,
  aquired :: Int
} deriving Show

newProgress :: String -> Progress
newProgress n = Progress n 0 0

setCL :: MVar Progress -> Int -> IO ()
setCL pg i = modifyMVarMasked_ pg $ \c ->
  return $ c { contentLength = i }

progress :: MVar Progress -> Int -> IO ()
progress pg i = modifyMVarMasked_ pg $ \c ->
  return $ c { aquired = aquired c + i }

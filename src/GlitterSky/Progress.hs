module GlitterSky.Progress where

import Control.Concurrent.MVar

data Progress = Progress {
  contentLength :: Int,
  aquired :: Int
} deriving Show

newProgress :: Progress
newProgress = Progress 0 0

setCL :: MVar Progress -> Int -> IO ()
setCL pg i = modifyMVarMasked_ pg $ \c ->
  return $ c { contentLength = i }

progress :: MVar Progress -> Int -> IO ()
progress pg i = modifyMVarMasked_ pg $ \c ->
  return $ c { aquired = aquired c + i }

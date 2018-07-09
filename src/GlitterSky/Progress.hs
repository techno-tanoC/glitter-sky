module GlitterSky.Progress where

import Control.Concurrent.MVar
import Data.Int

data Container = Container {
  contentLength :: Integer,
  aquired :: Integer
} deriving Show

type Progress = MVar Container

newProgress :: IO Progress
newProgress = newMVar $ Container 0 0

setCL :: Progress -> Integer -> IO ()
setCL pg i = modifyMVarMasked_ pg $ \c ->
  return $ c { contentLength = i }

progress :: Progress -> Integer -> IO ()
progress pg i = modifyMVarMasked_ pg $ \c ->
  return $ c { aquired = aquired c + i }

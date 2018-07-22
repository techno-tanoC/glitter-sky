module GlitterSky.File where

import Control.Exception
import System.Directory
import System.IO

-- handle exceptions
actBinaryTempFile :: (FilePath -> Handle -> IO a) -> (FilePath -> IO b) -> IO b
actBinaryTempFile f after = bracket
  (openBinaryTempFileWithDefaultPermissions "/tmp" "glitter-sky.temp")
  (\(path, handle) -> do
    removeFile path)
  (\(path, handle) -> do
    f path handle
    hClose handle
    after path)

module GlitterSky.File where

import Control.Exception
import System.Directory
import System.IO

-- handle exceptions
actBinaryTempFile :: (FilePath -> Handle -> IO a) -> (FilePath -> IO b) -> IO a
actBinaryTempFile f after = bracket
  (openBinaryTempFileWithDefaultPermissions "/tmp" "glitter-sky.temp")
  (\(path, handle) -> do
    hClose handle
    after path
    removeFile path)
  (uncurry f)

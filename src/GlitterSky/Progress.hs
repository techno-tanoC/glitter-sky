module GlitterSky.Progress where

import Control.Concurrent.MVar
import qualified Data.ByteString as BS
import Data.Char (chr)
import Data.Int
import Data.Word (Word8)
import qualified Data.Map.Strict as Map
import Network.HTTP.Types.Header as H
import qualified Safe as S

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

findCL :: H.ResponseHeaders -> Maybe Int
findCL hs = do
    bs <- find hs
    S.readMay . bytesToString . BS.unpack $ bs
  where
    find :: H.ResponseHeaders -> Maybe BS.ByteString
    find = Map.lookup H.hContentLength . Map.fromList
    bytesToString :: [Word8] -> String
    bytesToString = map (chr . fromIntegral)

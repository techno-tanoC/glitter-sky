module GlitterSky.HTTP where

import Control.Concurrent.MVar
import qualified Data.ByteString as BS
import Data.Char (chr)
import Data.Word (Word8)
import qualified Data.Map.Strict as Map
import Network.HTTP.Client
import Network.HTTP.Types.Header as H
import qualified Safe as S

readAll :: BodyReader -> (BS.ByteString -> IO a) -> IO ()
readAll reader f = do
  bs <- brRead reader
  f bs
  if BS.length bs == 0 then
    return ()
  else
    readAll reader f

findCL :: Response a -> Maybe Int
findCL res = do
    bs <- find $ responseHeaders res
    S.readMay . bytesToString . BS.unpack $ bs
  where
    find :: H.ResponseHeaders -> Maybe BS.ByteString
    find = Map.lookup H.hContentLength . Map.fromList
    bytesToString :: [Word8] -> String
    bytesToString = map (chr . fromIntegral)

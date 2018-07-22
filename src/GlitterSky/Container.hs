{-# LANGUAGE DeriveGeneric #-}
module GlitterSky.Container where

import qualified GlitterSky.Progress as P
import qualified GlitterSky.Tracker as T

import Control.Concurrent.MVar
import Data.Aeson (ToJSON)
import qualified Data.Map.Strict as Map
import Data.Traversable (traverse)
import GHC.Generics

data Container = Container {
  id :: String,
  name :: String,
  total :: Int,
  size :: Int
} deriving Generic

instance ToJSON Container

extract :: T.Trackers P.Progress -> IO [Container]
extract mvar = do
    ts <- readMVar mvar
    traverse convert $ Map.elems ts
  where
    convert :: T.Tracker P.Progress -> IO Container
    convert t = do
      P.Progress n cl a <- T.readContent t
      return $ Container (T.readId t) n cl a

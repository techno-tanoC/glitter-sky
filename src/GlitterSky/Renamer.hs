module GlitterSky.Renamer where

import Control.Concurrent.MVar
import qualified System.Directory as D
import System.FilePath
import System.IO.Unsafe (unsafePerformIO)

type Sem = MVar ()

{-# NOINLINE sem #-}
sem :: Sem
sem = unsafePerformIO $ newMVar ()

sync :: IO a -> IO a
sync f = do
  () <- takeMVar sem
  a <- f
  putMVar sem ()
  return a

type Path = String
type Name = String
type Ext = String

copy :: Path -> Name -> Ext -> IO ()
copy path name ext = sync $ do
  fresh <- freshName path name ext
  undefined

freshName :: Path -> Name -> Ext -> IO Name
freshName p n e = go 0
  where
    fullPath i = p </> buildName n e i
    go i = do
      b <- D.doesPathExist $ fullPath i
      if b then
        go (i + 1)
      else
        return $ fullPath i

buildName :: Name -> Ext -> Int -> String
buildName name e i = name ++ count i ++ tail e
  where
    tail :: String -> String
    tail "" = ""
    tail ex = '.' : ex
    count :: Int -> String
    count x
      | x <= 0 = ""
      | otherwise = "(" ++ show x ++ ")"

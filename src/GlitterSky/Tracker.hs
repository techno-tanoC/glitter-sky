module GlitterSky.Tracker where

import Control.Concurrent.MVar
import qualified Control.Concurrent as C
import Control.Exception as Ex
import Data.Traversable (traverse)
import qualified Data.Map.Strict as Map

data Tracker a = Tracker {
  content :: MVar a,
  threadId :: C.ThreadId
}

cancelTracker :: Tracker a -> IO ()
cancelTracker = C.killThread . threadId

readContent :: Tracker a -> IO a
readContent = readMVar . content

type Id = String
type Trackers a = MVar (Map.Map Id (Tracker a))

newTrackers :: IO (Trackers a)
newTrackers = newMVar Map.empty

insert :: Show a => Tracker a -> Trackers a -> IO ()
insert t mvar = modifyMVarMasked_ mvar $ \ts -> do
  return $ Map.insert (show . threadId $ t) t ts

delete :: Show a => Id -> Trackers a -> IO ()
delete id mvar = modifyMVarMasked_ mvar $ \ts -> do
  return $ Map.delete id ts

startTracker :: Show a => a -> Trackers a -> (MVar a -> IO ()) -> IO ()
startTracker a mvar f = do
  c <- newMVar a
  C.forkIO $ bracket
    (do
      my <- C.myThreadId
      let tracker = Tracker c my
      insert tracker mvar
    )
    (\_ -> do
      my <- C.myThreadId
      delete (show my) mvar
    )
    (\_ -> f c)
  return ()

cancel :: Id -> Trackers a -> IO Bool
cancel id mvar = do
  ts <- readMVar mvar
  case Map.lookup id ts of
    Just t -> do
      cancelTracker t
      return True
    Nothing -> return False

collect :: Trackers a -> IO [a]
collect mvar = do
  ts <- readMVar mvar
  traverse readContent $ Map.elems ts

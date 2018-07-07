module GlitterSky.Tracker where

import qualified Data.List as L
import Data.Traversable (traverse)
import Control.Concurrent.MVar
import qualified Control.Concurrent as C

data Tracker a = Tracker {
  container :: MVar a,
  threadId :: C.ThreadId
}

instance Eq (Tracker a) where
  x == y = threadId x == threadId y

startTracker :: a -> (MVar a -> IO ()) -> IO (Tracker a)
startTracker a f = do
  var <- newMVar a
  id <- C.forkIO $ f var
  return $ Tracker var id

cancelTracker :: Tracker a -> IO ()
cancelTracker = C.killThread . threadId

readContainer :: Tracker a -> IO a
readContainer = readMVar . container

type Trackers a = [Tracker a]
type Id = String

find :: Id -> Trackers a -> Maybe (Tracker a)
find id = L.find eq
  where eq t = (show . threadId $ t) == id

cancel :: Id -> Trackers a -> IO Bool
cancel id ts = do
  case find id ts of
    Just t -> do
      cancelTracker t
      return True
    Nothing -> return False

collect :: Trackers a -> IO [a]
collect = traverse readContainer

#!/usr/bin/env stack
-- stack --install-ghc runghc --nix --nix-pure --package "directory" --package "MissingH"

import System.Directory
import Control.Monad
import System.FilePath.Posix
import Data.List

data Battery = Battery {
  battCapacity :: Double
  }

instance Show Battery where
  show (Battery b) = show $ "Battery " ++ show b ++ "%"

baseDir :: FilePath
baseDir = "/sys/class/power_supply/"

-- /sys/class/power_supply/BAT1/capacity
readCapacity :: FilePath -> IO Double
readCapacity f = do
  rf <- readFile f
  return $ read rf :: IO Double

lsBatt :: IO [FilePath]
lsBatt = listDirectory baseDir
  >>= filterM (return . isPrefixOf "BAT")
  >>= mapM (return . (</> "capacity") . (</>) baseDir)

nbBatt :: IO Int
nbBatt = fmap length lsBatt

main :: IO ()  
main = do
  sumbatt <- fmap sum (lsBatt >>= mapM readCapacity)
  nbbatt <- nbBatt
  print $ Battery (sumbatt / fromIntegral nbbatt)


#!/usr/bin/env stack
-- stack --install-ghc runghc --nix --nix-pure --package "directory" --package "text"

import System.Directory
import Control.Monad
import System.FilePath.Posix
import Data.List

type BattName = String

data Battery = Battery {
  battName :: String
  , battCapacity :: Double
  , battStatus :: String
  }

instance Show Battery where
  show (Battery n c s) = show $ "Battery " ++ n ++ " " ++ show c ++ "% " ++ s ++ ""

baseDir :: FilePath
baseDir = "/sys/class/power_supply/"

-- /sys/class/power_supply/BAT1/capacity
readCapacity :: BattName -> IO Double
readCapacity bn = do
  rf <- readFile (baseDir </> bn </> "capacity")
  return $ read rf :: IO Double

readStatus :: BattName -> IO String
readStatus bn = do
  rf <- readFile (baseDir </> bn </> "status")
  return rf
  
lsBatt :: IO [BattName]
lsBatt = listDirectory baseDir
  >>= filterM (return . isPrefixOf "BAT")

nbBatt :: IO Int
nbBatt = fmap length lsBatt

main :: IO ()  
main = do
  lsbatt <- lsBatt
             >>= mapM (\b -> do
                          bCapa <- readCapacity b
                          bStat <- readStatus b
                          return $ Battery b bCapa bStat
                      )
  sumBatt <- fmap sum (lsBatt >>= mapM readCapacity)
  nbbatt <- nbBatt

  putStrLn "List batteries :"
  mapM_ (\b -> putStr $ "\t- " ++ battName b ++ " "
               ++ show (battCapacity b)
               ++ "% "++ battStatus b) lsbatt
  putStrLn $ "Full capacity: " ++ show (sumBatt / fromIntegral nbbatt) ++ "%"


{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE TemplateHaskell #-}
module Main where

import qualified Data.ByteString.Lazy as B
import qualified Data.List as List
import Data.Data
import Data.Monoid
import Debug
import qualified Debug.Hoed as Hoed

debug [d|
    quicksort :: (a -> a -> Bool) -> [a] -> [a]
    quicksort op [] = []
    quicksort op (x:xs) = quicksort op lt ++ [x] ++ quicksort op gt
        where (lt, gt) = partition (op x) xs

    partition               :: (a -> Bool) -> [a] -> ([a],[a])
    {-# INLINE partition #-}
    partition p xs = foldr (select p) ([],[]) xs

    select :: (a -> Bool) -> a -> ([a], [a]) -> ([a], [a])
    select p x ~(ts,fs) | p x       = (x:ts,fs)
                        | otherwise = (ts, x:fs)
    |]

quicksort0 :: String -> String
quicksort0 = Hoed.observe "quicksort" quicksort0'
quicksort0' [] = []
quicksort0' (x:xs) = quicksort0 lt ++ [x] ++ quicksort0 gt
        where (lt, gt) = List.partition (< x) xs

debug [d|
    foo :: m a -> m a
    foo = id
    |]

main = do
    _ <- return ()
    trace <- getDebugTrace defaultHoedOptions $ putStrLn$ quicksort (<) "haskell"
    debugPrintTrace trace
    B.writeFile "trace.js" . ("var trace =\n" <>) . (<> ";") $ debugJSONTrace trace
    debugSaveTrace "trace.html" trace
    print $ foo [1::Int]

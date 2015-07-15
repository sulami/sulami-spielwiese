{-# OPTIONS_GHC -O2 #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}

module Sim (
  Property, Ent, Generation, Config (..),
  evolution, run, printEnt, printGen
) where

import Data.List (sortBy)
import System.Random (randomRIO)

type Property   = (String, IO Float)
type Ent        = [Property]
type Generation = [Ent]

data Config     = Config {
    genSize         :: Int,
    mutProbability  :: Float,
    mutRange        :: Float
  }

mutate :: Config -> Ent -> [Ent]
mutate conf base = mut base : mutate conf base
  where
    mut :: Ent -> Ent
    mut base = map chProp base

    chProp :: Property -> Property
    chProp (n, p) = let np = do r1 <- randomRIO (0, 1) :: IO Float
                                let v = if r1 <= mutProbability conf
                                        then randomRIO (-1 * mutRange conf,
                                                        mutRange conf)
                                        else return 0
                                nv <- v
                                op <- p
                                return (op * (1 + nv))
                    in (n, np)

evolution :: Config -> Ent -> Generation
evolution conf base = take (genSize conf) $ base : mutate conf base

best :: Ord a => (Ent -> a) -> Generation -> Ent
best f gen = fst $ last $ sortBy s $ zip gen $ map f gen

run :: Ord a => Config -> Generation -> (Ent -> a) -> [Ent]
run conf gen f = let winner = best f gen
                     ngen = evolution conf winner
                  in winner : run conf ngen f

s :: Ord a => (b, a) -> (b, a) -> Ordering
s (_, a) (_, b) | a > b     = GT
                | a < b     = LT
                | otherwise = EQ

printGen :: Generation -> IO ()
printGen []     = return ()
printGen (x:xs) = do printEnt x
                     printGen xs

printEnt :: Ent -> IO ()
printEnt []     = return ()
printEnt (x:xs) = do putStr $ fst x ++ ": "
                     v <- snd x
                     print v
                     printEnt xs


{-# OPTIONS_GHC -O2 #-}

module Neural (
  mkNeuNet,
  predict, train
  ) where

import Data.Matrix

type Data          = Matrix Double
type Synapse       = Matrix Double
data NeuralNetwork = NeuralNetwork {
  layerCount  :: Int,
  shape       :: [Int],
  weights     :: [Synapse]
} deriving (Show)

-- | Construct a new neural network with the shape supplied.
mkNeuNet :: [Int] -> NeuralNetwork
mkNeuNet s = NeuralNetwork (length s) s $ mkSyns $ zip (init s) (tail s)

mkSyns :: [(Int, Int)] -> [Synapse]
mkSyns = foldl (\r (y,x) -> r ++ [zero x $ y + 1]) []

dot :: Matrix Double -> Matrix Double -> Matrix Double
dot a b = fromLists [zipWith (*) (toList a) (toList b)]

sigmoid :: Double -> Double
sigmoid x = 1 / (1 + exp(-x))

sigmoidDeriv :: Double -> Double
sigmoidDeriv x = x * (1 - x)

-- | Use the synapse to try to predict the result of the data.
predict :: Synapse -> Data -> Data
predict syn d1 = fmap sigmoid $ multStd2 d1 syn

delta :: Data -> Data -> Data
delta want res = transpose $ (want - res) `dot` (fmap sigmoidDeriv res)

updWght :: Synapse -> Data -> Data -> Synapse
updWght syn d dlt = let mod = (transpose d) * dlt in syn + mod

-- | Use a base synapse, input data and expected output to train the synapse
-- for c iterations.
train :: Synapse -> Data -> Data -> Int -> Synapse
train syn _  _  0 = syn
train syn d1 d2 c = let dlt = delta d2 $ predict syn d1
                        ns = updWght syn d1 dlt
                     in train ns d1 d2 (c-1)


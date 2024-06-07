{-
-- EPITECH PROJECT, 2024
-- B-FUN-400-BAR-4-1-compressor-renzo.maggiori
-- File description:
-- Kmeans.hs
-}

module Kmeans (RGB(..), Position(..), Pixel(..), kMeans) where
import System.Random (randomRIO)
import Parser (Config(..))

data RGB = RGB { red :: Int, green :: Int, blue :: Int }

data Position = Position { x :: Int, y :: Int }

data Pixel = Pixel { position :: Position, colour :: RGB }

data Cluster = Cluster { centroid :: Centroid , pixels :: [Pixel] }

instance Show RGB where
    show (RGB r g b) = "(" ++ show r ++ "," ++ show g ++ "," ++ show b ++ ")"

instance Show Position where
    show (Position x' y') = "(" ++ show x' ++ "," ++ show y' ++ ")"

instance Show Cluster where
    show (Cluster c ps) = "--\n" ++ show c ++ "\n-" ++ concatMap showPixel ps
        where
            showPixel (Pixel pos col) = "\n" ++ show pos ++ " " ++ show col

type Centroid = RGB

instance Eq RGB where
    (==) (RGB r g b) (RGB r' g' b') = r == r' && g == g' && b == b'

getRandomCentroids :: [RGB] -> Int -> IO [Centroid]
getRandomCentroids _ 0 = return []
getRandomCentroids rgb n = do
    randomIndex <- randomRIO (0, length rgb - 1)
    let randomCluster =  rgb !! randomIndex
    let remainingRGB = filter (\x' -> x' /= randomCluster) rgb
    restOfClusters <- getRandomCentroids remainingRGB(n - 1)
    return (randomCluster : restOfClusters)

distance :: RGB -> RGB -> Float
distance p1 p2 = sqrt $ fromIntegral ((red p1 - red p2) ^ (2 :: Int)
    + (green p1 - green p2) ^ (2 :: Int)
    + (blue p1 - blue p2) ^ (2 :: Int))

getNearestCentroid :: Pixel -> [Centroid] -> Centroid
getNearestCentroid pixel centroids = foldl1
    (\x' y' -> if distance (colour pixel) x' < distance (colour pixel) y'
    then x' else y') centroids

getNearestPixels :: [Pixel] -> [Centroid] -> Centroid -> [Pixel]
getNearestPixels pixels' centroids centroid' =
    filter (\x' -> centroid' == getNearestCentroid x' centroids) pixels'

assignClusters :: [Pixel] -> [Centroid] -> [Cluster]
assignClusters pixels' centroids =
    let assignForCentroid centroid' = Cluster {
        centroid = centroid',
        pixels = getNearestPixels pixels' centroids centroid'
        }
    in map assignForCentroid centroids

calculateNewCentroids :: [Cluster] -> [Centroid]
calculateNewCentroids clusters =
    let centroidsMean pixels' = RGB {
        red = sum (map (red . colour) pixels') `div` length pixels',
        green = sum (map (green . colour) pixels') `div` length pixels',
        blue = sum (map (blue . colour) pixels') `div` length pixels'
        }
    in map (\x' -> centroidsMean (pixels x')) clusters


calculateConvergence :: [Cluster] -> [Cluster] -> Float
calculateConvergence old new = maximum (map calculateMovement (zip old new))

calculateMovement :: (Cluster, Cluster) -> Float
calculateMovement (oldCluster, newCluster) =
        abs (distance (centroid oldCluster) (centroid newCluster))

kMeansLoop :: [Pixel] -> [Cluster] -> Float -> IO ()
kMeansLoop pixels' clusters limit =
    let newCentroids = calculateNewCentroids clusters
        newClusters = assignClusters pixels' newCentroids
    in if calculateConvergence clusters newClusters > limit
        then kMeansLoop pixels' newClusters limit
        else printResult newClusters

printResult :: [Cluster] -> IO()
printResult [] = return ()
printResult (x':xs) = print x' >> printResult xs

kMeans :: [Pixel] -> Config -> IO ()
kMeans pixels' config = do
        centroids <- getRandomCentroids (map colour pixels') (colors config)
        let clusters = assignClusters pixels' centroids
        kMeansLoop pixels' clusters (convergence config)

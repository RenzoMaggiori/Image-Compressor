{-
-- EPITECH PROJECT, 2024
-- B-FUN-400-BAR-4-1-compressor-renzo.maggiori
-- File description:
-- Main
-}

module Main (main) where

import Parser (getOptions, Config(..))
import Kmeans (kMeans)
import FileHandling (parseFileContent)
import System.Environment (getArgs)
import System.Exit (exitWith, ExitCode(ExitFailure))

processContent :: String -> Config -> IO ()
processContent content config =
    case parseFileContent content of
        Left errMsg ->
            putStrLn errMsg >>
            exitWith (ExitFailure 84)
        Right imagePoints ->
            kMeans imagePoints config

startProcess :: Config -> IO ()
startProcess config = do
    content <- readFile (file config)
    processContent content config

main :: IO ()
main = do
    args <- getArgs
    case getOptions args of
        Just config -> startProcess config
        Nothing ->
            putStrLn "Error: Invalid arguments" >>
            exitWith (ExitFailure 84)


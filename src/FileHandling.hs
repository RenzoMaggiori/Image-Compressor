{-
-- EPITECH PROJECT, 2024
-- B-FUN-400-BAR-4-1-compressor-renzo.maggiori
-- File description:
-- FileHandling
-}

module FileHandling (parseFileContent) where

import Kmeans (Pixel(..), RGB(..), Position(..))
import Text.ParserCombinators.ReadP
import Data.Char (isDigit, isSpace)

parseInt :: ReadP Int
parseInt = skipSpaces >> read <$> munch1 isDigit

parseWithSpaces :: ReadP a -> ReadP a
parseWithSpaces p = skipSpaces >> p >>= \result -> skipSpaces >> return result

parseTuple :: ReadP (Int, Int)
parseTuple =
    parseWithSpaces (char '(') >>
    parseWithSpaces parseInt >>= \xpos ->
    parseWithSpaces (char ',') >>
    parseWithSpaces parseInt >>= \ypos ->
    parseWithSpaces (char ')') >>
    return (xpos, ypos)

parseTriple :: ReadP (Int, Int, Int)
parseTriple =
    parseWithSpaces (char '(') >>
    parseWithSpaces parseInt >>= \r ->
    parseWithSpaces (char ',') >>
    parseWithSpaces parseInt >>= \g ->
    parseWithSpaces (char ',') >>
    parseWithSpaces parseInt >>= \b ->
    parseWithSpaces (char ')') >>
    return (r, g, b)


parseLine :: ReadP Pixel
parseLine =
    parseTuple >>= \pos ->
    skipSpaces >>
    parseTriple >>= \vals ->
    return (Pixel (uncurry Position pos) (uncurry3 RGB vals))


uncurry3 :: (a -> b -> c -> d) -> (a, b, c) -> d
uncurry3 f (a, b, c) = f a b c

parseSingleLine :: String -> Either String Pixel
parseSingleLine line = case readP_to_S parseLine (trim line) of
    [(result, "")] -> Right result
    _ -> Left "Error: Invalid format."

trim :: String -> String
trim = f . f
  where f = reverse . dropWhile isSpace

parseFileContent :: String -> Either String [Pixel]
parseFileContent input = case lines input of
    [] -> Left "Error: Input file is empty."
    ls -> traverse parseSingleLine ls


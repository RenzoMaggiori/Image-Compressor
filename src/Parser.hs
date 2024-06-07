{-
-- EPITECH PROJECT, 2024
-- B-FUN-400-BAR-4-1-compressor-renzo.maggiori
-- File description:
-- Parser
-}

module Parser (getOptions, Config(..)) where

import Text.Read (readMaybe)

data Config = Config {
    colors :: Int,
    convergence :: Float,
    file :: String
} deriving (Show)

defaultConf :: Config
defaultConf = Config {
    colors = 0,
    convergence = -1.0,
    file = ""
}

getOptions :: [String] -> Maybe Config
getOptions args
  | "-n" `notElem` args || "-l" `notElem` args ||
    "-f" `notElem` args = Nothing
  | otherwise = parseArgs args (Just defaultConf)

updateConfig :: String -> String -> Config -> Maybe Config
updateConfig "-n" val conf = case readMaybe val of
    Just n -> Just conf { colors = n }
    Nothing -> Nothing
updateConfig "-l" val conf = case readMaybe val of
    Just l -> Just conf { convergence = l }
    Nothing -> Nothing
updateConfig "-f" val conf = Just conf { file = val }
updateConfig _ _ _ = Nothing

parseArgs :: [String] -> Maybe Config -> Maybe Config
parseArgs [] conf = conf
parseArgs [_] _ = Nothing
parseArgs (o:v:rs) conf = case updateConfig o v <$> conf of
    Just newConf -> parseArgs rs newConf
    Nothing -> Nothing

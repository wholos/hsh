import System.Process (callCommand)
import System.IO (hFlush, stdout, readFile, writeFile)
import System.Directory (createDirectoryIfMissing, getHomeDirectory, doesFileExist)
import System.FilePath (takeDirectory)
import Data.List (isPrefixOf, isSuffixOf)
import Data.Maybe (fromMaybe)

-- config file
getConfigPath :: IO FilePath
getConfigPath = do
    home <- getHomeDirectory
    return $ home ++ "/.config/hsh/config.cfg"

-- base config
defaultConfig :: [(String, String)]
defaultConfig =
    [ ("prompt", "hsh> ")
    , ("welcome_message", "Welcome to HSHshell!")
    , ("history_size", "100")
    ]

-- read config
readConfig :: IO [(String, String)]
readConfig = do
    configPath <- getConfigPath
    exists <- doesFileExist configPath
    if exists
        then do
            content <- readFile configPath
            return $ parseConfig content
        else do
            -- create directory
            createDirectoryIfMissing True (takeDirectory configPath)
            writeConfig defaultConfig
            return defaultConfig

-- parsing config
parseConfig :: String -> [(String, String)]
parseConfig content =
    let lines' = filter (not . null) $ map (takeWhile (/= '#')) $ lines content
        pairs = map (break (== '=')) lines'
    in [ (trim k, trim (drop 1 v)) | (k, v) <- pairs, not (null k) ]
    where trim = dropWhile (== ' ') . reverse . dropWhile (== ' ') . reverse

-- write in file
writeConfig :: [(String, String)] -> IO ()
writeConfig config = do
    configPath <- getConfigPath
    let content = unlines [ k ++ "=" ++ v | (k, v) <- config ]
    writeFile configPath content

getConfigValue :: String -> [(String, String)] -> String
getConfigValue key config = fromMaybe (fromMaybe "" (lookup key defaultConfig)) (lookup key config)

setConfigValue :: String -> String -> [(String, String)] -> [(String, String)]
setConfigValue key value config =
    let config' = filter ((/= key) . fst) config
    in (key, value) : config'

handleConfigCommand :: String -> [(String, String)] -> IO [(String, String)]
handleConfigCommand command config =
    case words command of
        ("set":key:value:_) -> do
            let newConfig = setConfigValue key value config
            writeConfig newConfig
            putStrLn $ "Config updated: " ++ key ++ " = " ++ value
            return newConfig
        ("get":key:_) -> do
            putStrLn $ key ++ " = " ++ getConfigValue key config
            return config
        ("list":_) -> do
            mapM_ (\(k, v) -> putStrLn $ k ++ " = " ++ v) config
            return config
        _ -> do
            putStrLn "Unknown config command. Usage:"
            putStrLn "  set <key> <value> - Set config value"
            putStrLn "  get <key> - Get config value"
            putStrLn "  list - List all config values"
            return config

executeCommand :: String -> IO ()
executeCommand command = do
    callCommand command

-- repl func
repl :: [(String, String)] -> IO ()
repl config = do
    let prompt = getConfigValue "prompt" config
    putStr prompt
    hFlush stdout
    command <- getLine
    case command of
        "exit" -> putStrLn "Exiting shell..."
        "config" -> do
            putStr "config> "
            hFlush stdout
            configCommand <- getLine
            newConfig <- handleConfigCommand configCommand config
            repl newConfig
        _ -> do
            executeCommand command
            repl config

-- start shell
main :: IO ()
main = do
    config <- readConfig
    let welcome = getConfigValue "welcome_message" config
    putStrLn welcome
    repl config

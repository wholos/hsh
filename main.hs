import System.Process (callCommand)
import System.IO (hFlush, stdout)

executeCommand :: String -> IO ()
executeCommand command = do
    callCommand command

-- main func
repl :: IO ()
repl = do
    putStr "hsh> "
    hFlush stdout
    command <- getLine
    if command == "exit"
        then putStrLn "Exiting shell..."
        else do
            executeCommand command
            repl

-- shell starting
main :: IO ()
main = repl

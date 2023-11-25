module Main where

import Data.List (nub, isPrefixOf, intercalate)

data Graph a = Graph [a] [(a, a)] deriving (Show, Eq)
data Thing = Thing String deriving Eq

instance Show Thing where
    show (Thing x) = x

splitOn :: Eq a => [a] -> [a] -> [[a]]
splitOn delimiter input = go input []
  where
    go [] acc = reverse acc
    go rest acc =
      let (before, after) = splitOnce delimiter rest
      in go after (before : acc)

splitOnce :: Eq a => [a] -> [a] -> ([a], [a])
splitOnce _ [] = ([], [])
splitOnce delimiter list@(x:xs)
  | delimiter `isPrefixOf` list = ([], drop (length delimiter) list)
  | otherwise =
    let (before, after) = splitOnce delimiter xs
    in (x : before, after)

parseGraph :: String -> Graph Thing
parseGraph content = Graph nodes edges
    where
        edges = map (\[x, y] -> (Thing x, Thing y)) $ map (splitOn " -> ") $ lines content
        nodes = nub $ concatMap (\(x, y) -> [x, y]) edges

inDegree :: Eq a => Graph a -> a -> Int
inDegree (Graph _ edges) node = length $ filter (\(_, y) -> y == node) edges

children :: Eq a => Graph a -> a -> [a]
children (Graph _ edges) node = map snd $ filter (\(x, _) -> x == node) edges

removeNode :: Eq a => Graph a -> a -> Graph a
removeNode (Graph nodes edges) node = Graph nodes' edges'
    where
        nodes' = filter (/= node) nodes
        edges' = filter (\(x, y) -> x /= node && y /= node) edges

khanTopologicalSort :: Eq a => Graph a -> [a]
khanTopologicalSort graph@(Graph nodes edges) = go queue graph []
    where
        queue = filter (\node -> inDegree graph node == 0) nodes
        go [] g acc = reverse acc
        go (node:rest) g acc =
            let cs = children g node
                g' = removeNode g node
                queue' = rest ++ filter (\node -> inDegree g' node == 0) cs
            in go queue' g' (node : acc)

formatResult :: Show a => [a] -> String
formatResult = intercalate " -> " . map show

main :: IO ()
main = do
    let input_file = "input.txt"
    input <- readFile input_file
    let graph = parseGraph input
    let result = khanTopologicalSort graph
    let output = formatResult result
    putStrLn output

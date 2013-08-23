import System.IO
import System.Process
import System.Environment

sub :: [a] -> Int -> [a]
sub x 0  = x
sub [] _ = []
sub x c = sub (tail x) (c - 1)

rev :: [a] -> [a]
rev [] = []
rev (x:xs) = rev xs ++ [x]

positions :: (Eq a) => [a] -> a -> [Int]
positions b c
  | c `notElem` b = [0]
positions x b = [c | (c,d) <- (zip [0..(length x)] x), d == b] 


after :: (Eq a) => [a] -> a -> [a]
after [] _ = []
after x c = sub x (1+ (head (positions x c)))


contains :: (Eq a) => [a] -> [a] -> Bool
contains [] _ = False
contains x c
  | take (length c) x == c = True
  | otherwise = contains (tail x) c

before :: (Eq a) => [a] -> a -> [a]
before x c = filterBreak (/=c) x

filterBreak :: (a -> Bool) -> [a] -> [a]
filterBreak _ [] = []
filterBreak f (c:cs) = if (f c) then (c : (filterBreak f cs)) else []

removeBreak :: (a -> Bool) -> [a] -> [a]
removeBreak _ [] = []
removeBreak f (c:cs) = if (f c) then removeBreak f cs else cs
 
between :: (Eq a) => [a] -> (a,a) -> [a]
between x (a,b) = before (after x a) b

remv :: (Eq a) => [a] -> a -> [a]
remv x c = [d | d <- x, c /= d] 

count :: (Eq a) => [a] -> a -> Int
count a b = sum $ [1 | c <- a, c == b]

safeRemove :: (a -> Bool) -> [a] -> [a]
safeRemove f (x:xs)
  | f x = safeRemove f xs
  | otherwise = (x:xs)
                
rmlws :: String -> String
rmlws x = safeRemove (==' ') (' ':x)

handleSpecial :: String -> String
handleSpecial x
  | '^' `elem` x = (("touch ")++(rmlws (remv (remv x '^') '|')))
  | '%' `elem` x = rmlws ((remv (remv x '%') '|'))
  | '~' `elem` x = ("append "++(rmlws (between x ('~',':'))++(' ':(after x ':'))))
  | x `contains` "###" = ""
  | otherwise = x

hasAny :: (Eq a) => [a] -> [a] -> Bool
hasAny x c = or $ map ((flip elem) x) c

linesBetween :: [String] -> (String,String) -> [String]
linesBetween [] _ = []
linesBetween (x:xs) (a,b)
  | x `contains` a = filterBreak (\c -> (not (c `contains` b))) xs
  | otherwise = linesBetween xs (a,b)

directorySetup :: [String] -> [String]
directorySetup [] = []
directorySetup [x]
  | x `contains` "###" = []
  | hasAny x "^%~" = [handleSpecial x]
  | otherwise = ["mkdir "++(remv x '|')]
directorySetup (x:y:xs)
  | x `contains` "###" = rest
  | x `contains` "~{" = let filename = (between x ('{',':')) in map (\c -> "append "++(filename++" ")++c) (map condClean (linesBetween (x:y:xs) ("{","}"))) ++ directorySetup ((removeBreak (\c -> '}' `notElem` c)) (y:xs))
  | hasAny x "^%~" = handleSpecial x : rest
  | bars y > bars x = ("mkdir " ++ (cleanX)):("cd " ++ cleanX):rest
  | bars y == bars x = ("mkdir " ++ cleanX):rest
  | otherwise = ("mkdir " ++ cleanX):surface++rest
  where cleanX = (remv x '|')
        rest = directorySetup (y:xs)
        bars = ((flip count) '|')
        surface = (take (bars x - bars y) (repeat "cd ..")) --cd for every difference in bars
        condClean x = if '|' `elem` x then (remv x '|') else x

getLines :: String -> IO ([String])
getLines x = do
  file <- openFile x ReadMode
  contents <- hGetContents file
  return (lines contents)
  
main = do
  (inp:outp:_) <- getArgs
  lines <- getLines inp
  writeFile outp $ unlines ("#/bin/bash":(directorySetup lines))
  system("chmod +x " ++ outp)
  

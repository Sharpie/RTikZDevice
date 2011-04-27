#!/usr/bin/env runghc
{-
A simple script to reformat Markdown into an Rdoc NEWS file. Written in Haskell
because... well just because.

WARNING: Prolonged exposure to Haskell can cause your head to explode.
-}

import System.Environment -- For accessing program arguments
import Data.Maybe         -- For handling values that may or may not be values

import Text.Pandoc
import Text.Pandoc.Shared
import Text.Pandoc.Readers.Markdown


{-
This function takes the result of a Pandoc parser, extracts the contents,
formats them into Rd strings and returns a list of the results.
-}
pandocToRd :: Pandoc -> [String]
-- mapMaybe is like a regular functional mapping except it throws out Nothing
-- values and unpacks Just values.
pandocToRd parsed = map show $ mapMaybe blockToRd (getBlocks parsed)


{-
This function extracts the "block list" from the Pandoc object returned by
Pandoc readers such as `readMarkdown`.

More information about the structure of the block list can be found in the
documentation of the pandoc-types package:

  http://hackage.haskell.org/packages/archive/pandoc-types/1.8/doc/html/Text-Pandoc-Definition.html
-}
getBlocks :: Pandoc -> [Block]
getBlocks (Pandoc meta blocks) = blocks

{-
This function is responsible for possibly formatting each block element into a
string. Some block types are ignored and so the value Nothing is returned.
-}
blockToRd :: Block -> Maybe [String]
-- Individual block types
blockToRd (Plain elements) = return $ [concat $ inlineListToRd elements]
blockToRd (Para elements) = return $ [concat $ inlineListToRd elements]
blockToRd (Header level elements) = case level of
  1 -> return $ ["\\section{" ++ (concat $ inlineListToRd elements) ++ "}"]
  2 -> return $ ["\\subsection{" ++ (concat $ inlineListToRd elements) ++ "}"]
  _ -> Nothing -- Rdoc only has 2 header levels. Silently ignoring anything else
blockToRd (BulletList blocks) = do
  let makeListItem list = "\\item{" : list ++ ["}"]
  return $ "\\itemize{" : map (concat . makeListItem . blockListToRd) blocks ++ ["}"]
blockToRd HorizontalRule = Nothing
blockToRd Null = Nothing
-- Passed through uninterpreted for now
blockToRd other = return $ [show other]

blockListToRd :: [Block] -> [String]
blockListToRd blocks = concat $ mapMaybe blockToRd blocks

inlineListToRd :: [Inline] -> [String]
inlineListToRd elements = mapMaybe inlineToRd elements

{-
This function is responsible for possibly formatting inline elements into a
string
-}
inlineToRd :: Inline -> Maybe String
inlineToRd (Str string) = return $ sanitizeString string
inlineToRd (RawInline format string) = return $ sanitizeString string
inlineToRd (Code attr string) = return $ "\\code{" ++ string ++ "}"
inlineToRd Space = return " "
inlineToRd other = return $ show other

sanitizeString :: String -> String
sanitizeString = escapeStringUsing latexEscapes
  where latexEscapes = backslashEscapes "{}$%&_#" ++
                       [ ('^', "\\^{}")
                       , ('\\', "\\textbackslash{}")
                       , ('~', "\\ensuremath{\\sim}")
                       , ('|', "\\textbar{}")
                       , ('<', "\\textless{}")
                       , ('>', "\\textgreater{}")
                       , ('[', "{[}")  -- to avoid interpretation as
                       , (']', "{]}")  -- optional arguments
                       , ('\160', "~")
                       , ('\x2018', "`")
                       , ('\x2019', "'")
                       , ('\x201C', "``")
                       , ('\x201D', "''")
                       ]


{- Main Script -}
main :: IO()
main = do
  input_file <- fmap (!! 0) (getArgs)
  parsed_markdown <- fmap (readMarkdown defaultParserState) (readFile input_file)
  let results = pandocToRd parsed_markdown
  -- The unlines function joins a list of strings into one big string using
  -- newlines
  writeFile "NEWS.Rd" $ unlines results
  putStrLn "Output written to NEWS.Rd"


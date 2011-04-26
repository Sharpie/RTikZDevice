#!/usr/bin/env runghc
{-
A simple script to reformat Markdown into an Rdoc NEWS file. Written in Haskell
because... well just because.

WARNING: Prolonged exposure to Haskell can cause your head to explode.
-}

import System.Environment

import Text.Pandoc
import Text.Pandoc.Readers.Markdown


{-
This function takes the result of a Pandoc parser, extracts the contents,
formats them into Rd strings and returns a list of the results.
-}
pandocToRd :: Pandoc -> [String]
pandocToRd parsed = do
  let blocks = getBlocks parsed
  map show blocks

{-
This function extracts the "block list" from the Pandoc object returned by
Pandoc readers such as `readMarkdown`.

More information about the structure of the block list can be found in the
documentation of the pandoc-types package:

  http://hackage.haskell.org/packages/archive/pandoc-types/1.8/doc/html/Text-Pandoc-Definition.html
-}
getBlocks :: Pandoc -> [Block]
getBlocks (Pandoc meta blocks) = blocks


{- Main Script -}
main :: IO()
main = do
  input_file <- fmap (!! 0) (getArgs)
  parsed_markdown <- fmap (readMarkdown defaultParserState) (readFile input_file)
  let results = pandocToRd parsed_markdown
  writeFile "NEWS.Rd" $ unlines results
  putStrLn "Output written to NEWS.Rd"

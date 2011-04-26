#!/usr/bin/env runghc
{-
A simple script to reformat Markdown into an Rdoc NEWS file. Written in Haskell
because... well just because.

WARNING: Prolonged exposure to Haskell can cause your head to explode.
-}

import System.Environment

import Text.Pandoc
import Text.Pandoc.Readers.Markdown


main :: IO()
main = do
  input_file <- fmap (!! 0) (getArgs)
  parsed_markdown <- fmap (readMarkdown defaultParserState) (readFile input_file)
  print parsed_markdown

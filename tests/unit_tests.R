#!/usr/bin/env Rscript
if (nchar(Sys.getenv('R_TESTS')) == 0){
  # Protects against R CMD check
  library(tikzDevice)
  library(testthat)
  require(stringr)

  require(tools)
  require(evaluate)

  test_args <- commandArgs(TRUE)
  torture_mem <- any(str_detect(test_args, '^--use-gctorture'))

  if ( length(tags_to_run <- test_args[str_detect(test_args, '^--run-tests')]) ) {
    tags_to_run <- unlist(str_split(
        str_split(tags_to_run, '=')[[1]][2],
        ',' ))
  }

  if (torture_mem) { gctorture(TRUE) }

  # Ensure tikzDevice options have been set to their default values.
  setTikzDefaults(overwrite = TRUE)
  options(tikzMetricsDictionary = NULL)


  test_output_dir <- normalizePath(file.path(getwd(), 'test_output'))
  if( !file.exists(test_output_dir) ){ dir.create(test_output_dir) }

  test_work_dir <- normalizePath(file.path(getwd(), 'test_work'))
  if( !file.exists(test_work_dir) ){ dir.create(test_work_dir) }

  compare_cmd <- Sys.which("compare")
  if ( nchar(compare_cmd) == 0 ) compare_cmd <- NULL
  test_standard_dir <- normalizePath(file.path(getwd(), '..', 'inst', 'tests', 'standard_graphs'))

  test_package('tikzDevice')
}


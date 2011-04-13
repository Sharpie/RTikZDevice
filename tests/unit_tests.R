#!/usr/bin/env Rscript
if (nchar(Sys.getenv('R_TESTS')) == 0){
  # Protects against R CMD check
  library(tikzDevice)
  library(testthat)
  require(stringr)

  require(tools)
  require(evaluate)

  test_args <- commandArgs(TRUE)
  torture_mem <- any(str_detect(test_args, '--use-gctorture'))

  if (torture_mem) { gctorture(TRUE) }

  # Ensure tikzDevice options have been set to their default values.
  setTikzDefaults(overwrite = TRUE)
  options(tikzMetricsDictionary = NULL)


  test_output_dir <- normalizePath(file.path(getwd(), 'test_output'))
  if( !file.exists(test_output_dir) ){ dir.create(test_output_dir) }

  test_work_dir <- normalizePath(file.path(getwd(), 'test_work'))
  if( !file.exists(test_work_dir) ){ dir.create(test_work_dir) }

  test_package('tikzDevice')
}


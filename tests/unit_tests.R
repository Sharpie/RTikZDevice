#!/usr/bin/env Rscript
if (nchar(Sys.getenv('R_TESTS')) == 0){
  # Protects against R CMD check
  library(tikzDevice)
  library(testthat)
  require(stringr)

  require(tools)
  require(evaluate)

  # Set random number generator to a known state so results will be
  # reproducible
  set.seed(42)

  # Process command arguments
  test_args <- commandArgs(TRUE)
  torture_mem <- any(str_detect(test_args, '^--use-gctorture'))

  if ( length(tags_to_run <- test_args[str_detect(test_args, '^--run-tests')]) ) {
    tags_to_run <- unlist(str_split(
        str_split(tags_to_run, '=')[[1]][2],
        ',' ))
  }

  if (torture_mem) { gctorture(TRUE) }
  using_windows <- Sys.info()['sysname'] == 'Windows'

  # Ensure tikzDevice options have been set to their default values.
  setTikzDefaults(overwrite = TRUE)
  options(tikzMetricsDictionary = NULL)


  # Set up directories for test output.
  test_output_dir <- normalizePath(file.path(getwd(), 'test_output'))
  if( !file.exists(test_output_dir) ){ dir.create(test_output_dir) }

  test_work_dir <- normalizePath(file.path(getwd(), 'test_work'))
  if( !file.exists(test_work_dir) ){ dir.create(test_work_dir) }
  test_standard_dir <- normalizePath(file.path(getwd(), '..', 'inst', 'tests', 'standard_graphs'))

  # Locate required external programs
  gs_cmd <- normalizePath(Sys.which(ifelse(using_windows, 'gswin32c', 'gs')))
  if ( nchar(gs_cmd) == 0 ) gs_cmd <- NULL

  compare_cmd <- normalizePath(Sys.which("compare"))
  if ( nchar(compare_cmd) == 0 || is.null(gs_cmd) ) compare_cmd <- NULL

  convert_cmd <- normalizePath(ifelse(using_windows,
    system("bash -c 'which convert'", intern = TRUE, ignore.stderr = TRUE),
    Sys.which('convert')
  ))
  if ( nchar(convert_cmd) == 0 || is.null(gs_cmd) ) convert_cmd <- NULL


  test_package('tikzDevice')

}


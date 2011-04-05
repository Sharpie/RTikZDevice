#!/usr/bin/env Rscript
library(testthat)
library(tikzDevice)

require(tools)
require(stringr)
require(evaluate)

# Ensure tikzDevice options have been set to their default values.
setTikzDefaults(overwrite = TRUE)
options(tikzMetricsDictionary = NULL)


test_output_dir <- normalizePath(file.path(getwd(), 'test_output'))
if( !file.exists(test_output_dir) ){ dir.create(test_output_dir) }

test_work_dir <- normalizePath(file.path(getwd(), 'test_work'))
if( !file.exists(test_work_dir) ){ dir.create(test_work_dir) }

test_package('tikzDevice')

# This file contains custom test reporters.

DetailedReporter <- testthat:::Reporter$clone()
DetailedReporter$do({
  self$width <- getOption('width')
  self$n_tests <- 0
  self$n_failed <- 0
  self$failures <- list()
  self$start_time <- NULL

  self$start_reporter <- function() {
    self$failed <- FALSE
    cat(str_c(rep('=', self$width), collapse=''), '\n')
  }

  self$start_context <- function(desc) {
    cat(str_c('\n', desc, '\n'))
    cat(str_c(rep('-', nchar(desc)), collapse=''), '\n')
    self$context <- desc
    self$n_tests <- 0
    self$n_failed <- 0
    self$failures <- list()
  }

  self$start_test <- function(desc){
    cat(desc)
    self$test <- desc
    self$start_time <- Sys.time()
  }

  self$add_result <- function(result) {
    spacer <- paste(rep(' ',self$width - nchar(self$test) - 5),
      collapse = '')
    if (result$passed) {
      cat(spacer, colourise("PASS\n", fg = "light green"))
    } else {
      self$failed <- TRUE
      self$n_failed <- self$n_failed + 1
      result$test <- self$test
      self$failures[[self$n_failed]] <- result

      cat(spacer, colourise("FAIL\n", fg = "red"))
    }
  }

  self$end_test <- function(){
    elapsed_time <- as.numeric(difftime(Sys.time(), self$start_time,
      units='secs'))
    cat('  Elapsed Time: ', sprintf("%6.2f", elapsed_time), ' seconds\n')
    self$test <- NULL
    self$start_time <- NULL
    self$n_tests <- self$n_tests + 1
  }

  self$end_context <- function() {
    cat(paste(rep('-', self$width), collapse=''), '\n')
    n_success <- self$n_tests - self$n_failed
    success_per <- round( n_success / self$n_tests * 100, 2 )

    test_status <- paste(n_success, '/', self$n_tests,
      ' (', success_per, '%)', sep = '')
    test_status <- ifelse(self$n_failed == 0,
      colourise(test_status, 'light green'),
      colourise(test_status, 'red')
    )

    cat(test_status, 'tests sucessfully executed in this context.\n' )

    if( self$n_failed > 0 ){
      cat('\nOutput from failed tests:\n\n')

      charrep <- function(char, times) {
        sapply(times, function(i) str_c(rep.int(char, i), collapse = ""))
      }

      type <- ifelse(sapply(self$failures, "[[", "error"), "Error", "Failure")
      tests <- sapply(self$failures, "[[", "test")
      header <- str_c(type, ": ", tests, " ")
      linewidth <- ifelse(nchar(header) > getOption("width"),
        0, getOption("width") - nchar(header))
      line <- charrep("-", linewidth )

      message <- sapply(self$failures, "[[", "message")

      cat(str_c(
        colourise(header, "red"), line, "\n",
        message, "\n", collapse = "\n"))

    }
  }


  self$end_reporter <- function() {
    cat(str_c(rep('=', self$width), collapse=''), '\n\n')
  }

})


# This reporter is used by the graphics tests. It is very similar to the
# DetailedReporter, but contains specialized functionality for displaying the
# results of graphics tests.
GraphicsReporter <- DetailedReporter$clone()
GraphicsReporter$do({

  self$start_reporter <- function() {
    self$ran_vis_diff <- FALSE
    self$pixel_error <- 'SKIP'
    self$n_tests <- 0
    self$n_failed <- 0
    self$n_ctx_failed <- 0
    cat(str_c(rep('=', self$width), collapse=''), '\n')
    cat('Graphics Tests', '\n')
    cat(str_c(rep('~', self$width), collapse=''), '\n')
  }

  self$start_context <- function(desc) {
    cat(str_c('\n', desc, '\n'))
    self$failed <- FALSE
  }

  self$start_test <- function(desc){
    cat('  ', desc)
    self$test <- desc
    self$start_time <- Sys.time()
  }

  self$vis_result <- function(pixel_error) {
    self$ran_vis_diff <- TRUE
    self$pixel_error <- pixel_error
  }

  self$add_result <- function(result) {
    if ( self$ran_vis_diff ) {
      if ( self$pixel_error == 'SKIP' ) {
        spacer <- paste(rep(' ',self$width - nchar(self$test) - 19),
          collapse = '')
        cat(spacer, colourise("SKIP", fg = "yellow"), "\n")
      } else {
        spacer <- paste(rep(' ',self$width - nchar(self$test) - 29),
          collapse = '')
        cat(spacer, 'Error of:',
          colourise(sprintf("%8.2g pixels", self$pixel_error), fg = "yellow"),
          "\n"
        )
      }
    } else {
      spacer <- paste(rep(' ',self$width - nchar(self$test) - 19),
        collapse = '')
      if (result$passed) {
        cat(spacer, colourise("PASS", fg = "light green"))
      } else {
        self$failed <- TRUE
        self$n_failed <- self$n_failed + 1
        result$test <- self$test
        self$failures[[self$n_failed]] <- result

        cat(spacer, colourise("FAIL", fg = "red"))
      }
    }
  }

  self$end_test <- function(){
    if( self$ran_vis_diff ) {
      self$ran_vis_diff <- FALSE
    } else {
      elapsed_time <- as.numeric(difftime(Sys.time(), self$start_time,
        units='secs'))
      cat(sprintf(" %6.2f sec\n", elapsed_time))
    }
  }

  self$end_context <- function() {
    if ( self$failed ) {
      self$n_ctx_failed <- self$n_ctx_failed + 1
    }
    self$n_tests <- self$n_tests + 1
  }

  self$end_reporter <- function() {
    cat(paste(rep('-', self$width), collapse=''), '\n')
    n_success <- self$n_tests - self$n_ctx_failed
    success_per <- round( n_success / self$n_tests * 100, 2 )

    test_status <- paste(n_success, '/', self$n_tests,
      ' (', success_per, '%)', sep = '')
    test_status <- ifelse(self$n_ctx_failed == 0,
      colourise(test_status, 'light green'),
      colourise(test_status, 'red')
    )

    cat(test_status, 'tests sucessfully executed.\n' )

    if( self$n_failed > 0 ){
      cat('\nOutput from failed tests:\n\n')

      charrep <- function(char, times) {
        sapply(times, function(i) str_c(rep.int(char, i), collapse = ""))
      }

      type <- ifelse(sapply(self$failures, "[[", "error"), "Error", "Failure")
      tests <- sapply(self$failures, "[[", "test")
      header <- str_c(type, ": ", tests, " ")
      linewidth <- ifelse(nchar(header) > getOption("width"),
        0, getOption("width") - nchar(header))
      line <- charrep("-", linewidth )

      message <- sapply(self$failures, "[[", "message")

      cat(str_c(
        colourise(header, "red"), line, "\n",
        message, "\n", collapse = "\n"))

    }
    cat(str_c(rep('=', self$width), collapse=''), '\n\n')
  }

})


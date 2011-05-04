# This file contains functions that help set up and run the tikzDevice through
# test graphs.

do_graphics_test <- function(short_name, description, graph_code,
  uses_xetex = FALSE, graph_options = NULL, skip_if = NULL, ...) {

  context(description)

  if (str_length(Sys.getenv('R_TESTS')) != 0){
    # `R CMD check` is running. Skip test and return so our graphics testsuite
    # does not slow down the CRAN daily checks.
    cat("SKIP")
    return(FALSE)
  }

  if (!is.null(skip_if)) {
    if (skip_if()) {
      cat("SKIP")
      return(FALSE)
    }
  }

  graph_created <- FALSE

  if (!is.null(graph_options)) {
    # If this test uses custom options, make sure the current options are
    # restored after it finishes.
    orig_opts <- options()
    options(graph_options)
    on.exit(options(orig_opts))
  }

  graph_file <- file.path(test_work_dir, str_c(short_name,'.tex'))

  test_that('Graph is created cleanly',{

    expect_that(
      create_graph(graph_code, graph_file, uses_xetex),
      runs_cleanly()
    )

  })

  test_that('Graph compiles cleanly',{

    expect_that(graph_created <<- compile_graph(graph_file, uses_xetex), runs_cleanly())

  })

  test_that('Output regression check',{

    # Uses the `compare` utility in imagemagick/graphicsmagick to diff the
    # generated graph against a "standard". If there are any differences, we
    # changed the code in a way that broke the behavior of the TikzDevice.
    # This test always "passes" as the real result is the number of pixels that
    # were found to be different between the test graph and the standard graph.
    # Such a result must be interpreted by a human.
    expect_that(compare_graph(short_name), is_true())

  })


  return( graph_created )

}

create_graph <- function(graph_code, graph_file, uses_xetex){

    engine = ifelse(uses_xetex, 'xetex', 'pdftex')

    tikz(file = graph_file, standAlone = TRUE, engine = engine)
    on.exit(dev.off())

    eval(graph_code)

    invisible()

}

compile_graph <- function(graph_file, uses_xetex){
  # Have to compile in the same directory as the .tex file so that things like
  # raster images can be found.
  oldwd <- getwd()
  setwd(test_work_dir); on.exit(setwd(oldwd))

  tex_cmd <- ifelse(uses_xetex, getOption('tikzXelatex'), getOption('tikzLatex'))
  silence <- system(paste(shQuote(tex_cmd), '-interaction=batchmode',
    '-output-directory', test_work_dir,
    graph_file ), intern = TRUE)

  output_pdf = sub('tex$', 'pdf', graph_file)
  if ( file.exists(output_pdf) ) {
    file.rename(output_pdf, file.path(test_output_dir, basename(output_pdf)))
    graph_created <- TRUE
  } else {
    graph_created <- FALSE
  }

  return( graph_created )

}

compare_graph <- function(graph_name){

  if ( is.null(compare_cmd) ) {
    testthat:::test_reporter()$vis_result('SKIP')
    return(TRUE)
  }

  test_output <- file.path(test_output_dir, str_c(graph_name, '.pdf'))
  standard_graph <- file.path(test_standard_dir, str_c(graph_name, '.pdf'))

  if ( !file.exists(test_output) || !file.exists(standard_graph) ) {
    testthat:::test_reporter()$vis_result('SKIP')
    return(TRUE)
  }


  # Normalize and quote some paths in case we are running on Windows
  compare_output <- file.path(test_work_dir, str_c(graph_name, '_diff.png'))
  command_line <- paste(
    shQuote(compare_cmd), '-density 300', '-metric AE',
    shQuote(test_output), shQuote(standard_graph), shQuote(compare_output),
    "2>&1 | awk '{metric=$NF};END{print metric}'"
  )

  result <- as.double(system(paste(
    # Force the command to be executed through bash
    'bash -c ', shQuote(command_line)),
    intern = TRUE, ignore.stderr = TRUE))

  testthat:::test_reporter()$vis_result(result)

  return(TRUE)

}


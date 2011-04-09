do_graphics_test <- function(short_name, description, graph_code,
  uses_xetex = FALSE, graph_options = NULL, skip_if = NULL){

  context(description)

  if (str_length(Sys.getenv('R_TESTS')) != 0){
    # `R CMD check` is running. Skip test and return so our graphics testsuite
    # does not slow down the CRAN daily checks.
    cat("SKIP")
    return(invisible())
  }

  if (!is.null(skip_if)) {
    if (skip_if()) {
      cat("SKIP")
      return(invisible())
    }
  }

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

    expect_that(compile_graph(graph_file, uses_xetex), runs_cleanly())

  })

  test_that('Output passes regression check',{

    # TODO:
    # For future implementation.
    #
    # Use the `compare` utility in imagemagick/graphicsmagick to diff the
    # generated graph against a "standard". If there are any differences, we
    # changed the code in a way that broke the behavior of the TikzDevice.
    expect_that(TRUE, is_true())

  })

  # Don't return anything
  invisible()

}

create_graph <- function(graph_code, graph_file, uses_xetex){

    engine = ifelse(uses_xetex, 'xetex', 'pdftex')

    tikz(file = graph_file, standAlone = TRUE, engine = engine)
    on.exit(dev.off())

    eval(graph_code)

    invisible()

}

compile_graph <- function(graph_file, uses_xetex){

  tex_cmd <- ifelse(uses_xetex, getOption('tikzXelatex'), getOption('tikzLatex'))
  silence <- system(paste(tex_cmd, '-interaction=batchmode',
    '-output-directory', test_work_dir,
    graph_file ), intern = TRUE)

  output_pdf = sub('tex$', 'pdf', graph_file)
  file.rename(output_pdf, file.path(test_output_dir, basename(output_pdf)))

  invisible()

}

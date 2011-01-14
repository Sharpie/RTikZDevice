do_graphics_test <- function(short_name, description, graph_code){

  context(description)

  graph_file <- file.path(test_work_dir, str_c(short_name,'.tex'))

  test_that('Graph is created cleanly',{

    expect_that(
      create_graph(graph_code, graph_file),
      runs_cleanly()
    )

  })

  test_that('Graph compiles cleanly',{

    expect_that(compile_graph(graph_file), runs_cleanly())

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

create_graph <- function(graph_code, graph_file){

    tikz(file = graph_file, standAlone = TRUE)
    on.exit(dev.off())

    eval(graph_code)

    invisible()

}

compile_graph <- function(graph_file){

  tex_cmd <- options('tikzLatex')
  silence <- system(paste(tex_cmd, '-interaction=batchmode',
    '-output-directory', test_work_dir,
    graph_file ), intern = TRUE)

  output_pdf = sub('tex$', 'pdf', graph_file)
  file.rename(output_pdf, file.path(test_output_dir, basename(output_pdf)))

  invisible()

}

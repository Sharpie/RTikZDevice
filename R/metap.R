#' @export
metapost <-
function (file = "./Rplots.tex", width = 7, height = 7,
  bg="transparent", fg="black", pointsize = 10, standAlone = FALSE,
  bareBones = FALSE, console = FALSE, sanitize = FALSE,
  engine = getOption("tikzDefaultEngine"),
  documentDeclaration = getOption("tikzDocumentDeclaration"),
  packages,
  footer = getOption("tikzFooter")
){

  tryCatch({
    # Ok, this sucks. We copied the function signature of pdf() and got `file`
    # as an argument to our function. We should have copied png() and used
    # `filename`.

    # file_path_as_absolute can give us the absolute path to the output
    # file---but it has to exist first. So, we use file() to "touch" the
    # path.
    touch_file <- suppressWarnings(file(file, 'w'))
    close(touch_file)

    file <- tools::file_path_as_absolute(file)
  },
  error = function(e) {
    stop(simpleError(paste(
      "Cannot create:\n\t", file,
      "\nBecause the directory does not exist or is not writable."
    )))
  })

  # Determine which TeX engine is being used.
  switch(engine,
    pdftex = {
      engine <- 1L # In the C routines, a integer value of 1 means pdftex
      if (missing(packages)) {packages <- getOption('tikzLatexPackages')}
    },
    xetex = {
      engine <- 2L
      if (missing(packages)) {packages <- getOption('tikzXelatexPackages')}
    },
    {#ELSE
      stop('Unsupported TeX engine: ', engine,
        '\nAvailable choices are:\n',
        '\tpdftex\n',
        '\txetex\n')
    })

  # Ensure the standAlone option will trump the bareBones option.
  if( standAlone ) { bareBones = FALSE }
  if( footer != getOption("tikzFooter") && !standAlone)
    warning( "Footers are ignored when standAlone is set to FALSE" )

  # Extract the document pointsize from the documentDeclaration
  baseSize <- getDocumentPointsize( documentDeclaration )

  # If a pointsize was not found, we use the value of the pointsize
  # argument.
  if( is.na( baseSize ) ){ baseSize <- pointsize }

  # Collapse the character vectors into a single string
  # which is easier to work with in C
  documentDeclaration <-
    paste( paste(documentDeclaration, collapse='\n'), collapse='\n')
  packages <- paste( paste( packages, collapse='\n'), collapse='\n')
  footer <- paste( paste( footer,collapse='\n'), collapse='\n')

  .External('metapDevice', file, width, height, bg, fg, baseSize,
    standAlone, bareBones, documentDeclaration, packages, footer, console,
    sanitize, engine,
    PACKAGE='tikzDevice')

  invisible()

}

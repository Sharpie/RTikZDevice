# Define a set of classes and methods that can be used to locate TeX compilers
# on the user's system. Currently, only used in `.onLoad`, but could be moved
# to a more appropriate location later.
PATH <-
function(origin)
{
  structure(Sys.which(origin), origin = origin, class = 'PATH')
}

OPTION <-
function(origin)
{
  structure(ifelse(is.null(getOption(origin)), '', Sys.which(getOption(origin))),
    origin = origin, class = 'OPTION')
}

ENV_VAR <-
function(origin)
{
  structure(ifelse(is.null(Sys.getenv(origin)), '', Sys.which(Sys.getenv(origin))),
    origin = origin, class = 'ENV_VAR')
}


isExecutable <-
function(executable)
{
  path <- as.character(executable)

  # file.access doesn't like non-zero lengths.
  if ( nchar(path) == 0 ) { return(FALSE) }

  if ( file.access(path, 1) == 0 ) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

formatExecutable <-
function(executable)
{
  desc <- 'path:\n\t'
  desc <- paste(desc, as.character(executable), sep = '')
  desc <- paste(desc, "\nObtained from ", sep = '')
  desc <- paste(desc, format(executable), '\n', sep = '')

  return(desc)
}

# S3 methods have to be exported to the NAMESPACE in order to be effective
# during .onLoad...

#' @S3method format PATH
format.PATH <- function(x, ...) { sprintf('the PATH using the command: %s', attr(x, 'origin')) }
#' @S3method format OPTION
format.OPTION <- function(x, ...) { sprintf('the global option: %s', attr(x, 'origin')) }
#' @S3method format ENV_VAR
format.ENV_VAR <- function(x, ...) { sprintf('the environment variable: %s', attr(x, 'origin')) }


.onLoad <-
function(libname, pkgname) {

  # Perform a search for an executable LaTeX program.
  # R environment variables and options will be checked
  # followed by a check to see if pdflatex is executable
  # on the path. If LaTeX can not be found, loading of
  # this package will be aborted as a LaTeX compiler is
  # required in order to determine string metrics.
  # Ensure package options are set

  setTikzDefaults( overwrite = FALSE )

  versionInfo <- read.dcf(file.path( libname, pkgname, "DESCRIPTION"))

  versionInfo <- gettextf( "%s: %s (v%s)", versionInfo[, "Package"], versionInfo[, "Title"],
    getTikzDeviceVersion() )

  versionInfo <- c( paste(strwrap(versionInfo),collapse='\n'), "Checking for a LaTeX compiler...\n")

  packageStartupMessage( paste(versionInfo,collapse='\n') )

  foundLatex <- FALSE
  foundXelatex <- FALSE
  checked <- c()
  checkedXelatex <- c()

  latexTest <- function( pathToTeX, pathDesc ){

    Sys.setenv("PATH" = Sys.getenv("PATH"))
    latexPath <<- Sys.which( paste( pathToTeX ) )

    # Check to see if the path leads to an executible
    if( file.access(latexPath[1], 1) == 0 ){
      options( tikzLatex=latexPath )
      options( tikzLatexDefault=latexPath )
      foundLatex <<- TRUE
      checked <<- paste( "\nA working LaTeX compiler was found by checking:\n\t",pathDesc,
        "\n\nGlobal option tikzLatex set to:\n\t",latexPath,'\n',sep='' )
      return( TRUE )
    }else{
      checked[ length(checked)+1 ] <<- pathDesc
      return( FALSE )
    }

  }

  xelatexTest <- function( pathToTeX, pathDesc ){

      Sys.setenv("PATH" = Sys.getenv("PATH"))
      xelatexPath <<- Sys.which( paste( pathToTeX ) )

      # Check to see if the path leads to an executible
      if( file.access(xelatexPath[1], 1) == 0 ){
        options( tikzXelatex = xelatexPath )
        options( tikzXelatexDefault = xelatexPath )
        foundXelatex <<- TRUE
        checkedXelatex <<- paste( "\nA working XeLaTeX compiler was found by checking:\n\t",pathDesc,
          "\n\nGlobal option tikzXelatex set to:\n\t",xelatexPath,'\n',sep='' )
        return( TRUE )
      }else{
        checkedXelatex[ length(checked)+1 ] <<- pathDesc
        return( FALSE )
      }

    }


  testLocs <- c( ifelse( is.null(getOption('tikzLatex')), "", getOption('tikzLatex') ),
    Sys.getenv("R_LATEXCMD"),
    Sys.getenv("R_PDFLATEXCMD"),
    ifelse( is.null(getOption('latexcmd')), "NULL", getOption('latexcmd') ),
    'pdflatex',
    'latex')


  testDescs <- c( "A pre-existing value of the global option tikzLatex",
    "The R environment variable R_LATEXCMD",
    "The R environment variable R_PDFLATEXCMD",
    "The global option latexcmd",
    "The PATH using the command pdflatex",
    "The PATH using the command latex")


    # Only check for xelatex in the options and the PATH variable since there
    # no environment variables for xelatex
  xelatexTestLocs <- c(ifelse( is.null(getOption('tikzXelatex')), "", getOption('tikzXelatex') ),
    "xelatex")

  xelatexTestDescs <- c("A pre-existing value of the global option tikzXelatex",
    "The PATH using the command xelatex")

  # Non-Windows users are likely to use some derivative of TeX Live.  This next
  # test primarily covers the fact that R.app does not include `/usr/texbin` on
  # the search path on OS X.
  if( .Platform[['OS.type']] == 'unix' ){

    testLocs <- c( testLocs, '/usr/texbin/pdflatex' )
    testDescs <- c( testDescs, 'The directory /usr/texbin for `pdflatex`' ) 
    xelatexTestLocs <- c( xelatexTestLocs, '/usr/texbin/xelatex' )
    xelatexTestDescs <- c( xelatexTestDescs, 'The directory /usr/texbin for `xelatex`' )

  }

  for( i in 1:length(testLocs) ){
    if( latexTest( testLocs[i], testDescs[i] ) ){ break }
  }

  for( i in 1:length(xelatexTestLocs) ){
    if( xelatexTest(xelatexTestLocs[i], xelatexTestDescs[i]) ){ break }
  }


  if( foundLatex ){
    packageStartupMessage( checked )
    p <- pipe( paste( latexPath, '--version' ) )
    packageStartupMessage( paste( utils:::head(readLines( p ), 2), '\n', sep='' ) , sep='\n' )
    close(p)
  }else{
    stop("\n\nAn appropriate LaTeX compiler could not be found.\n",
      "Access to LaTeX is required in order for the TikZ device\n",
      "to produce output.\n\n",
      "The following places were tested for a valid LaTeX compiler:\n\n\t",
      paste( checked,collapse='\n\t'),
      "\n\nIf you have a working LaTeX compiler, try one of the\n",
      "following solutions:",

      "\n\n\tSet the path to your compiler as the value of either latexcmd or",
      "\n\ttikzLatex in .Rprofile using options().",

      "\n\n\tSet the path to your compiler as the value of either R_LATEXCMD or",
      "\n\tR_PDFLATEXCMD in .Renviron.",

      "\n\n\tEnsure the folder containing your compiler is included in PATH.\n"
    )
  }

  if( foundXelatex ){
      packageStartupMessage( checkedXelatex )
      p <- pipe( paste( xelatexPath, '--version' ) )
      packageStartupMessage( paste( utils:::head(readLines( p ), 2), '\n', sep='' ) , sep='\n' )
      close(p)
    }else{
      packageStartupMessage(
        "\n\nATTENTION: An appropriate XeLaTeX compiler could not be found.\n",
        "Access to the `xelatex' command is required for the TikZ device \n",
        "to produce output containing multibyte UTF-8 characters.\n\n",
        "The following places were tested for a valid XeLaTeX compiler:\n\n\t",
        paste( checkedXelatex,collapse='\n\t')
      )
    }

    # Its not nice to leave things in the user's global environment
  rm(latexPath, xelatexPath, envir=.GlobalEnv)
}

# Any variables defined in here will be hidden
# from normal users.
.tikzInternal <- new.env()

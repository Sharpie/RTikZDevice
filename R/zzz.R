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

  # Print out version banner
  pkgInfo <- read.dcf(file.path( libname, pkgname, "DESCRIPTION"))
  packageStartupMessage(sprintf("%s: %s (v%s)",
    pkgInfo[, "Package"], pkgInfo[, "Title"], getTikzDeviceVersion()))

  # Ensure options are set.
  setTikzDefaults( overwrite = FALSE )

  # Perform a search for executable TeX compilers. R options, environment
  # variables and common paths will be checked. If PdfLaTeX can not be found,
  # loading of this package will be aborted as a LaTeX compiler is required in
  # order to determine string metrics. Other compilers, such as XeLaTeX, are
  # optional.
  foundLatex <- FALSE
  foundXelatex <- FALSE

  latexLocs <- list(
    OPTION('tikzLatex'),
    ENV_VAR('R_LATEXCMD'),
    ENV_VAR('R_PDFLATEXCMD'),
    OPTION('latexcmd'),
    PATH('pdflatex'),
    PATH('latex')
  )

  # Only check for xelatex in the options and the PATH variable since there are
  # no environment variables for xelatex.
  xelatexLocs <- list(
    OPTION('tikzXelatex'),
    PATH('xelatex')
  )

  # Non-Windows users are likely to use some derivative of TeX Live. This next
  # test primarily covers the fact that R.app does not include `/usr/texbin` on
  # the search path on OS X.
  if( .Platform[['OS.type']] == 'unix' ){
    # Using explicit list insertion because the `c` function drops attributes
    # and thus destroys S3 objects. Writing 3 new class methods for PATH,
    # OBJECT and ENV_VAR is just overkill.
    latexLocs[[length(latexLocs) + 1]] <- PATH('/usr/texbin/pdflatex')
    xelatexLocs[[length(xelatexLocs) + 1]] <- PATH('/usr/texbin/xelatex')
  }

  for ( latexPath in latexLocs ) {
    if ( isExecutable(latexPath) ) {
      foundLatex <- TRUE
      options(tikzLatex = as.character(latexPath), tikzLatexDefault = as.character(latexPath))
      break
    }
  }

  for( xelatexPath in xelatexLocs ) {
    if( isExecutable(xelatexPath) ) {
      foundXelatex <- TRUE
      options(tikzXelatex = as.character(xelatexPath), tikzXelatexDefault = as.character(xelatexPath))
      break
    }
  }

  if ( foundLatex ) {
    packageStartupMessage(paste('  LaTeX found in', format(latexPath)))
  } else {
    stop("\n\nAn appropriate LaTeX compiler could not be found.\n",
      "Access to LaTeX is required in order for the TikZ device\n",
      "to produce output.\n\n",
      "The following places were tested for a valid LaTeX compiler:\n\n\t",
      paste( sapply(latexLocs, format),collapse='\n\t'),
      "\n\nIf you have a working LaTeX compiler, try one of the\n",
      "following solutions:",

      "\n\n\tSet the path to your compiler as the value of either latexcmd or",
      "\n\ttikzLatex in .Rprofile using options().",

      "\n\n\tSet the path to your compiler as the value of either R_LATEXCMD or",
      "\n\tR_PDFLATEXCMD in .Renviron.",

      "\n\n\tEnsure the folder containing your compiler is included in PATH.\n"
    )
  }

  if ( foundXelatex ) {
    packageStartupMessage(paste('  XeLaTeX found in', format(xelatexPath)))
  }

}

# Any variables defined in here will be hidden
# from normal users.
.tikzInternal <- new.env()

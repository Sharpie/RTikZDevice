.onLoad <-
function(libname, pkgname) {

	# Perform a search for an executable LaTeX program.
	# R environment variables and options will be checked
	# followed by a check to see if pdflatex is executable
	# on the path. If LaTeX can not be found, loading of
	# this package will be aborted as a LaTeX compiler is
	# required in order to determine string metrics.

	if( !require( filehash, quietly=TRUE ) ){ 
		stop("tikzDevice requires the filehash package to be available.") 
	}
	
	# Set Header and Footer options
	options( tikzDocumentDeclarationDefault = "\\documentclass[10pt]{article}\n" )
	options( tikzDocumentDeclaration = getOption("tikzDocumentDeclarationDefault") )
	options( tikzLatexPackagesDefault = c(
		"\\usepackage{tikz}\n",
		"\\usepackage[active,tightpage,psfixbb]{preview}\n",
		"\\PreviewEnvironment{pgfpicture}\n",
		"\\setlength\\PreviewBorder{0pt}\n") )
	options( tikzLatexPackages = getOption("tikzLatexPackagesDefault"))
	options( tikzFooterDefault = c( "\\end{document}\n" ) )
	options( tikzFooter = getOption('tikzFooterDefault') )
	options( tikzMetricPackages = c(
		"\\usepackage[utf8]{inputenc}\n",
		# The fontenc package is very important here! 
		# R assumes the output device is uing T1 encoding.
		# LaTeX defaults to OT1. This package makes the
		# symbol codes consistant for both systems.
		"\\usepackage[T1]{fontenc}\n",
		"\\usetikzlibrary{calc}\n"))
	options( tikzSanitizeCharacters = c('%','$','}','{','^') )
	options( tikzReplacementCharacters = c('\\%','\\$','\\}','\\{','\\^{}'))
	

	versionInfo <- read.dcf(file.path( libname, pkgname, "DESCRIPTION"))

	versionInfo <- gettextf("%s: %s (v%s)", versionInfo[, "Package"], versionInfo[, "Title"],
		as.character(versionInfo[, "Version"]))

	versionInfo <- c( paste(strwrap(versionInfo),collapse='\n'), "Checking for a LaTeX compiler...\n")

	packageStartupMessage( paste(versionInfo,collapse='\n') )

	foundLatex <- FALSE
	checked <- c()

	latexTest <- function( pathToTeX, pathDesc ){
		
		Sys.setenv("PATH" = Sys.getenv("PATH"))
		latexPath <<- Sys.which( paste( pathToTeX ) )

		if( latexPath[1] != "" ){
			options( tikzLatex=latexPath )
			options( tikzLatexDefault=latexPath )
			foundLatex <<- TRUE
			checked <<- paste( "\nA working LaTeX compiler was found in:\n\t",pathDesc,
				"\n\nGlobal option tikzLatex set to:\n\t",latexPath,'\n',sep='' )
			return( TRUE )
		}else{
			checked[ length(checked)+1 ] <<- pathDesc
			return( FALSE )
		}

	}


	testLocs <- c( ifelse( is.null(getOption('tikzLatex')), "", getOption('tikzLatex') ),
		Sys.getenv("R_LATEXCMD"), 
		Sys.getenv("R_PDFLATEXCMD"), 
		ifelse( is.null(getOption('latexcmd')), "NULL", getOption('latexcmd') ),
		'latex',
		'pdflatex')

	testDescs <- c( "A pre-existing value of the global option tikzLatex",
		"The R environment variable R_LATEXCMD", 
		"The R environment variable R_PDFLATEXCMD", 
		"The global option latexcmd",
		"The PATH using the command latex", 
		"The PATH using the command pdflatex" )

	for( i in 1:length(testLocs) ){
		if( latexTest( testLocs[i], testDescs[i] ) ){ break }
	}

	if( foundLatex ){
		packageStartupMessage( checked )
		p <- pipe( paste( latexPath, '--version' ) )
		packageStartupMessage( paste( readLines( p ), '\n', sep='' ) , sep='\n' )
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

  library.dynam(pkgname, pkgname, libname)
}

# Any variables defined in here will be hidden
# from normal users.
.tikzInternal <- new.env()

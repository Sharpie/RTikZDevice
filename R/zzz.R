.onLoad<-
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
	options( tikzDocumentDeclarationDefault = "\\documentclass{article}" )
	options( tikzDocumentDeclaration = getOption("tikzDocumentDeclarationDefault") )
	options( tikzLatexPackagesDefault = c(
		"\\usepackage{tikz}",
		"\\usepackage[active,tightpage]{preview}",
		"\\PreviewEnvironment{pgfpicture}",
		"\\setlength\\PreviewBorder{0pt}") )
	options( tikzLatexPackages = getOption("tikzLatexPackagesDefault"))
	options( tikzFooterDefault = c( "\\end{document}" ) )
	options( tikzFooter = getOption('tikzFooterDefault') )
	

	versionInfo <- read.dcf(file.path( libname, pkgname, "DESCRIPTION"))

	versionInfo <- gettextf("%s: %s (v%s)", versionInfo[, "Package"], versionInfo[, "Title"],
		as.character(versionInfo[, "Version"]))

	versionInfo <- c( paste(strwrap(versionInfo),collapse='\n'), "Checking for a LaTeX compiler...\n")

	packageStartupMessage( paste(versionInfo,collapse='\n') )

	foundLatex <- FALSE
	checked <- c()

	latexTest <- function( pathToTeX, pathDesc ){

		latexCheck <- suppressWarnings(
			system( paste( pathToTeX,'--version' ), ignore.stderr=T) )

		if( latexCheck == 0 ){
			options( tikzLatex=pathToTeX )
			foundLatex <<- TRUE
			checked <<- paste( "\nA working LaTeX compiler was found in:\n\t",pathDesc,
				"\n\nGlobal option tikzLatex set to:\n\t",pathToTeX,'\n',sep='' )
			return( TRUE )
		}else{
			checked[ length(checked)+1 ] <<- pathDesc
			return( FALSE )
		}

	}


	testLocs <- c( ifelse( is.null(getOption('tikzLatex')), "NULL", getOption('tikzLatex') ),
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
		message( checked )
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

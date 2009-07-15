getLatexStrWidth <-
function( texString ){

	# Reimplementation of the origonal C function since
	# the C function causes all kings of gibberish to
	# hit the screen when called under Windows and
	# Linux. 
	#
	#	On both platforms this causes the whole process 
	# of calling LaTeX in order to obtain string width 
	# to take even longer.
	#
	# Oh. And Windows can't nut up and make it through
	# the process so it just shits it's self and dies.

	# Create the TeX file in a temporary directory so
	# it doesn't clutter anything.
	texDir <- tempdir()
	texLog <- file.path( texDir,'tikzStringWidthCalc.log' )
	texFile <- file.path( texDir,'tikzStringWidthCalc.tex' )

	# Open the TeX file for writing.
	texIn <- file( texFile, 'w')

	writeLines("\\documentclass{article}", texIn)
	writeLines("\\usepackage[utf8]{inputenc}", texIn)
	writeLines("\\usepackage[T1]{fontenc}", texIn)
	writeLines("\\batchmode", texIn)

	# This is here as a reminder, add an argument 
	# that allows the user to specify the font packages
	writeLines("%%... other font setup stuff", texIn)

	writeLines(paste("\\sbox0{",texString,"}",sep=''), texIn)
	writeLines("\\typeout{width=\\the\\wd0}", texIn)

	# Stop before creating output
	writeLines("\\makeatletter", texIn)
	writeLines("\\@@end", texIn)
	
	# Close the LaTeX file, ready to compile 
	close( texIn )

	# Recover the latex command.
	latexCmd <- getOption('tikzLatex')

	# Append the batchmode flag to increase LaTeX 
	# efficiency.
	latexCmd <- paste( latexCmd, '-interaction=batchmode',
		'-output-directory', texDir, texFile)

	# Run that shit.
	silence <- system( latexCmd, intern=T, ignore.stderr=T)

	# Open the log file.
	texOut <- file( texLog, 'r' )

	# Read the contents of the log file.
	logContents <- readLines( texOut )
	close( texOut )

	# Find the line containing "width="
	# Let's guess how long it will take before
	# this line isn't unique in the logfile...
	match <- logContents[ grep('width=', logContents) ]

	# Remove all parts of the string besides the
	# number.
	match <- gsub('[=A-Za-z]','',match)

	# Yay! String width!
	return( as.double( match ) )

}

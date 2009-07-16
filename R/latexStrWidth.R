getLatexStrWidth <-
function( texString ){

	# Check to see if we have a width stored in
	# our dictionary for this string.
	width <- queryDictionaryForWidth( texString )

	if( width > 0 ){

		# Positive string width means there was a
		# cached value available. Yay! We're done.
		return( width )

	}else{

		# Bummer. No width on record for this string.
		# Call LaTeX and get one.
		width <- latexParseStrForWidth( texString )

		# Store the width in the dictionary so we don't
		# have to do this again.
		storeWidthInDictionary( texString, width )

		# Return the width.
		return( width )

	}
}

latexParseStrForWidth <-
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

latexParseCharForMetrics <-
function( charCode ){
	
	# Basically this function is largely a duplication of the 
	# string width function- it's mostly a proof of concept.
	# If it works, the operations herin should be generalized
	# so that both functions may be combined.
	#
	# Also, it would be nice to have the capability to load
	# arbitrary pacakges and even things such as \newcommand
	# during the exection of these runs.

	texDir <- tempdir()
	texLog <- file.path( texDir,'tikzStringWidthCalc.log' )
	texFile <- file.path( texDir,'tikzStringWidthCalc.tex' )

	# Open the TeX file for writing.
	texIn <- file( texFile, 'w')

	writeLines("\\documentclass{article}", texIn)
	writeLines("\\usepackage[utf8]{inputenc}", texIn)
	# The fontenc package is very important here! 
	# R assumes the output device is uing T1 encoding.
	# LaTeX defaults to OT1. This package makes the
	# symbol codes consistant for both systems.
	writeLines("\\usepackage[T1]{fontenc}", texIn)

	# We will use the TikZ pack to determine our
	# metrics by setting the character in question
	# inside a TikZ node and then extracting various
	# widths from the node. The TikZ calc library
	# will be used to calculate distances.
	writeLines("\\usepackage{tikz}", texIn)
	writeLines("\\usetikzlibrary{calc}", texIn)

	writeLines("\\batchmode", texIn)

	# This is here as a reminder, add an argument 
	# that allows the user to specify the font packages
	writeLines("%%... other font setup stuff", texIn)

	# Begin a tikz picture.
	writeLines("\\begin{tikzpicture}", texIn)

	# Set the character in a named node. Since R passes
	# an integer that corresponds to a character in 
 	# a table, rather than the character it's self, we
	# use the \char macro to extract the ASCII character
	# corresponding to the given integer.

	# Hopefully UTF8 will be simple like this...
	writeLines(paste(
		"\\node[inner sep=0pt, outer sep=0pt] (Char) {\\char",
		charCode,
		"};", sep=''), 
	texIn)

	# Calculate the ascent and print it to the log.
	writeLines("\\path let \\p1 = ($(Char.north) - (Char.base)$), 
		\\n1 = {veclen(\\x1,\\y1)} in (Char.north) -- (Char.base)
		node{ \\typeout{tikzCharAscent=\\n1} };", texIn)

	# Calculate the descent and print it to the log.
	writeLines("\\path let \\p1 = ($(Char.base) - (Char.south)$), 
		\\n1 = {veclen(\\x1,\\y1)} in (Char.base) -- (Char.south)
		node{ \\typeout{tikzCharDescent=\\n1} };", texIn)
 
	# Calculate the width and print it to the log.
	writeLines("\\path let \\p1 = ($(Char.east) - (Char.west)$), 
		\\n1 = {veclen(\\x1,\\y1)} in (Char.east) -- (Char.west)
		node{ \\typeout{tikzCharWidth=\\n1} };", texIn)

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

	# Recover ascent by finding the line containing
	# tikzCharAscent in the logfile.
	match <- logContents[ grep('tikzCharAscent=', logContents) ]
	# Remove all parts of the string besides the
	# number.
	ascent <- gsub('[=A-Za-z]','',match)

	# Do the same for descent and width.
	match <- logContents[ grep('tikzCharDescent=', logContents) ]
	descent <- gsub('[=A-Za-z]','',match)

	match <- logContents[ grep('tikzCharWidth=', logContents) ]
	width <- gsub('[=A-Za-z]','',match)

	# Yay! Character metrics!
	return( as.double( c(ascent,descent,width) ) )

}

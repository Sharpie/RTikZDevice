getLatexStrWidth <-
function( texString, cex = 1, face= 1){

	# Create an object that contains the string and it's
	# properties.
	TeXMetrics <- list( type='string', scale=cex, face=face, value=texString,
	 	documentDeclaration = getOption("tikzDocumentDeclaration"),
		packages = getOption("tikzLatexPackages"))

	# Check to see if we have a width stored in
	# our dictionary for this string.
	width <- queryMetricsDictionary( TeXMetrics )

	if( width > 0 ){

		# Positive string width means there was a
		# cached value available. Yay! We're done.
		return( width )

	}else{

		# Bummer. No width on record for this string.
		# Call LaTeX and get one.
		width <- getMetricsFromLatex( TeXMetrics )

		# Store the width in the dictionary so we don't
		# have to do this again.
		storeMetricsInDictionary( TeXMetrics, width )

		# Return the width.
		return( width )

	}
}

getLatexCharMetrics <-
function( charCode, cex = 1, face = 1 ){

	# This function is pretty much an exact duplicate of
	# getLatexStrWidth, these two functions should be 
	# generalized and combined.

	# We must be given a valid integer character code.
	if( !(is.numeric(charCode) && charCode > 31 && charCode < 127 ) ){
		warning("Sorry, this function currently only accepts numbers between 32 and 126!")
		return(NULL)
	}

	# Coerce the charCode to integer in case someone was being funny
  # and passed a float.
	charCode <- as.integer( charCode )

	# Create an object that contains the character and it's
	# properties.
	TeXMetrics <- list( type='char', scale=cex, face=face, value=charCode,
		documentDeclaration = getOption("tikzDocumentDeclaration"),
		packages = getOption("tikzLatexPackages"))

	# Check to see if we have metrics stored in
	# our dictionary for this character.
	metrics <- queryMetricsDictionary( TeXMetrics )

	if( all(metrics >= 0) ){

		# The metrics should be a vector of three non negative
		# numbers.
		return( metrics )

	}else{

		# Bummer. No metrics on record for this character.
		# Call LaTeX to obtain them.
		metrics <- getMetricsFromLatex( TeXMetrics )

		# Store the metrics in the dictionary so we don't
		# have to do this again.
		storeMetricsInDictionary( TeXMetrics, metrics )

		return( metrics )

	}
}

getMetricsFromLatex <-
function( TeXMetrics ){
	
	# Reimplementation of the origonal C function since
	# the C function causes all kinds of gibberish to
	# hit the screen when called under Windows and
	# Linux. 
	#
	#	On both platforms this causes the whole process 
	# of calling LaTeX in order to obtain string width 
	# to take even longer.
	#
	# Oh. And Windows couldn't nut up and make it through
	# the C process so it shit it's self and died.


	# Create the TeX file in a temporary directory so
	# it doesn't clutter anything.
	texDir <- tempdir()
	texLog <- file.path( texDir,'tikzStringWidthCalc.log' )
	texFile <- file.path( texDir,'tikzStringWidthCalc.tex' )

	# Open the TeX file for writing.
	texIn <- file( texFile, 'w')

	writeLines(getOption("tikzDocumentDeclaration"), texIn)
	
	# Add extra packages, it wont really matter if the user puts 
	# in duplicate packages or many irrelevant packages since they 
	# mostly wont be used. The packages we do care about are the 
	# font ones. I suppose it is possible that the user could add 
	# some wacky macros that could screw stuff up but lets pretend 
	# that cant happen for now. 
	#
	# Also, we load the user packages first so that we can override 
	# crucial things.
	writeLines(getOption("tikzLatexPackages"), texIn)
	
	writeLines("\\usepackage[utf8]{inputenc}", texIn)
	# The fontenc package is very important here! 
	# R assumes the output device is uing T1 encoding.
	# LaTeX defaults to OT1. This package makes the
	# symbol codes consistant for both systems.
	writeLines("\\usepackage[T1]{fontenc}", texIn)

	# We will use the TikZ pack to determine our
	# metrics by setting the character(s) in question
	# inside a TikZ node and then extracting various
	# widths from the node. The TikZ calc library
	# will be used to calculate the distances.
	writeLines("\\usepackage{tikz}", texIn)
	writeLines("\\usetikzlibrary{calc}", texIn)

	writeLines("\\batchmode", texIn)

	# Begin a tikz picture.
	writeLines("\\begin{tikzpicture}", texIn)

	# Insert the value of cex into the node options.
	nodeOpts <- paste('\\node[inner sep=0pt, outer sep=0pt, scale=',
		TeXMetrics$scale,']', sep='')

	# Create the node contents depending on the type of metrics
	# we are after.

	# First, which font face are we using?
	#
	# From ?par:
	#
	# font
	#
	#		An integer which specifies which font to use for text. If possible, 
	#		device drivers arrange so that 1 corresponds to plain text (the default), 
	#		2 to bold face, 3 to italic and 4 to bold italic. Also, font 5 is expected 
	#		to be the symbol font, in Adobe symbol encoding. On some devices font families 
	#		can be selected by family to choose different sets of 5 fonts.

	nodeContent <- ''
	switch( TeXMetrics$face,

		normal = {
			# We do nothing for font face 1, normal font.
		},
		
		bold = {
			# Using bold, we set in bold *series*
			nodeContent <- '\\bfseries'
		},

		italic = {
			# Using italic, we set in the italic *shape*
			nodeContent <- '\\itshape'
		},

		bolditalic = {
			# With bold italic we set in bold *series* with italic *shape* 	
			nodeContent <- '\\bfseries\\itshape'
		},
	
		symbol = {
			# We are currently ignoring R's symbol fonts.
		}
	
	) # End output font face switch.
		

	# Now for the content. For string width we set the whole string in
	# the node. For character metrics we have an integer corresponding
	# to a posistion in the ASCII character table- so we use the LaTeX
	# \char command to translate it to an actual character.
	switch( TeXMetrics$type,
		
		string = {
			
			nodeContent <- paste( nodeContent,TeXMetrics$value )

		},

		char = {

			nodeContent <- paste( nodeContent,'\\char',TeXMetrics$value, sep='' )

		}

	)# End switch for  metric type.

	writeLines( paste( nodeOpts, ' (TeX) {', nodeContent, "};", sep=''), texIn)

	# We calculate width for both characters and strings.
	writeLines("\\path let \\p1 = ($(TeX.east) - (TeX.west)$), 
		\\n1 = {veclen(\\x1,\\y1)} in (TeX.east) -- (TeX.west)
		node{ \\typeout{tikzTeXWidth=\\n1} };", texIn)

	# We only want ascent and descent for characters.
	if( TeXMetrics$type == 'char' ){

		# Calculate the ascent and print it to the log.
		writeLines("\\path let \\p1 = ($(TeX.north) - (TeX.base)$), 
			\\n1 = {veclen(\\x1,\\y1)} in (TeX.north) -- (TeX.base)
			node{ \\typeout{tikzTeXAscent=\\n1} };", texIn)

		# Calculate the descent and print it to the log.
		writeLines("\\path let \\p1 = ($(TeX.base) - (TeX.south)$), 
			\\n1 = {veclen(\\x1,\\y1)} in (TeX.base) -- (TeX.south)
			node{ \\typeout{tikzTeXDescent=\\n1} };", texIn)

	}

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

	# Recover width by finding the line containing
	# tikzTeXWidth in the logfile.
	match <- logContents[ grep('tikzTeXWidth=', logContents) ]

	# Remove all parts of the string besides the
	# number.
	width <- gsub('[=A-Za-z]','',match)

	# If we're dealing with a string, we're done.
	if( TeXMetrics$type == 'string' ){

		return( as.double( width ) )

	}else{

		# For a character, we want ascent and descent too.
		match <- logContents[ grep('tikzTeXAscent=', logContents) ]
		ascent <- gsub('[=A-Za-z]','',match)

		match <- logContents[ grep('tikzTeXDescent=', logContents) ]
		descent <- gsub('[=A-Za-z]','',match)

		return( as.double( c(ascent,descent,width) ) )

	}

}

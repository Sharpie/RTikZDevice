#' Obtain the Width of an Arbitrary LaTeX String
#' This function calculates the width of a string as it would appear after
#' being compiled by LaTeX.
#'
#' This function is used internally by the \code{tikz} device for proper string
#' placement in graphics.  This function first checks to see if the width
#' exists in a global or temporary string width dictionary (as define in
#' \code{options('tikzMetricsDictionary')}) and if so will pull the width from
#' there. If the dictionary does not exist then a temporary one for the current
#' R session is created and the string width is calculated via a \code{system}
#' call to latex. The calling of latex to calculate a string width is quit
#' expensive and so we strongly recommend setting
#' \code{options('tikzMetricsDictionary') <- /path/to/dictionary} to create a
#' global dictionary.
#'
#' @param texString An arbitrary string for which the width is to be
#'   calculated.  May contain LaTeX markup.
#' @param cex a real number that specifies a scaling factor that is to be
#'   applied to device output.
#' @param face an integer in the range [1-5] that specifies the font face to
#'   use. See \link{par} for details.
#'
#' @return \item{width}{The width of \code{texString} in point size.}
#'
#' @note \pkg{\link{tikzDevice}} tries very hard when it is loaded to find a
#'   working \command{latex} or \command{pdflatex} command.  If it is
#'   successful the command is set in \code{options('tikzLatex')}, otherwise
#'   this function will fail.
#'
#' @author Charlie Sharpsteen \email{source@@sharpsteen.net} and Cameron
#'   Bracken \email{cameron.bracken@@gmail.com}
#'
#' @seealso \code{\link{tikz}}, \code{\link{getLatexCharMetrics}}
#' @keywords character
#'
#' @examples
#'
#' 	getLatexStrWidth('{\\\\tiny Hello \\\\LaTeX!}')
#'
#' @export
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


#' Obtain LaTeX Font Metrics for Characters
#' This function is used to retrieve the ascent, decent and width of a
#' character glyph as it would appear in output typeset by LaTeX.
#'
#' \code{getLatexCharMetrics} first checks to see if metrics have allready been
#' calculated for the given character using the given values of \code{cex} and
#' \code{face}. If so, cached values are returned. If no cached values exists,
#' the LaTeX compiler specified by \code{options( tikzLatex )} is invoked in
#' order to calculate them.
#'
#' @param charCode an integer that corresponds to a symbol in the ASCII
#'   character table under the Type 1 font encoding. All numeric values are
#'   coerced using \code{as.integer}. Non-numeric values will not be accepted.
#' @param cex a real number that specifies a scaling factor that is to be
#'   applied to device output.
#' @param face an integer in the range [1-5] that specifies the font face to
#'   use. See \link{par} for details.
#'
#' @return \item{metrics}{A numeric vector holding ascent, descent, width
#'   character metrics. Values should all be nonnegative. }
#'
#' @note \code{\link{tikzDevice}} tries very hard when it is loaded to find a
#'   working \command{latex} or \command{pdflatex} command.  If it is
#'   successful the command is set in \code{options('tikzLatex')}, otherwise
#'   this function will fail.
#'
#' @author Charlie Sharpsteen \email{source@@sharpsteen.net}
#'
#' @seealso \code{\link{tikz}}, \code{\link{getLatexStrWidth}}
#' @references PGF Manual
#'
#' @keywords character
#'
#' @examples
#'
#' 	# Calculate ascent, descent and width for "A"
#' 	getLatexCharMetrics(65)
#'
#' @export
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
	# Also, we load the user packages last so the user can override 
	# things if they need to.
	#
	#The user MUST load the tikz package here
	writeLines(getOption("tikzLatexPackages"), texIn)
	
	# Load important packages for calculating metrics
	writeLines(getOption("tikzMetricPackages"), texIn)

	writeLines("\\batchmode", texIn)

	# Begin a tikz picture.
	writeLines("\\begin{document}\n\\begin{tikzpicture}", texIn)

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

	writeLines( paste( nodeOpts, ' (TeX) {', nodeContent, "%\n};", sep=''), texIn)

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
	latexCmd <- paste( latexCmd, '-interaction=batchmode', '-halt-on-error',
		'-output-directory', texDir, texFile)

  # avoid warnings about non-zero exit status, we know tex exited abnormally
  # it was designed that way for speed
	suppressWarnings(silence <- system( latexCmd, intern=T, ignore.stderr=T))

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

  # complete.cases() checks for NULLs, NAs and NaNs
	if( length(width) == 0 | any(!complete.cases(width)) ){

		message(paste(readLines(texFile),collapse='\n'))
		message(paste(readLines(texLog),collapse='\n'))
		stop('\nTeX was unable to calculate metrics for the following string\n',
      'or character:\n\n\t', 
      TeXMetrics$value, '\n\n',
      'Common reasons for failure include:\n',
      '  * The string contains a character which is special to LaTeX unless\n', 
      '    escaped properly, such as % or $.\n',
      '  * The string makes use of LaTeX commands provided by a package and\n',
      '    the tikzDevice was not told to load the package.\n\n',
      'The contents of the LaTeX log of the aborted run have been printed above,\n',
      'it may contain additional details as to why the metric calculation failed.\n'
    )

	}

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

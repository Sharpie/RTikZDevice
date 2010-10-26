# Utility functions that have nowhere else to live at the moment.
# These functions are used by the device subroutines.

getDateStampForTikz <- function(){

  # This function retrieves the current date stamp using
  # sys.time() and formats it to a string. This function
  # is used by the C routine Print_TikZ_Header to add
  # date stamps to output files.

  return( strftime( Sys.time() ) )

}

getTikzDeviceVersion <- function(){
  
  # Returns the version of the currently installed tikzDevice 
  # for use in Print_TikZ_Header.

  return(
    readLines(
      system.file('GIT_VERSION', package = 'tikzDevice')
    )[1]
  )

}

getDocumentPointsize <- function( docString ){

  # This function scans a LaTeX document declaration
  # for base pointsize used in the document. For example,
  # the declaration:
  #
  #    \documentclass[draft,12pt]{article}
  #
  # Should cause this function to return 12 as the pointsize.
  # The pointsize is used by the tikzDevice to determine
  # scaling factors and is stored at the C level in the
  # startps component of the pDevDesc structure. 

  # Search the document declaration for the pointsize.
  psLocation <- regexpr( '\\d+[pt]', docString, ignore.case = T, perl = T )

  # If there were no matches, regexpr() returns -1 and this
  # function returns NA.
  if( psLocation == -1 ){

    return( NA )

  } else {

    # Extract and return the pointsize.
    pointsize <- substr( docString, psLocation,
      psLocation + attr( psLocation, 'match.length') - 2 )

    return( as.numeric( pointsize ) )

  }

}


#' Reset tikzDevice options.
#' Reset all the \pkg{tikzDevice} options to their default values.
#'
#' Specifically resets the options \code{tikzLatex},
#' \code{tikzDocumentDeclaration}, \code{tikzLatexPackages},
#' \code{tikzMetricPackages}, \code{tikzFooter}, \code{tikzSanitizeCharacters}
#' and \code{tikzReplacementCharacters}.
#'
#' @param overwrite Should values that are allready set in \code{options()} be
#'   overwritten?
#' @return Nothing returned.
#'
#' @author Cameron Bracken \email{cameron.bracken@@gmail.com} and Charlie
#'   Sharpsteen \email{source@@sharpsteen.net}
#'
#' @seealso \code{\link{tikz}}
#'
#' @examples
#'
#' 	print( options( 'tikzDocumentDeclaration' ) )
#' 	options( tikzDocumentDeclaration = 'foo' )
#' 	setTikzDefaults()
#' 	print( options( 'tikzDocumentDeclaration' ) )
#'
#' @export
setTikzDefaults <- function( overwrite = TRUE ){

  tikzDefaults <- list(

    tikzLatex = getOption( 'tikzLatexDefault' ),
 
    tikzDocumentDeclaration = "\\documentclass[10pt]{article}\n",
 
    tikzLatexPackages = c(
      "\\usepackage{tikz}\n",
      "\\usepackage[active,tightpage,psfixbb]{preview}\n",
      "\\PreviewEnvironment{pgfpicture}\n",
      "\\setlength\\PreviewBorder{0pt}\n"
    ),

    tikzXelatexPackages = c(
      "\\usepackage{tikz}\n",
      "\\usepackage[active,tightpage,xetex]{preview}\n",
      "\\usepackage{fontspec,xunicode}\n",
      "\\PreviewEnvironment{pgfpicture}\n",
      "\\setlength\\PreviewBorder{0pt}\n"
    ),

    tikzFooter = "\\end{document}\n",

    tikzMetricPackages = c(
      # The fontenc package is very important here! 
      # R assumes the output device is uing T1 encoding.
      # LaTeX defaults to OT1. This package makes the
      # symbol codes consistant for both systems.
      "\\usepackage[T1]{fontenc}\n",
      "\\usetikzlibrary{calc}\n"
    ),

    tikzUnicodeMetricPackages = c(
      # The fontenc package is very important here!
      # R assumes the output device is uing T1 encoding.
      # LaTeX defaults to OT1. This package makes the
      # symbol codes consistant for both systems.
      "\\usepackage[T1]{fontenc}\n",
      "\\usetikzlibrary{calc}\n",
      "\\usepackage{fontspec,xunicode}\n"
    ),

 
    tikzSanitizeCharacters = c('%','$','}','{','^','_','#','&','~'), 
 
    tikzReplacementCharacters = c('\\%','\\$','\\}','\\{','\\^{}','\\_{}',
      '\\#','\\&','\\char`\\~')

  )

  if( !overwrite ){

    # We don't want to overwrite options that have allready been set.
    # Figure out which those are.
    tikzSetOptions <- sapply( do.call( options, as.list(names(tikzDefaults)) ),
      is.null )

    tikzSetOptions <- names( tikzDefaults )[ tikzSetOptions ]

  }else{

    tikzSetOptions <- names( tikzDefaults )

  }

  # Set defaults
  do.call( options, tikzDefaults[ tikzSetOptions ] )

  # Return a list of the options that were modified.
  invisible( tikzSetOptions )

}

anyMultibyteUTF8Characters <- function(string, encoding = "UTF-8"){

  # This function checks if any of the characters in the given string
  # are multibyte unicode charcters (not ASCII)
  #
  # The function will assume an input encoding of UTF-8 but will take any
  # specified encoding into account and will convert from the specified
  # encoding to UTF-8 before doing any checks

  mb <- FALSE

    # Set the encoding of the string if it is not explicitly set
  if(Encoding(string) == "unknown")
    Encoding(string) <- encoding

    # convert the string to UTF-8
  string <- enc2utf8(string)

    # Check if any of the characters are Multibyte
  explode <- strsplit(string,'')[[1]]
  for(i in 1:length(explode)){

    if(length(charToRaw(explode[i])) > 1){
      mb <- TRUE
      break
    }
  }

  return(mb)

}

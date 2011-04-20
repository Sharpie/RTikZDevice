# Utility functions that have nowhere else to live at the moment.
# These functions are used by the device subroutines.

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

    tikzDefaultEngine = 'pdftex',

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
      '\\#','\\&','\\char`\\~'),

    tikzRasterResolution = 300,

    tikzPdftexWarnUTF = TRUE

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

isTikzDevice <- function(which = dev.cur()){
  if (which == 1){ return(FALSE) }

  dev_name <- names(dev.list()[which - 1])
  return(dev_name == 'tikz output')
}

getTikzDeviceEngine <- function(dev_num = dev.cur()){
  if (!isTikzDevice(dev_num)){
    stop("The specified device is not a tikz device, please start a tikz device to use this function. See ?tikz.")
  }

  engine <- switch(
    EXPR = as.character(.Call('TikZ_GetEngine', dev_num, PACKAGE = 'tikzDevice')),
    '1' = 'pdftex',
    '2' = 'xetex'
  )

  return( engine )
}


getDeviceInfo <- function(dev_num = dev.cur()) {
  # This function recovers some information about a tikz() graphics device that
  # is stored at the C level in the tikzDevDesc struct.
  #
  # Currently returns:
  #
  #  * The path to the TeX file that is being created.
  if (!isTikzDevice(dev_num)){
    stop("The specified device is not a tikz device!")
  }

  device_info <- .Call('TikZ_DeviceInfo', dev_num, PACKAGE = 'tikzDevice')

  return(device_info)

}


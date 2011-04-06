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

tikz_writeRaster <-
function(
  fileName, rasterCount, rasterData, nrows, ncols,
  finalDims, interpolate
){

  fileName = tools::file_path_sans_ext( fileName )
  fileName = paste( fileName, '_ras_', rasterCount, '.png', sep = '' )

  message("\nRaw data was:\n\n",
    paste(capture.output(print(rasterData)),collapse='\n'))

  # Convert the 4 vectors of RGBA data contained in rasterData to a raster
  # image.
  rasterData[['maxColorValue']] = 255
  rasterData = do.call( grDevices::rgb, rasterData )
  rasterData = as.raster(
    matrix( rasterData, nrow = nrows, ncol = ncols, byrow = TRUE ) )

  message("\nRaster image is:\n\n",
    paste(capture.output(print(rasterData)),collapse='\n'))


  message( "Creating raster image: ", fileName, "\n" )

  message(
    "\nraster num ", rasterCount,
    " num rows:", nrows,
    " num columns:", ncols,
    " final dims:", finalDims,
    " interpolate?:", interpolate
  )

  # Write the image to a PNG file.
  savePar = par(no.readonly=TRUE); on.exit(par(savePar))

  # On OS X there is a problem with png() not respecting antialiasing options.
  # So, we have to use quartz instead.  Also, we cannot count on X11 or Cairo
  # being compiled into OS X binaries.  Technically, cannot count on Aqua/Quartz
  # either but you would have to be a special kind of special to leave it out.
  # Using type='Xlib' also causes a segfault for me on OS X 10.6.4
  if ( capabilities('aqua') ){

    quartz( file = fileName, type = 'png',
      width = finalDims$width, height = finalDims$height, antialias = FALSE )

  } else {

    # NOTE: Windows appears to have issues (who knew?!).  We may be loosing a
    # row and column of data.
    png( filename = fileName, width = finalDims$width, height = finalDims$height,
      type = 'Xlib', units = 'in', antialias = 'none' )

  }

  par( mar = c(0,0,0,0) )
  plot.new()

  plotArea = par('fig')

  rasterImage(rasterData, plotArea[1], plotArea[3],
    plotArea[2], plotArea[4], interpolate = interpolate )

  dev.off()

  return( fileName )

}

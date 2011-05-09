#' Convert grid coordinates to device coordinates
#'
#' This function converts a coordinate pair specifying a location in a
#' grid \code{\link{viewport}} in grid units to a coordinate pair specifying a
#' location in device units relative to the lower left corner of the plotting
#' canvas.
#'
#' @param x x coordinate.
#' @param y y coordinate. If no values are given for \code{x} and \code{y}, the
#'   location of the lower-left corner of the current viewport will be
#'   calculated.
#' @param units Character string indicating the units of \code{x} and \code{y}.
#'   See the \code{\link{unit}} function for acceptable unit types.
#'
#' @return A tuple of coordinates in device units.
#'
#' @author Charlie Sharpsteen \email{source@@sharpsteen.net}
#'
#' @keywords graphics grid conversion units
#' @seealso
#'   \code{\link{unit}}
#'   \code{\link{viewport}}
#'   \code{\link{convertX}}
#'   \code{\link{convertY}}
#'   \code{\link{current.transform}}
#'
#'
#' @export
#' @importFrom grid convertX convertY current.transform
gridToDevice <- function(x = 0, y = 0, units = 'native') {
  # Converts a coordinate pair from the current viewport to an "absolute
  # location" measured in device units from the lower left corner. This is done
  # by first casting to inches in the current viewport and then using the
  # current.transform() matric to obtain inches in the device canvas.
  x <- convertX(unit(x, units), unitTo = 'inches', valueOnly = TRUE)
  y <- convertY(unit(y, units), unitTo = 'inches', valueOnly = TRUE)

  transCoords <- c(x,y,1) %*% current.transform()
  transCoords <- (transCoords / transCoords[3])

  return(
    # Finally, cast from inches to device coordinates (which are TeX points for
    # the tikzDevice)
    c(
      grconvertX(transCoords[1], from = 'inches', to = 'device'),
      grconvertY(transCoords[2], from = 'inches', to = 'device')
    )
  )

}


#' Add Custom TikZ Code to an Active Device
#'
#' This function allows custom (LaTeX) commands to be added to the output of an
#' active tikzDevice.
#'
#' \code{tikzAnnotate} is intended to allow the drawing of TikZ commands for
#' annotating graphics. If you annotate a graphic with a command that needs a
#' coordinate \strong{you must convert user coordinates to device coordinates
#' with the \code{\link{grconvertX}} or \code{\link{grconvertY}} function}.
#'
#' \code{tikzCoord} is a wrapper for \code{tikzAnnotate} that inserts TikZ
#' \code{\\coordinate} commands into the output.  Coordinates are named
#' locations that may be referred to by other TikZ drawing commands.
#'
#' \code{tikzAnnotateGrob} and \code{tikzCoordGrob} create "graphics objects"
#' that are suitable for use with the grid graphics system.
#' \code{tikzCoordGrob} uses \code{\link{gridToDevice}} to translate between
#' grid coordinates and device coordinates.
#'
#' See the TikZ vignette for more information and examples.
#'
#' @usage tikzAnnotate(annotation)
#'   tikzCoord(x, y, name, units = 'user')
#'   tikzAnnotateGrob(annotation)
#'   tikzCoordGrob(x, y, name, units = 'native')
#' @param annotation A character vector, one element per line to be added to
#'   the open tikz device.
#' @param x numeric, x location for a named coordinate in user coordinates
#' @param y numeric, y location for a named coordinate in user coordinates
#' @param units Character string specifying the unit system associated with
#'   \code{x} and \code{y}. See \code{\link{grconvertX}} for acceptable
#'   units in base graphics and \code{\link{unit}} for acceptable
#'   units in grid graphics.
#' @param name Character string giving a name for the coordinate (as seen by
#'   TikZ)
#' @return Nothing returned.
#'
#' @author Cameron Bracken <cameron.bracken@@gmail.com> and Charlie Sharpsteen
#'   \email{source@@sharpsteen.net}
#'
#' @name tikzAnnotate
#' @aliases tikzAnnotate tikzCoord tikzAnnotateGrob tikzCoordGrob
#' @seealso
#'   \code{\link{grconvertX}}
#'   \code{\link{grconvertY}}
#'   \code{\link{tikzDevice}}
#'   \code{\link{tikz}}
#'   \code{\link{gridToDevice}}
#'   \code{\link{unit}}
#'
#' @keywords device
#'
#' @examples
#'
#' \dontrun{
#' #### Example 1
#' 	library(tikzDevice)
#' 	options(tikzLatexPackages = c(getOption('tikzLatexPackages'),
#' 		"\\\\usetikzlibrary{shapes.arrows}"))
#' 	tikz(standAlone=TRUE)
#' 	plot(1)
#' 	x <- grconvertX(1,,'device')
#' 	y <- grconvertY(1,,'device')
#' 	tikzAnnotate(paste('\\\\node[single arrow,anchor=tip,draw,fill=green] at (',
#' 		x,',',y,') {Look over here!};'))
#' 	dev.off()
#'
#' #### Example 2
#' 	options(tikzLatexPackages =
#' 	    c(getOption('tikzLatexPackages'),
#' 	        c("\\\\usetikzlibrary{decorations.pathreplacing}",
#' 	        "\\\\usetikzlibrary{shapes.arrows}")))
#'
#' 	p <- rgamma(300,1)
#' 	outliers <- which( p > quantile(p,.75)+1.5*IQR(p) )
#'
#' 	tikz("annotation.tex",width=4,height=4)
#' 	    boxplot(p)
#'
#' 	    min.outlier <- grconvertY(min( p[outliers] ),, "device")
#' 	    max.outlier <- grconvertY(max( p[outliers] ),, "device")
#' 	    x <- grconvertX(1,,"device")
#'
#' 	    tikzAnnotate(paste("\\\\node (min) at (",x,',',min.outlier,") {};"))
#' 	    tikzAnnotate(paste("\\\\node (max) at (",x,',',max.outlier,") {};"))
#' 	    tikzAnnotate(c("\\\\draw[decorate,very thick,red,",
#' 	        "decoration={brace,amplitude=20pt}] (min) ",
#' 	        "-- node[single arrow,anchor=tip,left=20pt,draw=green] ",
#' 	        "{Look at These Outliers!} (max);"))
#' 	    tikzAnnotate(c("\\\\node[starburst, fill=green, ",
#' 	        "draw=blue, very thick,right=of max]  (burst) {Wow!};"))
#' 	    tikzAnnotate(c("\\\\draw[->, very thick] (burst.west) -- (max);"))
#'
#' 	dev.off()
#' 	setTikzDefaults()
#'
#' #### Example 3 - Using tikzCoord
#' 	tikz(standAlone=TRUE)
#' 	plot(1:2,type='l')
#' 	tikzCoord(1,1,'one')
#' 	tikzCoord(1,1,'two')
#' 	tikzAnnotate("\\\\draw[black] (one) -- (two);")
#' 	dev.off()
#' }
#'
#' @export tikzAnnotate tikzCoord tikzAnnotateGrob tikzCoordGrob
#' @importFrom grid grob drawDetails
#' @S3method drawDetails tikz_annotation
#' @S3method drawDetails tikz_coord
NULL

tikzAnnotate <-
function (annotation)
{

	if (!isTikzDevice()){
		stop("The active device is not a tikz device, please start a tikz device to use this function. See ?tikz.")
  }

	.C('TikZ_Annotate', as.character(annotation),
		as.integer(length(annotation)), PACKAGE='tikzDevice')

	invisible()
}

tikzCoord <-
function( x, y, name, units = 'user'){

	# Ensure we got a character.
	if( !is.character(name) ){
		stop( "The coordinate name must be a character!" )
	}

	# Convert coordinates to device coordinates.
  if ( units != 'device' ) {
    tikzX <- grconvertX(x, from = units, to = 'device')
    tikzY <- grconvertY(y, from = units, to = 'device')
  }

  # Use tikzAnnotate() to add a coordinate.
  tikzAnnotate(paste('\\coordinate (', name, ') at (',
    tikzX, ',', tikzY, ');', sep=''))

	# Return the coordinate name, invisibly.
	invisible(
		paste( '(', name, ')', sep = '' )
	)

}


tikzAnnotateGrob <- function(annotation) {

  grob(annotation = annotation, cl = 'tikz_annotation')

}

tikzCoordGrob <- function(x, y, name, units = 'native') {

  grob(x = x, y = y, coord_name = name, units = units, cl = 'tikz_coord')

}

drawDetails.tikz_annotation <- function(x, recording) {

  tikzAnnotate(x$annotation)

}

drawDetails.tikz_coord <- function(x, recording) {

  coords <- gridToDevice(x$x, x$y, x$units)
  tikzCoord(coords[1], coords[2], x$cord_name, units = 'device')

}

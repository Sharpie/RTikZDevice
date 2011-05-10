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
#'   tikzNode(x = NULL, y = NULL,
#'     opts = NULL, name = NULL, content = NULL, units = 'user')
#'   tikzCoord(x, y, name, units = 'user')
#'   tikzAnnotateGrob(annotation)
#'   tikzNodeGrob(x = NULL, y = NULL,
#'     opts = NULL, name = NULL, content = NULL, units = 'native')
#'   tikzCoordGrob(x, y, name, units = 'native')
#' @param annotation A character vector, one element per line to be added to
#'   the open tikz device.
#' @param x numeric, x location for a named coordinate in user coordinates
#' @param y numeric, y location for a named coordinate in user coordinates
#' @param opts A character string that will be used as options for a \code{node}.
#'   See the "Nodes and Edges" section of the TikZ manual for complete details.
#' @param name Optional character string that will be used as a name for a
#'   \code{coordiinate} or \code{node}. Other TikZ commands can use this
#'   name to refer to an object's location.
#' @param content A character string that will be used as the content to be displayed
#'   inside of a \code{node}. If left as \code{NULL} a \code{coordinate} will be
#'   created instead. If a \code{node} with empty content is truely desired,
#'   pass an empty string \code{""}.
#' @param units Character string specifying the unit system associated with
#'   \code{x} and \code{y}. See \code{\link{grconvertX}} for acceptable
#'   units in base graphics and \code{\link{unit}} for acceptable
#'   units in grid graphics.
#' @return Nothing returned.
#'
#' @author Cameron Bracken <cameron.bracken@@gmail.com> and Charlie Sharpsteen
#'   \email{source@@sharpsteen.net}
#'
#' @name tikzAnnotate
#' @aliases tikzAnnotate tikzNode tikzCoord tikzAnnotateGrob tikzNodeGrob tikzCoordGrob
#' @seealso
#'   \code{\link{grconvertX}}
#'   \code{\link{grconvertY}}
#'   \code{\link{gridToDevice}}
#'   \code{\link{unit}}
#'   \code{\link{tikz}}
#'
#' @keywords device
#'
#' @examples
#'
#' \dontrun{
#'
#' ### Example 1: Annotations in Base Graphics
#' # Load some additional TikZ libraries
#' tikz("annotation.tex",width=4,height=4,
#'   packages = c(getOption('tikzLatexPackages'),
#'     "\\usetikzlibrary{decorations.pathreplacing}",
#'     "\\usetikzlibrary{positioning}",
#'     "\\usetikzlibrary{shapes.arrows,shapes.symbols}")
#' )
#'
#' p <- rgamma (300 ,1)
#' outliers <- which( p > quantile(p,.75)+1.5*IQR(p) )
#' boxplot(p)
#'
#' # Add named coordinates that other TikZ commands can hook onto
#' tikzCoord(1, min(p[outliers]), 'min outlier')
#' tikzCoord(1, max(p[outliers]), 'max outlier')
#'
#' # Use tikzAnnotate to insert arbitrary code, such as drawing a
#' # fancy path between min outlier and max outlier.
#' tikzAnnotate(c("\\draw[very thick,red,",
#'   # Turn the path into a brace.
#'   'decorate,decoration={brace,amplitude=12pt},',
#'   # Shift it 1em to the left of the coordinates
#'   'transform canvas={xshift=-1em}]',
#'   '(min outlier) --',
#'   # Add a node with some text in the middle of the path
#'   'node[single arrow,anchor=tip,fill=white,draw=green,',
#'   'left=14pt,text width=0.70in,align=center]',
#'   '{Holy Outliers Batman!}', '(max outlier);'))
#'
#' # tikzNode can be used to place nodes with customized options and content
#' tikzNode(
#'   opts='starburst,fill=green,draw=blue,very thick,right=of max outlier',
#'   content='Wow!'
#' )
#'
#' dev.off()
#'
#' }
#'
#' @export tikzAnnotate tikzNode tikzCoord tikzAnnotateGrob tikzNodeGrob tikzCoordGrob
#' @importFrom grid grob drawDetails
#' @S3method drawDetails tikz_annotation
#' @S3method drawDetails tikz_node
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

tikzNode <- function(
  x = NULL, y = NULL,
  opts = NULL,
  name = NULL, content = NULL,
  units = 'user'
) {
  # If there is no node content, we create a coordinate.
  node_string <- ifelse(is.null(content), '\\coordinate', '\\node')

  # Process the other components.
  if ( !is.null(opts) ) {
    node_string <- paste(node_string, '[', opts, ']', sep = '')
  }
  if ( !is.null(name) ) {
    # Ensure we got a character.
    if ( !is.character(name) ) {
      stop( "The coordinate name must be a character!" )
    }

    node_string <- paste(node_string, ' (', name, ')', sep = '')
  }
  if ( !is.null(x) && !is.null(y) ) {
    # Convert coordinates to device coordinates.
    if ( units != 'device' ) {
      x <- grconvertX(x, from = units, to = 'device')
      y <- grconvertY(y, from = units, to = 'device')
    }

    node_string <- paste(node_string,
      ' at (', round(x,2), ',', round(y,2), ')', sep = '')
  }
  if ( !is.null(content) ) {
    node_string <- paste(node_string, ' {', content, '}', sep = '')
  }

  # Use tikzAnnotate() to add a coordinate.
  tikzAnnotate(paste(node_string, ';', sep = ''))

}


tikzCoord <- function( x, y, name, units = 'user') {

  tikzNode(x = x, y = y, name = name, units = units)

}


tikzAnnotateGrob <- function(annotation) {

  grob(annotation = annotation, cl = 'tikz_annotation')

}

tikzNodeGrob <- function(
  x = NULL, y = NULL,
  opts = NULL, name = NULL,
  content = NULL,
  units = 'native'
) {

  grob(x = x, y = y, opts = opts, coord_name = name, content = content,
    units = units, cl = 'tikz_node')

}

tikzCoordGrob <- function(x, y, name, units = 'native') {

  grob(x = x, y = y, coord_name = name, units = units, cl = 'tikz_coord')

}


drawDetails.tikz_annotation <- function(x, recording) {

  tikzAnnotate(x$annotation)

}

drawDetails.tikz_node <- function(x, recording) {

  if ( is.null(x$x) && is.null(x$y) ) {
    coords <- c(NULL, NULL)
  } else {
    coords <- gridToDevice(x$x, x$y, x$units)
  }

  tikzNode(coords[1], coords[2], x$opts,
    x$cord_name, x$content, units = 'device')

}

drawDetails.tikz_coord <- function(x, recording) {

  coords <- gridToDevice(x$x, x$y, x$units)
  tikzCoord(coords[1], coords[2], x$cord_name, units = 'device')

}

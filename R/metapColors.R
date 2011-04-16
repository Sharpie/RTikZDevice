#' @export
metap_color <- function(color_name, rgb_value, spot_name = NULL) {
  # color_name: A name for the color. Should only contain letters.
  # rgb_value: A vector of three integers that specifies the color value
  # spot_name: A name for a PDF color channel to which the color should be
  #            assigned.  can contain spaces and numbers, perhaps other symbols
  #            as well.
  if ( grepl('[^a-zA-Z]', color_name) ) {
    stop("MetaPost color names cannot contain any characters other than ASCII letters!")
  }

  if ( is.character(rgb_value) ) rgb_value <- grDevices::col2rgb(rgb_value)

  return(
    structure(
      list(color_name = color_name, rgb_value = rgb_value, spot_name = spot_name),
      class = 'metap_color'
    )
  )

}


format.metap_color <- function(color, ...) {
  red = color$rgb_value[1]
  green = color$rgb_value[2]
  blue = color$rgb_value[3]

  color_def <- c("\n\\definecolor\n\t",
    paste("[", color$color_name, "]\n\t", sep = ''),
    sprintf("[r=%i,g=%i,b=%i]\n", red, green, blue)
  )


  if (!is.null(color$spot_name)) {
    color_def <- c(color_def,
      "\n\\definespotcolor\n\t",
      paste("[", color$color_name, "Spot]\n\t", sep = ''),
      paste("[", color$color_name, "]\n\t", sep = ''),
      sprintf("[p=1,e=%s]\n", color$spot_name)
    )
  }

  return( color_def )

}


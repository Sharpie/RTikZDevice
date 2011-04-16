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


#' @export
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


rgb2col <- function(rgb_value){

  # Takes RGB values and produces a HTML string---i.e "#000000" for black.
  color <- rgb(rgb_value[1], rgb_value[2], rgb_value[3], maxColorValue = 255)

}


add_metap_color <- function(color_list, color) {
  # Function for adding a color to a color list. If the color defines a new
  # name for an RGB value that allready exists in the list, then the name of
  # the existing color is swapped out to a list of "alias" or "old names".
  color_tag <- rgb2col(color$rgb_value)
  existing_color <- color_list[[color_tag]]


  if ( is.null(existing_color) ) {

    color_list[[color_tag]] <- color

  } else {

    # Overwrite, incase a color got redefined as a spot color
    color_list[[color_tag]] <- color

    color_list[[color_tag]]$aliases <- setdiff(
      c(existing_color$aliases, existing_color$color_name),
      color$color_name
    )

  }

  return( color_list )

}


#' @export
define_metap_color <- function(color_name, rgb_value, spot_name = NULL, dev_num = dev.cur()) {

  color <- metap_color(color_name, rgb_value, spot_name)

  if (dev_num == -1) {

    # Add to the global color list
    color_list <- add_metap_color(getOption('metapColors'), color)
    options(metapColors = color_list)

  } else {
    if ( dev_num == 1 ||
        ( names(dev.list()[dev_num - 1]) != 'metapost output' )
       ) { stop("Can only set colors on a metapost device!") }

    color_list <- add_metap_color(getDeviceInfo(dev_num)$colors, color)
    setMetapColors(color_list, dev_num)

  }

  invisible(color_list)

}


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
  # Generates ConTeXt code for defining colors and spot colors.
  red = color$rgb_value[1]
  green = color$rgb_value[2]
  blue = color$rgb_value[3]

  color_def <- c("\n\\definecolor\n\t",
    paste("[", color$color_name, "]\n\t", sep = ''),
    sprintf("[r=%5.3f,g=%5.3f,b=%5.3f]\n", red/255, green/255, blue/255)
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


get_or_set_color <- function(rgb_value) {
  # This function is called from the C code of the MetaPost device, it's job is
  # to search the global color list and the device's own color list to retrieve
  # the name assigned to a given RGB value. If no definition exists, the RGB
  # value is added to the device's color list under a generic name.

  # Search device specific list.
  dev_num <- dev.cur()
  color_tag <- rgb2col(rgb_value)
  color_list <- getDeviceInfo(dev_num)$colors
  if ( is.null(color_list) ) color_list <- list()

  color <- color_list[[color_tag]]

  if ( is.null(color) ) {
    # Try the global list.
    color <- getOption('metapColors')[[color_tag]]
  }

  if ( is.null(color) ) {
    # Still Null. Color not defined yet. Add to device color list.
    if ( is.null(attr(color_list, 'n_color_defs')) ) {
      # Simple integer counter used to generate unique names for undefined
      # colors.
      attr(color_list, 'n_color_defs') <- 1
    }

    n <- attr(color_list, 'n_color_defs')
    # Color names have to contain only letters. Will convert the integer
    # `n_def` to a suitable combination of letters A-Z.
    color_name <- c(rep(26, (n - (n %% 26)) / 26), n %% 26)
    color_name <- paste('MetaPostColor',
      paste(LETTERS[color_name], sep = '', collapse=''),
      sep = ''
    )

    color <- metap_color(color_name, rgb_value)

    attr(color_list, 'n_color_defs') <- n + 1
    color_list <- add_metap_color(color_list, color)
    setMetapColors(color_list, dev_num)

  }

  if ( is.null(color$spot_name) ) {
    return(color$color_name)
  } else {
    return(
      paste(color$color_name, 'Spot', sep = '')
    )
  }

}


#' @export
define_metap_color <- function(color_name, rgb_value, spot_name = NULL, dev_num = dev.cur()) {
  # User visible function for adding or altering colors in the global color
  # list or a device-specific color list. If -1 is passed for dev_num, this
  # function alters the global list.

  color <- metap_color(color_name, rgb_value, spot_name)

  if (dev_num == -1) {

    # Add to the global color list
    color_list <- add_metap_color(getOption('metapColors'), color)
    options(metapColors = color_list)

  } else {
    if ( dev_num == 1 ||
        ( names(dev.list()[dev_num - 1]) != 'metapost output' )
       ) { stop("Can only set colors on a metapost device!") }

    color_list <- getDeviceInfo(dev_num)$colors
    if (is.null(color_list)) color_list <- list()
    color_list <- add_metap_color(getDeviceInfo(dev_num)$colors, color)
    setMetapColors(color_list, dev_num)

  }

  invisible(color_list)

}


evil_color_mangler <- function(output_file, device_colors) {
  # This function is called at the end of a MetaPost plot to do post-processing
  # of color names. The tasks that need to be done are:
  #
  #   * Combine global color list with the device's color list.
  #
  #   * Scan the device output and remove any colors from the list that were
  #     not actuall used.
  #
  #   * If a color was renamed by a call to `define_metap_color`, then replace
  #     occurances of the old name with the final name. Substitue spot color
  #     names if they are present.
  #
  #   * Print out the ConTeXt color definitons and prepend them to the device
  #     output.
  #
  # This routine is "evil" because it performs these tasks very, very
  # inefficiently---mostly by greping through the output multiple times.
  color_list <- getOption('metapColors')
  for (color in device_colors) { color_list <- add_metap_color(color_list, color) }

  # This function forms a regular expression that matches color definitions for
  # a given MetaPost color.
  form_regex <- function(color) {
    aliases <- unique(c(color$color_name, color$aliases))
    regex <- paste(
      'MPcolor',
      paste('(\\{', aliases, '\\})', collapse = '|', sep = ''),
      sep = ''
    )

    return( regex )
  }

  device_output <- readLines(output_file)

  color_list <- Filter(
    function(color) {any(grepl(form_regex(color), device_output)) },
    color_list
  )


  colors_to_sub <- Filter(
    function(color) { !is.null(color$aliases) || !is.null(color$spot_name) },
    color_list
  )

  for (color in colors_to_sub) {

    if (!is.null(color$spot_name)) {
      name <- paste(color$color_name, 'Spot', sep = '')
    } else {
      name <- color$color_name
    }

    device_output <- gsub(form_regex(color), paste('{', name, '}', sep = ''),
      device_output)

  }

  color_defs <- unlist(sapply(color_list, format))
  color_defs <- c(color_defs,
    '\n\n\\setupcolors[state=start,spot=yes,overprint=yes]\n')

  output <- file(output_file, 'w')
  writeLines(color_defs, output, sep = '')
  writeLines(device_output, output)
  close(output)

  invisible()

}


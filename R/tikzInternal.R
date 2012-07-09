# These are unexported functions that are called by the C routines of the tikz
# device to execute tasks that are difficult to do at the C level.

getDateStampForTikz <- function(){

  # This function retrieves the current date stamp using
  # sys.time() and formats it to a string. This function
  # is used by the C routine Print_TikZ_Header to add
  # date stamps to output files.

  return( strftime( Sys.time() ) )

}


getTikzDeviceVersion <- function(lib.loc = NULL){

  # Returns the version of the currently installed tikzDevice for use in
  # Print_TikZ_Header.
  version_file <- system.file('GIT_VERSION', package = 'tikzDevice', lib.loc = lib.loc)
  if (file.exists(version_file)) {
    version_num <- readLines(version_file)[1]
  } else {
    version_num <- paste('~',
      read.dcf(system.file('DESCRIPTION', package = 'tikzDevice', lib.loc = lib.loc),
        fields = 'Version')
    )
  }

  return( version_num )

}


tikz_writeRaster <-
function(
  fileName, rasterCount, rasterData, nrows, ncols,
  finalDims, interpolate
){

  raster_file <- basename(tools::file_path_sans_ext(fileName))
  raster_file <- file.path(dirname(fileName),
    paste(raster_file, '_ras', rasterCount, '.png', sep = '')
  )

  # Convert the 4 vectors of RGBA data contained in rasterData to a raster
  # image.
  rasterData[['maxColorValue']] = 255
  rasterData = do.call( grDevices::rgb, rasterData )
  rasterData = as.raster(
    matrix( rasterData, nrow = nrows, ncol = ncols, byrow = TRUE ) )

  # Write the image to a PNG file.

  # On OS X there is a problem with png() not respecting antialiasing options.
  # So, we have to use quartz instead.  Also, we cannot count on X11 or Cairo
  # being compiled into OS X binaries.  Technically, cannot count on Aqua/Quartz
  # either but you would have to be a special kind of special to leave it out.
  # Using type='Xlib' also causes a segfault for me on OS X 10.6.4
  if ( Sys.info()['sysname'] == 'Darwin' && capabilities('aqua') ){

    quartz( file = raster_file, type = 'png',
      width = finalDims$width, height = finalDims$height, antialias = FALSE,
      dpi = getOption('tikzRasterResolution') )

  } else if (Sys.info()['sysname'] == 'Windows') {

    png( filename = raster_file, width = finalDims$width, height = finalDims$height,
      units = 'in', res = getOption('tikzRasterResolution') )

  } else {

    # Linux/UNIX and OS X without Aqua.
    png( filename = raster_file, width = finalDims$width, height = finalDims$height,
      type = 'Xlib', units = 'in', antialias = 'none',
      res = getOption('tikzRasterResolution') )

  }

  par( mar = c(0,0,0,0) )
  plot.new()

  plotArea = par('usr')

  rasterImage(rasterData, plotArea[1], plotArea[3],
    plotArea[2], plotArea[4], interpolate = interpolate )

  dev.off()

  return(
    basename(tools::file_path_sans_ext(raster_file))
  )

}

tikzAnnotate <-
function (annotation)
{	

	if(names(dev.cur()) != "tikz output")
		stop("The active device is not a tikz device, please start a tikz device to use this function. See ?tikz.")
		
	.C('tikzAnnotate', as.character(annotation), 
		as.integer(length(annotation)), PACKAGE='tikzDevice') 
	
	invisible()	
}

tikzCoord <-
function( x, y, name ){

	# Ensure we got a character.
	if( !is.character(name) ){
		stop( "The coordinate name must be a character!" )
	}

	# Convert user coordinates to device coordinates.
	tikzX <- grconvertX( x, to = 'device' )
	tikzY <- grconvertY( y, to = 'device' )

  # Use tikzAnnotate() to add a coordinate.
  tikzAnnotate(paste('\\coordinate (', name, ') at (',
    tikzX, ',', tikzY, ');', sep='')) 

	# Return the coordinate name, invisibly.
	invisible(
		paste( '(', name, ')', sep = '' )
	)

}

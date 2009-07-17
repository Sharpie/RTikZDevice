tikz <-
function (file = "Rplots.tex", width = 7, height = 7, bg="white", fg="black",
	standAlone = FALSE, bareBones = FALSE )
{

	# Ensure the standAlone option will trump the bareBones option.
	if( standAlone ) { bareBones = F }	

  .External('tikzDevice', file, width, height, bg, fg, standAlone, bareBones, PACKAGE='tikzDevice') 
	
	invisible()	
}


tikz <-
function (file = "Rplots.tex", width = 7, height = 7, bg="white", fg="black",
	standAlone = FALSE, bareBones = FALSE, header = getOptions("tikzDeviceHeader"),
	footer = getOptions("tikzDeviceFooter"))
{

	# Ensure the standAlone option will trump the bareBones option.
	if( standAlone ) { bareBones = F }
	if( footer != getOptions("tikzDeviceFooterDefault") && !standAlone)
		warning( "Footers are ignored when standAlone is set to FALSE" )

	.External('tikzDevice', file, width, height, bg, fg, standAlone, bareBones, PACKAGE='tikzDevice') 
	
	invisible()	
}


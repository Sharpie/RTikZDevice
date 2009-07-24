tikzAnnotate <-
function (annotation)
{	

	if(names(dev.cur()) != "tikz output")
		stop("The active device is not a tikz device, please start a tikz device to use this function. See ?tikz.")
		
	.C('tikzAnnotate', as.character(annotation), 
		as.integer(length(annotation)), PACKAGE='tikzDevice') 
	
	invisible()	
}
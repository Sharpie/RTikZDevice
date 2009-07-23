tikzAnnotate <-
function (annotation)
{	

	.C('tikzAnnotate', as.character(annotation), 
		as.integer(length(annotation)), PACKAGE='tikzDevice') 
	
	invisible()	
}
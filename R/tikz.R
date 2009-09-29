tikz <-
function (file = "Rplots.tex", width = 7, height = 7, bg="white", fg="black",
	standAlone = FALSE, bareBones = FALSE, 
	documentDeclaration = getOption("tikzDocumentDeclaration"),
	packages = getOption("tikzLatexPackages"),
	footer = getOption("tikzFooter"),
	bfs = 11
){

	# Ensure the standAlone option will trump the bareBones option.
	if( standAlone ) { bareBones = F }
	if( footer != getOption("tikzFooterDefault") && !standAlone)
		warning( "Footers are ignored when standAlone is set to FALSE" )

	# Collapse the character vectors into a single string 
	# which is easier to work with in C
	documentDeclaration <- 
		paste( paste(documentDeclaration, collapse='\n'), collapse='\n')
	packages <- paste( paste( packages, collapse='\n'), collapse='\n')
	footer <- paste( paste( footer,collapse='\n'), collapse='\n')
	
	.External('tikzDevice', file, width, height, bg, fg, standAlone, 
		bareBones, documentDeclaration, packages, footer, bfs,
		PACKAGE='tikzDevice') 
	
	invisible()	
}

setTikzDefaults <- function(){
	
	options( tikzLatex = getOption('tikzLatexDefault') )
	options( tikzDocumentDeclaration = getOption("tikzDocumentDeclarationDefault") )
	options( tikzLatexPackages = getOption("tikzLatexPackagesDefault"))
	options( tikzFooter = getOption('tikzFooterDefault') )
	
	
}

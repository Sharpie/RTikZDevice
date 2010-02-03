tikz <-
function (file = "Rplots.tex", width = 7, height = 7,
  bg="transparent", fg="black", pointsize = 10,
  standAlone = FALSE, bareBones = FALSE, console = FALSE, 
  sanitize = FALSE,
  documentDeclaration = getOption("tikzDocumentDeclaration"),
  packages = getOption("tikzLatexPackages"),
  footer = getOption("tikzFooter")
){

  # Ensure the standAlone option will trump the bareBones option.
  if( standAlone ) { bareBones = F }
  if( footer != getOption("tikzFooterDefault") && !standAlone)
    warning( "Footers are ignored when standAlone is set to FALSE" )

  # Extract the document pointsize from the documentDeclaration
  baseSize <- getDocumentPointsize( documentDeclaration )

  # If a pointsize was not found, we use the value of the pointsize
  # argument.
  if( is.na( baseSize ) ){

    baseSize <- pointsize

  }


  # Collapse the character vectors into a single string 
  # which is easier to work with in C
  documentDeclaration <- 
    paste( paste(documentDeclaration, collapse='\n'), collapse='\n')
  packages <- paste( paste( packages, collapse='\n'), collapse='\n')
  footer <- paste( paste( footer,collapse='\n'), collapse='\n')
  
  .External('tikzDevice', file, width, height, bg, fg, baseSize, 
    standAlone, bareBones, documentDeclaration, packages, footer, console, sanitize,
    PACKAGE='tikzDevice') 
  
  invisible()  

}

setTikzDefaults <- function(){
	
	options( tikzLatex = getOption('tikzLatexDefault') )
	options( tikzDocumentDeclaration = getOption("tikzDocumentDeclarationDefault") )
	options( tikzLatexPackages = getOption("tikzLatexPackagesDefault"))
	options( tikzFooter = getOption('tikzFooterDefault') )
	options( tikzSanitizeCharacters = c('%','$','}','{','^') )
	options( tikzReplacementCharacters = c('\\%','\\$','\\}','\\{','\\^{}'))
	
	
}
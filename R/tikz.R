tikz <-
function (file = "Rplots.tex", width = 7, height = 7, bg="white", fg="black",
	standAlone = FALSE, latexCmd = getOption('tikzLatex') )
{
  .External('tikzDevice', file, width, height, bg, fg, standAlone, latexCmd) 
	
	invisible()	
}


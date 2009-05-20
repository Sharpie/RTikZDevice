tikz <-
function (file = "Rplots.tex", width = 7, height = 7,standalone = FALSE)
{
  .External('tikzDevice', file, width, height, standalone) 
	
	invisible()	
}


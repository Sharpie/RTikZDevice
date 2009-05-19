tikz <-
function (file = "Rplots.tex", width = 7, height = 7)
{
  .External('tikzDevice', file, width, height) 
	
	invisible()	
}


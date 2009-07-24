\name{tikzAnnotate}
\Rdversion{1.1}
\alias{tikzAnnotate}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Annotate an active tikz device
}
\description{
This function allows (LaTeX) commands to be added to an active tikzDevice.  
}
\usage{
	tikzAnnotate( annotation ) 
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{annotation}{A character vector, one element per line to be added to the open tikz device.}
}
\details{
This is intended to allow the drawing of TikZ commands for annotating graphics. If you annotate a graphic with a command that needs a coordinate \strong{you must convert user coordinates to device coordinates with the \code{\link{grconvertX}} or \code{\link{grconvertY}} function}.
}

\value{
Nothing returned.
}
\author{
Cameron Bracken <cameron.bracken@gmail.com>
}

\seealso{
\code{\link{grconvertX}}, \code{\link{grconvertY}},\code{\link{tikzDevice}}, \code{\link{tikz}}
}
\examples{
	library(tikzDevice)
	options(tikzLatexPackages = c(getOption('tikzLatexPackages'),
		"\\usetikzlibrary{shapes.arrows}"))
	tikz(standAlone=T)
	plot(1)
	x <- grconvertX(1,,'device')
	y <- grconvertY(1,,'device')
	tikzAnnotate(paste('\\node[single arrow,anchor=tip,draw,fill=green] at (',
		x,',',y,') {Look over here!};'))
	dev.off()
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ device }
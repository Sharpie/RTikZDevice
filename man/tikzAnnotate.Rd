\name{tikzAnnotate}
\Rdversion{1.1}
\alias{tikzAnnotate}
\alias{tikzCoord}
\title{
Annotate an active tikz device
}
\description{
This function allows (LaTeX) commands to be added to an active tikzDevice.  
}
\usage{
	tikzAnnotate( annotation ) 
	tikzCoord( x, y, name ) 
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{annotation}{A character vector, one element per line to be added to the open tikz device.}
  \item{x}{numeric, x location for a named coordinate in user coordinates}
  \item{y}{numeric, y location for a named coordinate in user coordinates}
  \item{name}{Character string giving a name for the coordinate (as seen by TikZ)}
}
\details{
\code{tikzAnnotate} is intended to allow the drawing of TikZ commands for annotating graphics. If you annotate a graphic with a command that needs a coordinate \strong{you must convert user coordinates to device coordinates with the \code{\link{grconvertX}} or \code{\link{grconvertY}} function}.

\code{tikzCoord} provides a way to reference a specific location in the graphic by name for annotation purposes. 
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
\dontrun{
#### Example 1
	library(tikzDevice)
	options(tikzLatexPackages = c(getOption('tikzLatexPackages'),
		"\\\\usetikzlibrary{shapes.arrows}"))
	tikz(standAlone=TRUE)
	plot(1)
	x <- grconvertX(1,,'device')
	y <- grconvertY(1,,'device')
	tikzAnnotate(paste('\\\\node[single arrow,anchor=tip,draw,fill=green] at (',
		x,',',y,') {Look over here!};'))
	dev.off()

#### Example 2	
	options(tikzLatexPackages = 
	    c(getOption('tikzLatexPackages'),
	        c("\\\\usetikzlibrary{decorations.pathreplacing}",
	        "\\\\usetikzlibrary{shapes.arrows}")))

	p <- rgamma(300,1)
	outliers <- which( p > quantile(p,.75)+1.5*IQR(p) )

	tikz("annotation.tex",width=4,height=4)
	    boxplot(p)

	    min.outlier <- grconvertY(min( p[outliers] ),, "device")
	    max.outlier <- grconvertY(max( p[outliers] ),, "device")
	    x <- grconvertX(1,,"device")

	    tikzAnnotate(paste("\\\\node (min) at (",x,',',min.outlier,") {};"))
	    tikzAnnotate(paste("\\\\node (max) at (",x,',',max.outlier,") {};"))
	    tikzAnnotate(c("\\\\draw[decorate,very thick,red,",
	        "decoration={brace,amplitude=20pt}] (min) ",
	        "-- node[single arrow,anchor=tip,left=20pt,draw=green] ",
	        "{Look at These Outliers!} (max);"))
	    tikzAnnotate(c("\\\\node[starburst, fill=green, ",
	        "draw=blue, very thick,right=of max]  (burst) {Wow!};"))
	    tikzAnnotate(c("\\\\draw[->, very thick] (burst.west) -- (max);"))

	dev.off()
	setTikzDefaults()
	
#### Example 3 - Using tikzCoord
	tikz(standAlone=TRUE)
	plot(1:2,type='l')
	tikzCoord(1,1,'one')
	tikzCoord(1,1,'two')
	tikzAnnotate("\\\\draw[black] (one) -- (two);")
	dev.off()
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ device }

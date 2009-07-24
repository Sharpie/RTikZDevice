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
#### Example 1
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

#### Example 2	
	options(tikzLatexPackages = 
	    c(getOption('tikzLatexPackages'),
	        c("\\usetikzlibrary{decorations.pathreplacing}",
	        "\\usetikzlibrary{shapes.arrows}")))

	p <- rgamma(300,1)
	outliers <- which( p > quantile(p,.75)+1.5*IQR(p) )

	tikz("annotation.tex",width=4,height=4)
	    boxplot(p)

	    min.outlier <- grconvertY(min( p[outliers] ),, "device")
	    max.outlier <- grconvertY(max( p[outliers] ),, "device")
	    x <- grconvertX(1,,"device")

	    tikzAnnotate(paste("\\node (min) at (",x,',',min.outlier,") {};"))
	    tikzAnnotate(paste("\\node (max) at (",x,',',max.outlier,") {};"))
	    tikzAnnotate(c("\\draw[decorate,very thick,red,",
	        "decoration={brace,amplitude=20pt}] (min) ",
	        "-- node[single arrow,anchor=tip,left=20pt,draw=green] ",
	        "{Look at These Outliers!} (max);"))
	    tikzAnnotate(c("\\node[starburst, fill=green, ",
	        "draw=blue, very thick,right=of max]  (burst) {Wow!};"))
	    tikzAnnotate(c("\\draw[->, very thick] (burst.west) -- (max);"))

	dev.off()
	setTikzDefaults()
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ device }
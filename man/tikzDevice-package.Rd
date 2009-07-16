\name{tikzDevice-package}
\Rdversion{1.1}
\alias{tikzDevice-package}
\alias{tikzDevice}
\docType{package}
\title{
TikZ Graphics Device
}
\description{
This package provides the \code{\link{tikz}} graphics device for outputing graphics PGF/TikZ format for inclusion into LaTeX documents.  Graphics output in this manner can be included directly in LaTeX documents. All text in a graphic output with \code{tikz} will be typeset by LaTeX and therefore will match whatever fonts are currently used in the document.  This also means that \textbf{\textit{LaTeX mathematics can be typeset directly into labels and annotations}}
}
\details{
\tabular{ll}{
Package: \tab tikzDevice\cr
Type: \tab Package\cr
Version: \tab 0.3.5\cr
Date: \tab 2009-07-16\cr
License: \tab GPL\cr
LazyLoad: \tab yes\cr
}
%~~ An overview of how to use the package, including the most important ~~
%~~ functions ~~
}
\author{
Charlie Sharpsteen \email{source@sharpsteen.net} and Cameron Bracken \email{cameron.bracken@gmail.com}

Maintainer: Charlie Sharpsteen \email{source@sharpsteen.net}
}
\references{
PGF manual

pictex Device
}
\keyword{ package }
\seealso{
\code{\link{tikz}}
}
\examples{
\dontrun{
td <- tempdir()
tf <- file.path(td,'example.tex')
oldwd <- getwd()
setwd(td)

tikz(tf,standAlone=T)
	plot(-2:2, -2:2, type = "n", axes=F, 
			xlab='', ylab='', main='TikZ Device Example')
    text(x,y,paste('\\Large$\\',syms,'$',sep=''))
dev.off()
tools::texi2dvi(tf,pdf=T)
system(paste(getOption('pdfviewer'),file.path(td,'example.pdf')))
setwd(oldwd)
}
}

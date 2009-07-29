\name{tikzDevice-package}
\Rdversion{1.1}
\alias{tikzDevice-package}
\alias{tikzDevice}
\docType{package}
\title{
Support for native LaTeX output of R graphics
}
\description{
This package implements the \code{\link{tikz}} device which allows for the output of R graphics 
to be saved in a LaTeX friendly format. All text in a graphic be typeset by LaTeX and therefore will match whatever fonts are currently used in the document.  This also means that \strong{LaTeX mathematics can be typeset directly into labels and annotations}
}
\details{
\tabular{ll}{
Package: \tab tikzDevice\cr
Type: \tab Package\cr
Version: \tab 0.35\cr
Date: \tab 2009-07-16\cr
License: \tab GPL 2.0 or greater\cr
LazyLoad: \tab yes\cr
}
}
\author{
Cameron Bracken: \email{cameron.bracken@gmail.com}

Charlie Sharpsteen: \email{source@sharpsteen.net}

Submit bug reports to: \email{tikzdevice-bugs@lists.r-forge.r-project.org}
}
\references{
The TikZ and PGF Packages: Manual for version 2.00\cr
\url{http://sourceforge.net/projects/pgf}\cr
Till Tantu, February 20, 2008
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
    text(x,y,paste('\\\\Large$\\\\',syms,'$',sep=''))
dev.off()
tools::texi2dvi(tf,pdf=T)
system(paste(getOption('pdfviewer'),file.path(td,'example.pdf')))
setwd(oldwd)
}
}

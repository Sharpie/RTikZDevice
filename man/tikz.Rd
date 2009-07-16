\Rdversion{1.1}
\name{tikz}
\alias{tikz}

\title{
TikZ Graphics Device
}
\description{
\code{tikz} is used to open a R graphics device which supports output in the TikZ graphics 
language. TikZ code may be used inside a LaTeX document by specifying \code{\\usepackage\{tikz\}} 
in the document header.
}
\usage{
tikz(file = "Rplots.tex", width = 7, height = 7, bg = "white", fg = "black"
	standAlone = FALSE)
}
\arguments{
  \item{file}{A character string indicating the desired path to the output file.}
  \item{width}{The width of the output figure, in \bold{inches}.}
  \item{height}{The hegiht of the output figure, in \bold{inches}.}
  \item{bg}{The starting background color for the plot.}
  \item{fg}{The starting foreground color for the plot.}
  \item{standAlone}{A logical value indicating whether the resulting file should be suitable for direct 
		processing by LaTeX. A value of \code{FALSE} indicates that the file is intended for inclusion in a
	  larger document. See \sQuote{Details}.}
  }
\details{
The TikZ device enables LaTeX-ready output from R graphics functions. This is done by producing code that 
can be understood by the TikZ graphics language. Current releases of the TikZ package are available from 
\url{http://www.ctan.org}. The package may also be installed through the MikTeX package manager on Windows 
or using the TeX Live package manager, \code{tlmgr}, on Unix/Linux/OS X. The TeX Live package manager will 
only be installed by default for TeX Live distributions dated 2008 and later. Both bleeding-edge and release 
versions of TikZ may be obtained from the project website hosted at \url{http://sourceforge.net/projects/pgf/}.

The TikZ device currently supports two modes of output depending on the value of the parameter \code{standAlone}.
If \code{standAlone} is set to \code{FALSE}, the default, the resulting file will only contain the \code{tikzpicture}
environment and the commands to build your graphic. Since this file is not a complete LaTeX document, it will need to
be included in another LaTeX document using the \code{\\input} command.

When \code{standAlone} is set to \code{TRUE}, the device wraps the \code{tikzpicture} environment in a complete LaTeX
document suitable for direct compilation. In this mode the \code{preview} package is used to crop the resulting output 
to the bounding box of the graphic.
}
\note{
Should probably mention something about why plotting functions are so slow here...
}
\value{
\code{tikz()} returns no values.
}
\references{
The TikZ and PGF Packages: Manual for version 2.00\cr
\url{http://sourceforge.net/projects/pgf}\cr
Till Tantu, February 20, 2008
}

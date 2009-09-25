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
tikz(file = "Rplots.tex", width = 7, height = 7, 
	bg="white", fg="black", standAlone = FALSE, bareBones = FALSE, 
	documentDeclaration = getOption("tikzDocumentDeclaration"),
	packages = getOption("tikzLatexPackages"),
	footer = getOption("tikzFooter"))
}
\arguments{
  \item{file}{A character string indicating the desired path to the output file.}
  \item{width}{The width of the output figure, in \bold{inches}.}
  \item{height}{The height of the output figure, in \bold{inches}.}
  \item{bg}{The starting background color for the plot.}
  \item{fg}{The starting foreground color for the plot.}
  \item{standAlone}{A logical value indicating whether the resulting file 
			should be suitable for direct processing by LaTeX. A value of 
			\code{FALSE} indicates that the file is intended for inclusion in 
			a larger document. See \sQuote{Details}.}
  \item{bareBones}{A logical value.  When \code{TRUE} the figure will not be 
			wrapped in a \code{tikzpicture} environment.  This option is 
			useful for embedding one TikZ picture within another. When 
			\code{TRUE} multipage output will be drawn on a single page.}
  \item{documentDeclaration}{See the section ``Options That Affect Package Behavior.''}
  \item{packages}{See the section ``Options That Affect Package Behavior.''}
  \item{footer}{See the section ``Options That Affect Package Behavior.''}
  }

\details{
The TikZ device enables LaTeX-ready output from R graphics functions. This is done by producing code that 
can be understood by the TikZ graphics language. All text in a graphic output with \code{tikz} will be typeset by LaTeX and therefore will match whatever fonts are currently used in the document. This also means that \strong{LaTeX mathematics can be typeset directly into labels and annotations}.

The TikZ device currently supports two modes of output depending on the value of the parameter \code{standAlone}.
If \code{standAlone} is set to \code{FALSE}, the default, the resulting file will only contain the \code{tikzpicture}
environment and the commands to build your graphic. Since this file is not a complete LaTeX document, it will need to
be included in another LaTeX document using the \code{\\input} command. For example,
\preformatted{
\documentclass{article}
\usepackage{tikz}
\begin{document}
    \begin{figure}
        \centering
        \input{Rplots.tex}
        \caption{}
    \end{figure}
\end{document}
}

When \code{standAlone} is set to \code{TRUE}, the device wraps the \code{tikzpicture} environment in a complete LaTeX
document suitable for direct compilation. In this mode the \code{preview} package is used to crop the resulting output 
to the bounding box of the graphic.
}
\value{
\code{tikz()} returns no values.
}
\references{
The TikZ and PGF Packages: Manual for version 2.00\cr
\url{http://sourceforge.net/projects/pgf}\cr
Till Tantau, February 20, 2008
}
\author{
Charlie Sharpsteen \email{source@sharpsteen.net} and Cameron Bracken \email{cameron.bracken@gmail.com}
}
\note{
To compile the output of \code{tikz} a working installation of LaTeX and PGF is needed.  Current releases of the TikZ package are available from 
\url{http://www.ctan.org}. The package may also be installed through the MikTeX package manager on Windows 
or using the TeX Live package manager, \code{tlmgr}, on Unix/Linux/OS X. The TeX Live package manager will 
only be installed by default for TeX Live distributions dated 2008 and later. Both bleeding-edge and release 
versions of TikZ may be obtained from the project website hosted at \url{http://sourceforge.net/projects/pgf/}.

Multiple plots will be placed as separate environments in the output file.
}

\section{Options That Affect Package Behavior}{
The \pkg{tikzDevice} package is currently influenced by a number of global options that may be set your \R\ scripts, in the \R\ console or in your in a \code{.Rprofile} file. All of the options can be set by using \code{options(<option> = <value>)}.  These options allow for the use of custom \code{documentclass} declarations, LaTeX packages, and typesetting engines (e.g. XeLaTeX). The defaults , if are any for a given option, are shown below the description.   The global options are:

\describe{
\item{\code{tikzLatex}}{ Specifies the location of the LaTeX compiler to be used by \pkg{tikzDevice}. Setting this option may help the package locate a missing compiler. The default is searched for when the package is loaded, otherwise it can be set manually.   This option may be set as follows: \code{options( tikzLatex = '/path/to/latex/compiler' )}.}

\item{\code{tikzMetricsDictionary}}{ When using the graphics device provided by \pkg{tikzDevice}, you may notice that \R\ appears to ``lag" or ``hang" when commands such as \code{plot()} are executed. This is because the device must query the LaTeX compiler for string widths and font metrics. For a normal plot, this may happen dozens or hundreds of times- hence \R\ becomes unresponsive for a while. The good news is that the \code{tikz()} code is designed to cache the results of these computations so they need only be performed once for each string or character. By default, these values are stored in a temporary cache file which is deleted when \R\ is shut down. A location for a permanent cache file may be specified by setting the value of \code{tikzMetricsDictionary} in \code{.Rprofile} with \code{options( tikzMetricsDictionary = '/path/to/dictionary/location' )}.}

\item{\code{tikzDocumentDeclaration}}{A string. The documentclass declaration when \code{standAlone == TRUE} as well. as when font metrics are calculated. The default value is:
\preformatted{
options( tikzDocumentDeclaration = "\\\\documentclass{article}" )
<<<<<<< HEAD
}}

\item{\code{tikzFooter}}{A character vector. The footer to be used only when \code{standAlone==TRUE}. The default value is: 
\preformatted{
options( tikzFooter = c( "\\\\end{document}" ) )
}}

=======


}}

\item{\code{tikzFooter}}{A character vector. The footer to be used only when \code{standAlone==TRUE}. The default value is: 
\preformatted{
options( tikzFooter = c( "\\\\end{document}" ) )
}}

>>>>>>> beta
\item{\code{tikzLatexPackages}}{ A character vector. These are the packages which are included when using the \code{standAlone} option as well as when font metric are calculated. The default value is:
\preformatted{
options( tikzLatexPackagesDefault = c(
	"\\\\usepackage{tikz}",
	"\\\\usepackage[active,tightpage]{preview}",
	"\\\\PreviewEnvironment{pgfpicture}",
	"\\\\setlength\\\\PreviewBorder{0pt}") )
}
}

\item{\code{tikzMetricPackages}}{ A character vector. These are the packages which are additionally loaded when doing font metric calculations.  As you see below, the font encoding is set to Type 1. This is very important so that character codes of LaTeX and \R\ match up. The default value is:
\preformatted{
options( tikzMetricPackages = c(
		"\\\\usepackage[utf8]{inputenc}",
		"\\\\usepackage[T1]{fontenc}",
		"\\\\usetikzlibrary{calc}"))
		
		
}}
} 
} 

\seealso{
\code{\link{pictex}}, \code{\link{getLatexCharMetrics}}, \code{\link{getLatexStrWidth}}, \code{\link{setTikzDefaults}}, \code{\link{tikzAnnotate}}
}
\examples{
\dontrun{
		
## Example 1 ###################################
#Set up temporary work directory
td <- tempdir()
tf <- file.path(td,'example1.tex')
oldwd <- getwd()
setwd(td)

# Minimal plot
tikz(tf,standAlone=TRUE)
	plot(1)
dev.off()

# View the output
tools::texi2dvi(tf,pdf=T)
system(paste(getOption('pdfviewer'),file.path(td,'example1.pdf')))
setwd(oldwd)
################################################
		
## Example 2 ###################################
#Set up temporary work directory
td <- tempdir()
tf <- file.path(td,'example2.tex')
oldwd <- getwd()
setwd(td)

#LaTeX math symbol names
syms <-c('alpha','theta','tau','beta','vartheta','pi','upsilon',
   		  'gamma','gamma','varpi','phi','delta','kappa','rho',
   		  'varphi','epsilon','lambda','varrho','chi','varepsilon',
   		  'mu','sigma','psi','zeta','nu','varsigma','omega','eta',
   		  'xi','Gamma','Lambda','Sigma','Psi','Delta','Xi','Upsilon',
   		  'Omega','Theta','Pi','Phi')
x <- rnorm(length(syms))
y <- rnorm(length(syms))

tikz(tf,standAlone=TRUE)
	plot(-2:2, -2:2, type = "n", axes=F, 
			xlab='', ylab='', main='TikZ Device Example')
    text(x,y,paste('\\\\Large$\\\\',syms,'$',sep=''))
dev.off()

#View the output
tools::texi2dvi(tf,pdf=TRUE)
system(paste(getOption('pdfviewer'),file.path(td,'example2.pdf')))
setwd(oldwd)
################################################

## Example 3 ###################################
#Set up temporary work directory
td <- tempdir()
tf <- file.path(td,'example3.tex')
oldwd <- getwd()
setwd(td)

tikz(tf,standAlone=TRUE)
	plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(50), rnorm(50), pch=21, 
			bg=rainbow(50,alpha=.5), cex=10)
dev.off()

#View the output
tools::texi2dvi(tf,pdf=TRUE)
system(paste(getOption('pdfviewer'),file.path(td,'example3.pdf')))
setwd(oldwd)
################################################
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ device }

\name{tikz}
\alias{tikz}

\title{
TikZ Graphics Device
}
\description{
\code{tikz} is used to open a R graphics device which supports output in the TikZ graphics 
language. TikZ code may be included inside a LaTeX document by specifying \code{\\usepackage\{tikz\}} 
in the document header.
}
\usage{
tikz(file = "Rplots.tex", width = 7, height = 7,
	  bg="transparent", fg="black", pointsize = 10, standAlone = FALSE, 
	  bareBones = FALSE, console = FALSE, sanitize = FALSE,
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
  \item{pointsize}{Base pointsize used in the LaTeX document.  This option is
      only used if a valid pointsize cannot be extracted from the value of
      \code{getOption("tikzDocumentDeclaration")}.  See the section ``Font Size Calculations'' for more details. }
  \item{standAlone}{A logical value indicating whether the output file 
			should be suitable for direct processing by LaTeX. A value of 
			\code{FALSE} indicates that the file is intended for inclusion in 
			a larger document. See \sQuote{Details}.}
  \item{bareBones}{A logical value.  When \code{TRUE} the figure will not be 
			wrapped in a \code{tikzpicture} environment.  This option is 
			useful for embedding one TikZ picture within another. When 
			\code{TRUE} multipage output will be drawn on a single page.}
  \item{console}{Should the output of tikzDevice be directed to the R console 
			(default FALSE). This is useful for dumping tikz output directly 
			into a LaTeX document via \code{\link{sink}}.  If TRUE, the 
			\code{file} argument is ignored. Setting \code{file=''} is 
			equivalent to setting \code{console=TRUE}.}
  \item{sanitize}{Should special latex characters be replaced (Default FALSE). 
			See the section ``Options That Affect Package Behavior'' for which
			characters are replaced.}
  \item{documentDeclaration}{See the sections ``Options That Affect Package 
			Behavior'' and ``Font Size Calculations'' for more details.}
  \item{packages}{See the section ``Options That Affect Package Behavior.''}
  \item{footer}{See the section ``Options That Affect Package Behavior.''}
  }

\details{
The TikZ device enables LaTeX-ready output from \R{} graphics functions. This is done by encoding graphics commands using TikZ markup.  All text in a graphic output with \code{tikz} will be typeset by LaTeX and therefore will match whatever fonts are currently used in the document. This also means that \strong{LaTeX mathematics can be typeset directly into labels and annotations}.

The TikZ device currently supports three modes of output depending on the value of the parameter \code{standAlone} and \code{bareBones}.  If \code{standAlone} and \code{bareBones} are set to the default value of \code{FALSE}, the resulting file will only contain graphics output wrapped in a LaTeX \code{tikzpicture} environment.  Since this file is not a complete LaTeX document, it will need to be included in another LaTeX document using the \code{\\input} command. For example,
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

When \code{standAlone} is set to \code{TRUE}, the device wraps the \code{tikzpicture} environment in a complete LaTeX document suitable for direct compilation. In this mode the \code{preview} package is used to crop the resulting output to the bounding box of the graphic.  

When \code{bareBones} is set to \code{TRUE}, the output is not wrapped in a document or a \code{tikzpicture} environment.  This is useful for embedding an \R{} generated graphic within an existing TikZ picture. 

In cases where both \code{standAole} and \code{bareBones} have been set to \code{TRUE}, the \code{standAlone} option will take precedence.
}

\value{
\code{tikz()} returns no values.
}

\section{Font Size Calculations}{

The overarching goal of the \code{tikzDevice} is to provide seamless integration between text in \R{} graphics and the text of LaTeX documents that contain those graphics. In order to achieve this integration the device must translate font sizes specified in \R{} to corresponding font sizes in LaTeX.

The issue is that font sizes in LaTeX are controlled by a ``base font size'' that is specified at the beginning of the document-- typically 10pt.  There is no easy way in LaTeX to change the font size to a new numerical value, such as 16pt for a plot title.  Fortunately, the TikZ graphics system allows text to be resized using a scaling factor.  The \code{tikzDevice} calculates this scaling factor using three inputs:

\itemize{

  \item The ``base font size'' specified when the graphics device is created.

  \item The ``character expansion factor'' parameter, specified using the \code{cex} argument to functions such as \code{\link{par}}.

  \item The ``font size'' parameter, specified using the \code{ps} argument to functions such as \code{\link{par}} or the \code{fontsize} argument to functions such as \code{\link{gpar}}. 

}

The tricky bit is the specification of the ``base font size''.  By default the \code{tikzDevice} will attempt to determine this parameter by scaning the value of \code{options( "tikzDocumentDeclaration" )} using the regular expression \code{\\d+[pt]}.  For the default header of:

\preformatted{
  \documentclass[10pt]{article}
}

This regular expression will return 10 as the base pointsize to be used by the device.  If the regular expression fails to produce a match, the value of the \code{pointsize} argument to the \code{tikz} function will be used.
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
The \pkg{tikzDevice} package is currently influenced by a number of global options that may be set your \R{} scripts, in the \R{} console or in your in a \code{.Rprofile} file. All of the options can be set by using \code{options(<option> = <value>)}.  These options allow for the use of custom \code{documentclass} declarations, LaTeX packages, and typesetting engines (e.g. XeLaTeX). The defaults , if are any for a given option, are shown below the description.   The global options are:

\describe{
\item{\code{tikzLatex}}{ Specifies the location of the LaTeX compiler to be used by \pkg{tikzDevice}. Setting this option may help the package locate a missing compiler. The default is searched for when the package is loaded, otherwise it can be set manually.   This option may be set as follows: \code{options( tikzLatex = '/path/to/latex/compiler' )}.}

\item{\code{tikzMetricsDictionary}}{ When using the graphics device provided by \pkg{tikzDevice}, you may notice that \R{} appears to ``lag" or ``hang" when commands such as \code{plot()} are executed. This is because the device must query the LaTeX compiler for string widths and font metrics. For a normal plot, this may happen dozens or hundreds of times- hence \R{} becomes unresponsive for a while. The good news is that the \code{tikz()} code is designed to cache the results of these computations so they need only be performed once for each string or character. By default, these values are stored in a temporary cache file which is deleted when \R{} is shut down. A location for a permanent cache file may be specified by setting the value of \code{tikzMetricsDictionary} in \code{.Rprofile} with \code{options( tikzMetricsDictionary = '/path/to/dictionary/location' )}.}

\item{\code{tikzDocumentDeclaration}}{A string. The LaTeX documentclass declaration used in output files when \code{standAlone == TRUE}.  \code{tikzDocumentDeclaration} also influences the calculation of font metrics. The default value is:

\preformatted{
options( tikzDocumentDeclaration = "\\\\documentclass[10pt]{article}" )
}}

\item{\code{tikzFooter}}{A character vector. The footer to be used only when \code{standAlone==TRUE}. The default value is: 
\preformatted{
options( tikzFooter = c( "\\\\end{document}" ) )
}}

\item{\code{tikzLatexPackages}}{ A character vector. These are the packages which are included when using the \code{standAlone} option as well as when font metric are calculated. The default value is:
\preformatted{
options( tikzLatexPackagesDefault = c(
	"\\\\usepackage{tikz}",
	"\\\\usepackage[active,tightpage]{preview}",
	"\\\\PreviewEnvironment{pgfpicture}",
	"\\\\setlength\\\\PreviewBorder{0pt}") )
}
}

\item{\code{tikzMetricPackages}}{ A character vector. These are the packages which are additionally loaded when doing font metric calculations.  As you see below, the font encoding is set to Type 1. This is very important so that character codes of LaTeX and \R{} match up. The default value is:

\preformatted{
options( tikzMetricPackages = c(
		"\\\\usepackage[utf8]{inputenc}",
		"\\\\usepackage[T1]{fontenc}",
		"\\\\usetikzlibrary{calc}"))
}}

\item{\code{tikzSanitizeCharacters}}{ A character vector of special latex characters to replace. These values should correspond to the replacement values from the \code{tikzReplacementCharacters} option The default value is:
\preformatted{
options( tikzSanitizeCharacters = c('\%','\$','\}','\{','^') )
}}

\item{\code{tikzReplacementCharacters}}{ A character vector of replacements for special latex characters. These values should correspond to the values from the \code{tikzSanitizeCharacters} option The default value is:
\preformatted{
options( tikzReplacementCharacters = c('\\\\\%','\\\\\$','\\\\}','\\\\{','\\\\^{}'))
}}

} 
} 

\references{
The TikZ and PGF Packages: Manual for version 2.00\cr
\url{http://sourceforge.net/projects/pgf}\cr
Till Tantau, February 20, 2008
}

\author{
Charlie Sharpsteen \email{source@sharpsteen.net} and Cameron Bracken \email{cameron.bracken@gmail.com}
}

\seealso{
\code{\link{pictex}}, \code{\link{getLatexCharMetrics}}, \code{\link{getLatexStrWidth}}, \code{\link{setTikzDefaults}}, \code{\link{tikzAnnotate}}, \code{\link{sanitizeTexString}}
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

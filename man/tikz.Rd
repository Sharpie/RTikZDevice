\name{tikz}
\Rdversion{1.1}
\alias{tikz}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
TikZ Graphics Device
}
\description{
\code{tikz} produces graphic output in PGF/TikZ format for inclusion into LaTeX documents.
}
\usage{
	tikz(file = "Rplots.tex", width = 7, height = 7, 
		bg="white", fg="black", standAlone = FALSE )
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{file}{Name of the output file}
  \item{width}{Width of the device in inches}
  \item{height}{Height if the device in inches}
  \item{bg}{Default background color}
  \item{fg}{Default foreground color}
  \item{standAlone}{
    Should the resuting tikzpicture environment be wrapped in a LaTeX header and footer so that it can me compiled directly.  Note: the preview environment is used here to crop the picture. 
  }
}
\details{
A graphic output with the \code{tikz} device may be used directly in LaTeX or pdfLaTeX my means of an \code{\input{}} statement.  For example, 
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

All text in a graphic output with \code{tikz} will be typeset by LaTeX and therefore will match whatever fonts are currently used in the document. This also means that \strong{LaTeX mathematics can be typeset directly into labels and annotations}.

}
\value{
Output file is generated. 
}
\references{
PGF Manual 

PicTeX Device
}
\author{
Charlie Sharpsteen \email{source@sharpsteen.net} and Cameron Bracken \email{cameron.bracken@gmail.com}
}
\note{
To compile the output of \code{tikz} a working installation of LaTeX and PGF is needed. 

Multiple plots will be placed as separate environments in the output file.
}

\section{String Widths and Font Metrics and Calulation Times}{

Charlie can wax poetic here about string widths, font metrics, encodings, metric dictionaries, comutation time, and the meaning of life. 

}

\seealso{
\code{\link{pictex}}, \code{\link{latexParseCharForMetrics}}, \code{\link{getLatexStringWidth}}
}
\examples{
\dontrun{
		
## Example 1 ###################################
#Set up temporary work directory
td <- tempdir()
tf <- file.path(td,'example2.tex')
oldwd <- getwd()
setwd(td)

# Minimal plot
tikz(tf,standAlone=T)
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

tikz(tf,standAlone=T)
	plot(-2:2, -2:2, type = "n", axes=F, 
			xlab='', ylab='', main='TikZ Device Example')
    text(x,y,paste('\\Large$\\',syms,'$',sep=''))
dev.off()

#View the output
tools::texi2dvi(tf,pdf=T)
system(paste(getOption('pdfviewer'),file.path(td,'example2.pdf')))
setwd(oldwd)
################################################

## Example 2 ###################################
#Set up temporary work directory
td <- tempdir()
tf <- file.path(td,'example3.tex')
oldwd <- getwd()
setwd(td)

tikz(tf,standAlone=T)
	plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(50), rnorm(50), pch=21, 
			bg=rainbow(50,alpha=.5), cex=10)
dev.off()

#View the output
tools::texi2dvi(tf,pdf=T)
system(paste(getOption('pdfviewer'),file.path(td,'example3.pdf')))
setwd(oldwd)
################################################
}
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ device }

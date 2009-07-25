\name{setTikzDefaults}
\Rdversion{1.1}
\alias{setTikzDefaults}
\title{
Reset tikzDevice options.
}
\description{
Reset all the \pkg{tikzDevice} options to their default values.
}
\usage{
	setTikzDefaults() 
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  None.
}
\details{
Specifically resets the options \code{tikzLatex}, \code{tikzDocumentDeclaration}, \code{tikzLatexPackages} and \code{tikzFooter} 
}

\value{
Nothing returned.
}
\author{
Cameron Bracken <cameron.bracken@gmail.com>
}

\seealso{
\code{\link{tikz}}
}
\examples{
	options( 'tikzDocumentDeclaration' )
	options( tikzDocumentDeclaration = 'foo' )
	setTikzDefaults() 
	options( 'tikzDocumentDeclaration' )
}

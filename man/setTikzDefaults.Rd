\name{setTikzDefaults}
\Rdversion{1.1}
\alias{setTikzDefaults}
%- Also NEED an '\alias' for EACH other topic documented here.
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
specifially resets the options \code{tikzLatex}, \code{tikzDocumentDeclaration}, \code{tikzLatexPackages} and \code{tikzFooter} 
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
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ character }

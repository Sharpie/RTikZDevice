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
	setTikzDefaults( overwrite = TRUE ) 
setTikzDefaults(overwrite=TRUE)
}

\arguments{
  \item{ overwrite }{Should values that are allready set in \code{options()} be overwritten?}  
\item{overwrite}{Should values that are allready set in \code{options()} be
overwritten?}
}
\details{
Specifically resets the options \code{tikzLatex},
\code{tikzDocumentDeclaration}, \code{tikzLatexPackages},
\code{tikzMetricPackages}, \code{tikzFooter}, \code{tikzSanitizeCharacters} and
\code{tikzReplacementCharacters}. 
\code{setTikzDefaults}: Specifically resets the options \code{tikzLatex},
\code{tikzDocumentDeclaration}, \code{tikzLatexPackages},
\code{tikzMetricPackages}, \code{tikzFooter}, \code{tikzSanitizeCharacters}
and \code{tikzReplacementCharacters}.


}

\value{
Nothing returned.
\code{setTikzDefaults}: Nothing returned.


}
\author{
Cameron Bracken \email{cameron.bracken@gmail.com} and Charlie Sharpsteen \email{source@sharpsteen.net}
}

\seealso{
\code{\link{tikz}}
\code{\link{tikz}}}
\examples{
	print( options( 'tikzDocumentDeclaration' ) )
	options( tikzDocumentDeclaration = 'foo' )
	setTikzDefaults() 
	print( options( 'tikzDocumentDeclaration' ) )
print( options( 'tikzDocumentDeclaration' ) )
options( tikzDocumentDeclaration = 'foo' )
setTikzDefaults()
print( options( 'tikzDocumentDeclaration' ) )}
\alias{setTikzDefaults}


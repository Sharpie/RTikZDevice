\name{latexParseCharForMetrics}
\Rdversion{1.1}
\alias{latexParseCharForMetrics}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Calculate the ascent, descent, width of a single character as seen by LaTeX.
}
\description{
This function calculates character metrics after being compiled by LaTeX. 
}
\usage{
	latexParseCharForMetrics( charCode ) 
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{charCode}{}
}
\details{
A bunch of voo doo. Charlie, you can do the honors. 
}

\value{
  \item{acent}{}
  \item{decent}{}
  \item{width}{}

}
\references{
PGF Manual
}
\author{
Charlie Sharpsteen \email{source@sharpsteen.net}
}
\note{
\code{\link{tikzDevice}} tries very hard when it is loaded to find a working \command{latex} or \command{pdflatex} command.  If it is successful the command is set in \code{options('tikzLatex')}, otherwise this function will fail. 
}

\seealso{
\code{\link{tikz}}, \code{\link{getLatexStringWidth}}
}
\examples{
	latexParseCharForMetrics('{\\\\tiny Hello \\\\LaTeX!}')
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ character }

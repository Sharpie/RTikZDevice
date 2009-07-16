\name{getLatexStringWidth}
\Rdversion{1.1}
\alias{getLatexStringWidth}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Calculate the width of a LaTeX string
}
\description{
This function calculates the width of a string after being compiled by LaTeX. 
}
\usage{
	getLatexStrWidth( texString ) 
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{texString}{An arbitrary string to calcualte the width of.  May contain LaTeX markup.}
}
\details{
This function is used internally by the \code{tikz} device for proper string placement in graphics.  This function first checks to see if the width exists in a global or temporary string width dictionary (as define in \code{options('tikzMetricsDictionary')}) and if so will pull the width from there. If the dictionary does not exist then a temporary one for the current R session is created and the string width is calculated via a \code{system} call to latex. The calling of latex to calculate a string width is quit expensive and so we reccommend setting \code{options('tikzMetricsDictionary') <- /path/to/dictionary} to greate a global dictionary.  
}

\value{
  \item{width}{The width of \code{texString} in pointsize.}
}
\references{
Post on compt.text.tex.
}
\author{
Charlie Sharpsteen \email{source@sharpsteen.net} and Cameron Bracken \email{cameron.bracken@gmail.com}
}
\note{
\pkg{\link{tikzDevice}} tries very hard when it is loaded to find a working \command{latex} or \command{pdflatex} command.  If it is successful the command is set in \code{options('tikzLatex')}, otherwise this function will fail. 
}

\seealso{
\code{\link{tikz}}, \code{\link{getLatexCharMetrics}}
}
\examples{
	getLatexStrWidth('{\\\\tiny Hello \\\\LaTeX!}')
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ character }

\name{getLatexStrWidth}
\alias{getLatexStrWidth}
\title{Obtain the Width of an Arbitrary LaTeX String...}
\usage{getLatexStrWidth(texString, cex=1, face=1)
getLatexStrWidth(texString, cex=1, face=1)
getLatexStrWidth(texString, cex=1, face=1)
}
\description{Obtain the Width of an Arbitrary LaTeX String
This function calculates the width of a string as it would appear after
being compiled by LaTeX.}
\details{This function is used internally by the \code{tikz} device for proper string
placement in graphics.  This function first checks to see if the width
exists in a global or temporary string width dictionary (as define in
\code{options('tikzMetricsDictionary')}) and if so will pull the width from
there. If the dictionary does not exist then a temporary one for the current
R session is created and the string width is calculated via a \code{system}
call to latex. The calling of latex to calculate a string width is quit
expensive and so we strongly recommend setting
\code{options('tikzMetricsDictionary') <- /path/to/dictionary} to create a
global dictionary.\code{getLatexStrWidth}: This function is used internally by the \code{tikz} device for proper string
placement in graphics.  This function first checks to see if the width
exists in a global or temporary string width dictionary (as define in
\code{options('tikzMetricsDictionary')}) and if so will pull the width from
there. If the dictionary does not exist then a temporary one for the current
R session is created and the string width is calculated via a \code{system}
call to latex. The calling of latex to calculate a string width is quit
expensive and so we strongly recommend setting
\code{options('tikzMetricsDictionary') <- /path/to/dictionary} to create a
global dictionary.


\code{getLatexStrWidth}: This function is used internally by the \code{tikz} device for proper string
placement in graphics.  This function first checks to see if the width
exists in a global or temporary string width dictionary (as define in
\code{options('tikzMetricsDictionary')}) and if so will pull the width from
there. If the dictionary does not exist then a temporary one for the current
R session is created and the string width is calculated via a \code{system}
call to latex. The calling of latex to calculate a string width is quit
expensive and so we strongly recommend setting
\code{options('tikzMetricsDictionary') <- /path/to/dictionary} to create a
global dictionary.


}
\value{\item{width}{The width of \code{texString} in point size.}\code{getLatexStrWidth}: \item{width}{The width of \code{texString} in point size.}


\code{getLatexStrWidth}: \item{width}{The width of \code{texString} in point size.}


}
\note{\pkg{\link{tikzDevice}} tries very hard when it is loaded to find a
working \command{latex} or \command{pdflatex} command.  If it is
successful the command is set in \code{options('tikzLatex')}, otherwise
this function will fail.\pkg{\link{tikzDevice}} tries very hard when it is loaded to find a
working \command{latex} or \command{pdflatex} command.  If it is
successful the command is set in \code{options('tikzLatex')}, otherwise
this function will fail.\pkg{\link{tikzDevice}} tries very hard when it is loaded to find a
working \command{latex} or \command{pdflatex} command.  If it is
successful the command is set in \code{options('tikzLatex')}, otherwise
this function will fail.}
\author{Charlie Sharpsteen \email{source@sharpsteen.net} and Cameron
Bracken \email{cameron.bracken@gmail.com}}
\seealso{\code{\link{tikz}}, \code{\link{getLatexCharMetrics}}\code{\link{tikz}}, \code{\link{getLatexCharMetrics}}\code{\link{tikz}}, \code{\link{getLatexCharMetrics}}}
\keyword{character}
\arguments{\item{texString}{An arbitrary string for which the width is to be
calculated.  May contain LaTeX markup.}
\item{cex}{a real number that specifies a scaling factor that is to be
applied to device output.}
\item{face}{an integer in the range [1-5] that specifies the font face to
use. See \link{par} for details.}
}
\examples{getLatexStrWidth('{\tiny Hello \LaTeX!}')getLatexStrWidth('{\\tiny Hello \\LaTeX!}')getLatexStrWidth('{\\\\tiny Hello \\\\LaTeX!}')}

\alias{getLatexStrWidth}
\keyword{character}

\alias{getLatexStrWidth}
\keyword{character}


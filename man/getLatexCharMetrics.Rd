\name{getLatexCharMetrics}
\alias{getLatexCharMetrics}
\title{Obtain LaTeX Font Metrics for Characters
This function is used to retrieve the ascent, decent and width of a
character glyph as it would appear in output typeset by LaTeX.}
\usage{
  getLatexCharMetrics(charCode, cex = 1, face = 1,
    engine = getOption("tikzDefaultEngine"))
}
\arguments{
  \item{charCode}{an integer that corresponds to a symbol
  in the ASCII character table under the Type 1 font
  encoding. All numeric values are coerced using
  \code{as.integer}. Non-numeric values will not be
  accepted.}

  \item{cex}{a real number that specifies a scaling factor
  that is to be applied to device output.}

  \item{face}{an integer in the range [1-5] that specifies
  the font face to use. See \link{par} for details.}

  \item{engine}{a string specifying which TeX engine to
  use. Possible values are 'pdftex', 'xetex' and 'luatex'.
  See the Unicode section of \link{tikzDevice} for
  details.}
}
\value{
  \item{metrics}{A numeric vector holding ascent, descent,
  width character metrics. Values should all be
  nonnegative. }
}
\description{
  \code{getLatexCharMetrics} first checks to see if metrics
  have allready been calculated for the given character
  using the given values of \code{cex} and \code{face}. If
  so, cached values are returned. If no cached values
  exists, the LaTeX compiler specified by \code{options(
  tikzLatex )} is invoked in order to calculate them.
}
\note{
  \code{\link{tikzDevice}} tries very hard when it is
  loaded to find a working \command{latex} or
  \command{pdflatex} command.  If it is successful the
  command is set in \code{options('tikzLatex')}, otherwise
  this function will fail.
}
\examples{
# Calculate ascent, descent and width for "A"
	getLatexCharMetrics(65)
}
\author{
  Charlie Sharpsteen \email{source@sharpsteen.net}
}
\references{
  PGF Manual
}
\seealso{
  \code{\link{tikz}}, \code{\link{getLatexStrWidth}}
}
\keyword{character}


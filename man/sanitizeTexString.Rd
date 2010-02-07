\name{sanitizeTexString}
\alias{sanitizeTexString}

\title{
Replace LaTeX spacial characters in a string
}
\description{
This function is used by tikzDevice when \code{sanitize=TRUE} to replace special LaTeX characters (such as the comment character \%) in plotting text where the user does not have direct control over the generated text. 
}
\usage{
	sanitizeTexString(string, strip = getOption('tikzSanitizeCharacters'),
		replacement = getOption('tikzReplacementCharacters'))
}
\arguments{
  \item{string}{A character vector of length 1 (a string).}
	\item{strip}{A character vector of single characters to search for.}
	\item{replacement}{A character vector of replacement values.}
}
\details{
\code{sanitizeTexString} searches character by character through a string replacing each occurrence of a special character contained in \code{strip[i]} with the corresponding replacement value in \code{replacement[i]}.  tikzDevice calls back this function for every pice of text when the sanitize option is TRUE. See \code{\link{tikz}} for more information on the default special characters and replacement values.
}
\value{
  \item{sanitizedString}{A character vector of length 1 with all special characters replaced. }

}
\author{
Cameron Bracken \email{cameron.bracken@gmail.com}
}
\seealso{
\code{\link{tikz}}
}
\examples{
	# Although we may want -1 to be a superscrip it gets sanitized away with 
	# the other default special characters
	sanitizeTexString('10\% of 10\$ is 10^{-1}\$')
}
\keyword{ character }

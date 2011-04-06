

#' Check If a String Contains Multibyte UTF-8 characters
#' This function is used by tikzDevice to check if an incoming string contains
#' multibyte UTF-8 characters
#' 
#' This function searches through the characters in the given string, if any of
#' the characters in the string are more than one byte then the function
#' returns \code{TRUE} otherwise it returns \code{FALSE}.
#' 
#' The function will assume an input encoding of UTF-8 but will take any
#' specified encoding into account and will convert from the specified encoding
#' to UTF-8 before doing any checks
#' 
#' @param string A character vector of length 1 (a string).
#' @param encoding The input encoding of \code{string}, if not specified
#'   previously via \code{\link{Encoding}} or by this argument then a value of
#'   "UTF-8" is assumed
#' @return A boolean value
#' @author Cameron Bracken \email{cameron.bracken@@gmail.com}
#' @seealso \code{\link{tikz}}
#' @keywords character
#' @examples
#' 
#' # TRUE
#' anyMultibyteUTF8Characters('R is GNU © but not ®')
#' # FALSE
#' anyMultibyteUTF8Characters('R is GNU copyright but not restricted')
#' 
#' @export
anyMultibyteUTF8Characters <- function(string, encoding = "UTF-8"){

  # This function checks if any of the characters in the given string
  # are multibyte unicode charcters (not ASCII)
  #
  # The function will assume an input encoding of UTF-8 but will take any
  # specified encoding into account and will convert from the specified
  # encoding to UTF-8 before doing any checks

  mb <- FALSE

    # Set the encoding of the string if it is not explicitly set
  if(Encoding(string) == "unknown")
    Encoding(string) <- encoding

    # convert the string to UTF-8
  string <- enc2utf8(string)

    # Check if any of the characters are Multibyte
  explode <- strsplit(string,'')[[1]]
  for(i in 1:length(explode)){

    if(length(charToRaw(explode[i])) > 1){
      mb <- TRUE
      break
    }
  }

  return(mb)

}

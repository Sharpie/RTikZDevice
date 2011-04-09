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

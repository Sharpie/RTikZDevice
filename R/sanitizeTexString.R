sanitizeTexString <- function(string, 
	strip = getOption('tikzSanitizeCharacters'),
	replacement = getOption('tikzReplacementCharacters')){
		
		explode <- strsplit(string,'')[[1]]
		for(i in 1:length(explode)){
			
			matches <- (explode[i] == strip)
			if(any(matches))
				explode[i] <- paste('{',replacement[which(matches)],'}',sep='')
				
		}
		return(paste(explode,collapse=''))
}
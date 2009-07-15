queryDictionaryForWidth <-
function( texString ){

	# Since calling LaTeX to obtain string metrics is inefficient
	# and expensive, this function will search a string metrics 
	# dictionary to see if we have allready calculated metrics
	# for this particular string. If so we return the cached
	# value.

	# Ensure the dictionary is available.
	checkDictionaryStatus()

	# For some reson texString is not considered a part of this
	# function's environment. Therefore it can not be accessed
	# from within .tikzOptions. So we'll export it into 
	# tikzOptions as a quick fix.
	#
	# Something seems dirty about this... I guess we will remove
	# the variable before we exit in order to keep .tikzOptions
	# clean.
	assign('texString', texString, envir=.tikzOptions)

	# Check for the string.
	if( evalq( dbExists(dictionary, sha1(texString) ), .tikzOptions) ){

		# Yay! The width exists! Recover and return it.
		width <- evalq( dictionary[[ sha1(texString) ]], .tikzOptions)
		# Clean up .tikzOptions.
		remove('texString', envir= .tikzOptions, inherits=F)
		return( width )

	}else{

		# No dice. Return -1 to indicate that metrics for this string
		# are not present in the dictionary.
		return( -1 )

	} 

}

storeWidthInDictionary <-
function( texString, width ){

	# This function stores a width in the metrics dictionary. The
	# with is stored under a key which is a SHA1 hash created from
	# the texString it is associated with.

	# See comment in queryDictionaryForWidth on why these assign
	# statments are here and why they give me a bad feeling.
	assign('texString', texString, envir=.tikzOptions)
	assign('width', width, envir=.tikzOptions)

	evalq( dictionary[[ sha1(texString) ]] <- width, .tikzOptions)

	# Clean up .tikzOptions.
	remove(list=c('texString','width'), envir= .tikzOptions, inherits=F)

	# Return nothing.
	invisible()

}


checkDictionaryStatus <-
function(){

	# This function checks to see if our dictionary has been
	# created as a variable in our private .tikzOptions
	# enviornment. If not, it either opens a user specified
	# dictionary or creates a new one in tempdir().
	if( !exists('dictionary', envir=.tikzOptions, inherits=F) ){

		# Check for a user specified dictionary.
		if( !is.null( getOption('tikzMetricsDictionary') ) ){

			dbFile <- getOption('tikzMetricsDictionary')

			# Create the database file if it does not exist.
			if( !file.exists( dbFile ) ){
				message("Creating new tikz metrics dictionary in:\n\t",dbFile)
				dbCreate( dbFile, type='DB1' )
			}


		}else{
			# Create a temporary dictionary- it will disappear after
			# the R session finishes.
			dbFile <- file.path( tempdir(), 'tikzMetricsDictionary' ) 
			dbCreate( dbFile, type='DB1' )
		}

		# Add the dictionary as an object in the .tikzOptions
		# environment.
		assign( 'dictionary', dbInit(dbFile), envir=.tikzOptions)

	}

	# Return nothing.
	invisible()

}


sha1 <-
function( robj ){
	# Filehash contains a function for generating a SHA1 hash
	# from an R object, but doesn't export it. The digest package
	# also contains the exact same code made publicly avaiable
	# but it seems redundant to add it to the dependency list.
	# This function allows access to filehash's unexported SHA1 
	# function.

	return( filehash:::sha1( robj ) )

}

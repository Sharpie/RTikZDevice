patchedCodeRunner <- function(evalFunc=RweaveEvalWithOpt)
{
    ## Return a function suitable as the 'runcode' element
    ## of an Sweave driver.  evalFunc will be used for the
    ## actual evaluation of chunk code.
    RweaveLatexRuncode <- function(object, chunk, options)
      {
          if(!(options$engine %in% c("R", "S"))){
              return(object)
          }

          if(!object$quiet){
              cat(formatC(options$chunknr, width=2), ":")
              if(options$echo) cat(" echo")
              if(options$keep.source) cat(" keep.source")
              if(options$eval){
                  if(options$print) cat(" print")
                  if(options$term) cat(" term")
                  cat("", options$results)
                  if(options$fig){
                      if(options$eps) cat(" eps")
                      if(options$pdf) cat(" pdf")
                  }
              }
              if(!is.null(options$label))
                cat(" (label=", options$label, ")", sep="")
              cat("\n")
          }

          chunkprefix <- RweaveChunkPrefix(options)

          if(options$split){
              ## [x][[1L]] avoids partial matching of x
              chunkout <- object$chunkout[chunkprefix][[1L]]
              if(is.null(chunkout)){
                  chunkout <- file(paste(chunkprefix, "tex", sep="."), "w")
                  if(!is.null(options$label))
                    object$chunkout[[chunkprefix]] <- chunkout
              }
          }
          else
            chunkout <- object$output
		
		# Pull in non-standard opts.
		options <- c( options, options('wrapinput','wrapoutput') )	

	  saveopts <- options(keep.source=options$keep.source)
	  on.exit(options(saveopts))

          SweaveHooks(options, run=TRUE)

          chunkexps <- try(parse(text=chunk), silent=TRUE)
          RweaveTryStop(chunkexps, options)
          openSinput <- FALSE
          openSchunk <- FALSE

          if(length(chunkexps) == 0L)
            return(object)

          srclines <- attr(chunk, "srclines")
          linesout <- integer(0L)
          srcline <- srclines[1L]

	  srcrefs <- attr(chunkexps, "srcref")
	  if (options$expand)
	    lastshown <- 0L
	  else
	    lastshown <- srcline - 1L
	  thisline <- 0
          for(nce in 1L:length(chunkexps))
            {
                ce <- chunkexps[[nce]]
                if (nce <= length(srcrefs) && !is.null(srcref <- srcrefs[[nce]])) {
                    if (options$expand) {
                	srcfile <- attr(srcref, "srcfile")
                	showfrom <- srcref[1L]
                	showto <- srcref[3L]
                    } else {
                    	srcfile <- object$srcfile
                    	showfrom <- srclines[srcref[1L]]
                    	showto <- srclines[srcref[3L]]
                    }
                    dce <- getSrcLines(srcfile, lastshown+1, showto)
	    	    leading <- showfrom-lastshown
	    	    lastshown <- showto
                    srcline <- srclines[srcref[3L]]
                    while (length(dce) && length(grep("^[[:blank:]]*$", dce[1L]))) {
	    		dce <- dce[-1L]
	    		leading <- leading - 1L
	    	    }
	    	} else {
                    dce <- deparse(ce, width.cutoff=0.75*getOption("width"))
                    leading <- 1L
                }
                if(object$debug)
                  cat("\nRnw> ", paste(dce, collapse="\n+  "),"\n")
                if(options$echo && length(dce)){
                    if(!openSinput){
                        if(!openSchunk){
														if( is.null( options$chunktitle ) && 
															is.null(options$chunkfooter) ){
                             cat("\\begin{Schunk}[]\n",
                                file=chunkout, append=TRUE)
														}else{
															
															tikzOpts <- '\\begin{Schunk}['

															if( !is.null( options$chunktitle ) ){
																tikzOpts <- paste(tikzOpts,'title={',
																	options$chunktitle,'}',sep='')
															}[]

															if( !is.null( options$chunktitle )  &&
																!is.null( options$chunkfooter ) ){
																
																tikzOpts <- paste(tikzOpts,',',sep='')

															}

															if( !is.null( options$chunkfooter ) ){
																
																tikzOpts <- paste(tikzOpts,'footer={',
																	options$chunkfooter,'}',sep='')

															}

															tikzOpts <- paste(tikzOpts,']\n',sep='')

															cat(tikzOpts,file=chunkout,append=T)

														}	

                            linesout[thisline + 1] <- srcline
                            thisline <- thisline + 1
                            openSchunk <- TRUE
														firstChunkLine <- TRUE
                        }
												if( !is.null(options$wrapinput) ){
                        	cat( options$wrapinput[1],
                            file=chunkout, append=TRUE)
												}
                        openSinput <- TRUE
                    }
		    if( firstChunkLine ) {
					cat(paste(dce[1L:leading], sep="", collapse="\n"),
		    		file=chunkout, append=TRUE, sep="")
					firstChunkLine <- FALSE
				}else{
					cat("\n", paste(dce[1L:leading], sep="", collapse="\n"),
		    		file=chunkout, append=TRUE, sep="")
				}
                    if (length(dce) > leading)
                    	cat("\n", paste( dce[-(1L:leading)], sep="", collapse="\n"),
                    	    file=chunkout, append=TRUE, sep="")
		    linesout[thisline + 1L:length(dce)] <- srcline
		    thisline <- thisline + length(dce)
                }

                                        # tmpcon <- textConnection("output", "w")
                                        # avoid the limitations (and overhead) of output text connections
                tmpcon <- file()
                sink(file=tmpcon)
                err <- NULL
                if(options$eval) err <- evalFunc(ce, options)
                cat("\n") # make sure final line is complete
                sink()
                output <- readLines(tmpcon)
                close(tmpcon)
                ## delete empty output
                if(length(output) == 1L & output[1L] == "") output <- NULL

                RweaveTryStop(err, options)

                if(object$debug)
                  cat(paste(output, collapse="\n"))

                if(length(output) & (options$results != "hide")){

                    if(openSinput){
												if( !is.null(options$wrapinput) ){
                          cat(options$wrapinput[2], file=chunkout, append=TRUE)
												}
                        linesout[thisline + 1L:2L] <- srcline
                        thisline <- thisline + 2L
                        openSinput <- FALSE
                    }
                    if(options$results=="verbatim"){
                        if(!openSchunk){
														if( is.null( options$chunktitle ) && 
															is.null(options$chunkfooter) ){
                             cat("\\begin{Schunk}[]\n",
                                file=chunkout, append=TRUE)
														}else{
															
															tikzOpts <- '\\begin{Schunk}['

															if( !is.null( options$chunktitle ) ){
																tikzOpts <- paste(tikzOpts,'title={',
																	options$chunktitle,'}',sep='')
															}

															if( !is.null( options$chunktitle )  &&
																!is.null( options$chunkfooter ) ){
																
																tikzOpts <- paste(tikzOpts,',',sep='')

															}

															if( !is.null( options$chunkfooter ) ){
																
																tikzOpts <- paste(tikzOpts,'footer={',
																	option$chunkfooter,'}',sep='')

															}

															tikzOpts <- paste(tikzOpts,']\n',sep='')

															cat(tikzOpts,file=chunkout,append=T)

														}	
		
                            linesout[thisline + 1L] <- srcline
                            thisline <- thisline + 1L
                            openSchunk <- TRUE
														firstChunkLine <- TRUE
                        }
												if( !is.null(options$wrapoutput) ){
                        	cat(options$wrapoutput[1],
                            file=chunkout, append=TRUE)
												}
                        linesout[thisline + 1L] <- srcline
                        thisline <- thisline + 1L
                    }

                    output <- paste(output,collapse="\n")
                    if(options$strip.white %in% c("all", "true")){
                        output <- sub("^[[:space:]]*\n", "", output)
                        output <- sub("\n[[:space:]]*$", "", output)
                        if(options$strip.white=="all")
                          output <- sub("\n[[:space:]]*\n", "\n", output)
                    }
                    cat(output, file=chunkout, append=TRUE)
                    count <- sum(strsplit(output, NULL)[[1L]] == "\n")
                    if (count > 0L) {
                    	linesout[thisline + 1L:count] <- srcline
                    	thisline <- thisline + count
                    }

                    remove(output)

                    if(options$results=="verbatim"){
												if( !is.null(options$wrapoutput) ){
                        	cat(options$wrapoutput[2], file=chunkout, append=TRUE)
												}
                        linesout[thisline + 1L:2] <- srcline
                        thisline <- thisline + 2L
                    }
                }
            }

          if(openSinput){
							if( !is.null(options$wrapinput) ){
              	cat(options$wrapinput[2], file=chunkout, append=TRUE)
							}
              linesout[thisline + 1L:2L] <- srcline
              thisline <- thisline + 2L
          }

          if(openSchunk){
              cat("\\end{Schunk}\n", file=chunkout, append=TRUE)
              linesout[thisline + 1L] <- srcline
              thisline <- thisline + 1L
          }

          if(is.null(options$label) & options$split)
            close(chunkout)

          if(options$split & options$include){
              cat("\\input{", chunkprefix, "}\n", sep="",
                file=object$output, append=TRUE)
              linesout[thisline + 1L] <- srcline
              thisline <- thisline + 1L
          }

          if(options$fig && options$eval){
              if(options$eps){
                  grDevices::postscript(file=paste(chunkprefix, "eps", sep="."),
                                        width=options$width, height=options$height,
                                        paper="special", horizontal=FALSE)

                  err <- try({SweaveHooks(options, run=TRUE)
                              eval(chunkexps, envir=.GlobalEnv)})
                  grDevices::dev.off()
                  if(inherits(err, "try-error")) stop(err)
              }
              if(options$pdf){
                  grDevices::pdf(file=paste(chunkprefix, "pdf", sep="."),
                                 width=options$width, height=options$height,
                                 version=options$pdf.version,
                                 encoding=options$pdf.encoding)

                  err <- try({SweaveHooks(options, run=TRUE)
                              eval(chunkexps, envir=.GlobalEnv)})
                  grDevices::dev.off()
                  if(inherits(err, "try-error")) stop(err)
              }
              if(options$include) {
                  cat("\\includegraphics{", chunkprefix, "}\n", sep="",
                      file=object$output, append=TRUE)
                  linesout[thisline + 1L] <- srcline
                  thisline <- thisline + 1L
              }
          }
          object$linesout <- c(object$linesout, linesout)
          return(object)
      }
    RweaveLatexRuncode
}

patchedOptionsChecker <- function(options)
{

    ## ATTENTION: Changes in this function have to be reflected in the
    ## defaults in the init function!

    ## convert a character string to logical
    c2l <- function(x){
        if(is.null(x)) return(FALSE)
        else return(as.logical(toupper(as.character(x))))
    }

    NUMOPTS <- c("width", "height")
    NOLOGOPTS <- c(NUMOPTS, "results", "prefix.string",
                   "engine", "label", "strip.white",
                   "pdf.version", "pdf.encoding",
									 "chunktitle", "chunkfooter")

    for(opt in names(options)){
        if(! (opt %in% NOLOGOPTS)){
            oldval <- options[[opt]]
            if(!is.logical(options[[opt]])){
                options[[opt]] <- c2l(options[[opt]])
            }
            if(is.na(options[[opt]]))
                stop(gettextf("invalid value for '%s' : %s", opt, oldval),
                     domain = NA)
        }
        else if(opt %in% NUMOPTS){
            options[[opt]] <- as.numeric(options[[opt]])
        }
    }

    if(!is.null(options$results))
        options$results <- tolower(as.character(options$results))
    options$results <- match.arg(options$results,
                                 c("verbatim", "tex", "hide"))

    if(!is.null(options$strip.white))
        options$strip.white <- tolower(as.character(options$strip.white))
    options$strip.white <- match.arg(options$strip.white,
                                     c("true", "false", "all"))

    options
}

#!/usr/bin/env Rscript

library(tikzDevice)
library(getopt)

#Column 3: Argument mask of the flag. An integer. Possible values: 
# 0=no argument, 1=required argument, 2=optional argument. 
optspec <- matrix(c('output-prefix', 'p', 2, "character"),ncol=4,byrow=T)

#parse the command line arguments
opt <- getopt(optspec)

prefix <- ifelse(!is.null(opt$"output-prefix"),opt$"output-prefix",'.')

tests <- list(

function(main){
    #test a circle and some simple text
    plot(1, axes=F, xlab='', ylab='', main=main)
    text(1, 1.1, 'Some Text')
},

function(main){
    #test a rectangular box
    plot(1, type='n', axes=F, main=main)
    box()
},

# Test of text color.
function(main){
    plot(1, type='n', main=main)
    text(0.8,0.8,'red',col='red')
		text(1.2,1.2,'blue',col='blue',cex=2)
},

# Plotting test- with legend
function(main){

	plot(1,1, xlim=c(0,10), ylim=c(0,10), main=main)

	legend( x='top', title='Legend Test', legend=c('Hello, world!'), inset=0.05 )

	legend( 6, 4, title='Another Legend Test', legend=c('Test 1','Test 2'), pch=c(1,16))
    
},

# Plotting test- pch values 0-25

function(main){

	# Magic stuff taken from example(points)
	n <- floor(sqrt(26))
	npchIndex <- 0:(25)

	ix <- npchIndex %/% n
	iy <- 3 + (n-1) - npchIndex %% n

	rx <- c(-1,1)/2 + range(ix)
	ry <- c(-1,1)/2 + range(iy)

	# Set up plot area
	plot(rx, ry, type="n", axes=F, xlab='', ylab='', main=main, sub="Standard R plotting characters")

	# Plot characters.
	for( i in 1:26 ){
		
		points(ix[i], iy[i], pch=i-1)
		# Place text label so we know which character is being plotted.
		text(ix[i]-0.3, iy[i], i-1 )

	}

},

#tests a outline colored circle
function(main){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(10), rnorm(10), col = "red")
    points(rnorm(10)/2, rnorm(10)/2, col = "blue")
},

#test for filled circle color
function(main){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(10), rnorm(10), pch=21, col='blue', bg='forestgreen')
},

#test for a colored line
function(main){
    plot(c(0,1), c(0,1), type = "l", axes=F, 
            xlab='', ylab='', col='red3', main=main)
},


#tests cex, there is actually nothing in the tikzDevice that handles this
function(main){
    plot(1, axes=F, xlab='', ylab='', cex=10, main=main)
    points(1, cex=.5)
},

#test for filled color rectangle
function(main){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(10), rnorm(10), pch=22, col='red', bg='gold')
},

#test for line types
function(main){
    plot(0, type='n', xlim=c(0,1), ylim=c(0,6), 
            axes=F, xlab='', ylab='', main=main)
    for(i in 0:6)
    	lines(c(0, 1), c(i, i), lty=i)
},

#test for line weight
function(main){
    plot(0, type='n', xlim=c(0,1), ylim=c(0,6), 
            axes=F, xlab='', ylab='', main=main)
    for(i in 0:6)
    	lines(c(0,1), c(i,i), lwd=i)
},

#test for transparency
function(main){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(50), rnorm(50), pch=21, bg=rainbow(50,alpha=.5), cex=10)
},

#test of many points for file size
function(main){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(500), rnorm(500), pch=21, bg=rainbow(50,alpha=.5), cex=10)
},

# Test with many strings and complex clipping from help(contour)
function(main){
    x <- -6:16
    op <- par(mfrow = c(2, 2))
    contour(outer(x, x), method = "edge")
    z <- outer(x, sqrt(abs(x)), FUN = "/")
    image(x, x, z)
    contour(x, x, z, col = "pink", add = TRUE, method = "edge")
    contour(x, x, z, ylim = c(1, 6), method = "simple", labcex = 1)
    contour(x, x, z, ylim = c(-6, 6), nlev = 20, lty = 2, method = "simple")
    par(op)
},

# test for string placement, symbol should be centered on point
function(main){

    syms <-c('alpha','theta','tau','beta','vartheta','pi','upsilon',
    		  'gamma','gamma','varpi','phi','delta','kappa','rho','varphi',
    		  'epsilon','lambda','varrho','chi','varepsilon','mu','sigma',
    		  'psi','zeta','nu','varsigma','omega','eta','xi','Gamma',
    		  'Lambda','Sigma','Psi','Delta','Xi','Upsilon','Omega',
    		  'Theta','Pi','Phi')
    x <- rnorm(length(syms))
    y <- rnorm(length(syms))
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(x, y, pch=21,  bg='black', cex=.5)
    text(x,y,paste('\\Large$\\',syms,'$',sep=''))
    
},

# Three dimensional plotting test- taken from a persp example.
function(main){

	x <- seq( -1.95, 1.95, length=30 )
	y <- seq( -1.95, 1.95, length=35 )

	z <- outer( x, y, function(a,b){ a*b^2 } )

	nrz <- nrow(z)
	ncz <- ncol(z)

	jet.colors <- colorRampPalette( c("blue", "green") )

	nbcol <- 100

	color <- jet.colors(nbcol)

	zfacet <- z[-1,-1] + z[-1,-ncz] + z[-nrz, -1] + z[-nrz, -ncz]
	facetcol <- cut(zfacet, nbcol)

	persp(x, y, z, col=color[facetcol], phi=30, theta=-30, ticktype='detailed', main=main )
    
},

# Neat example of image.plot using the fields package.
function(main){

	sink('/dev/null')
	require(fields)
	sink()
	data(RCMexample)

	image.plot( RCMexample$x, RCMexample$y, RCMexample$z[,,8], main=main )

}

## ADD NEW TESTS HERE

)# End of test function list

#Run the tests

output.list <- c()

for(i in 1:length(tests)){
    cat("Running Test",sprintf('%02d',i),"... ")
    this.testfile <- file.path(prefix,
      paste('test',sprintf('%02d',i),'.tex',sep=''))
    t <- system.time(
    {
        tikz(this.testfile,standAlone=T)
        tests[[i]](main=paste('Test',i))
        dev.off()
    })
    last.line <- length(count.fields(this.testfile,blank.lines.skip=F))
    info.line <- scan(this.testfile,skip=(last.line-1),
                        nlines=1,what='character',sep='?',quiet=T)
    cat("Done, took ",t[['elapsed']],"seconds.\n")
    if(!(info.line == "\\end{document}")){
        # then debugging is turned on 
        cat(info.line,'\n\n')
    }

		# Compile the resulting TeX file.
		silence <- system( paste(Sys.getenv("R_PDFLATEXCMD"),'-output-directory',prefix,
			this.testfile), intern=T )

    this.testfile <- file.path(prefix,
			paste('test',sprintf('%02d',i),'.pdf',sep=''))

		# Reproduce the plot using pdf() as a control.
		this.controlfile <- file.path(prefix,
			paste('control',sprintf('%02d',i),'.pdf',sep=''))
		pdf( this.controlfile )
		tests[[i]](main=paste('Control',i))
		dev.off()

		# Commented Out ImageMagick comparison-- it doesn't seem to serve
		# much purpose comparing the output of pdf() and tikz() is like comparing
		# apples to oranges.

		#  # Create a diff between the two files using ImageMagick's compare utility.
		#  this.diffile <- file.path(prefix,
		#  	paste('diff',sprintf('%02d',i),'.pdf',sep=''))

		#  silence <- system( paste('compare',this.testfile,
		#  	this.controlfile,
		#  	this.diffile), intern=T )

		# Add file names to output list.
		output.list <- c( output.list, this.testfile, this.controlfile )

}

# calculate the file sizes of the output files
f <- 'filesizes.txt'
texfiles <- list.files(prefix,'tex')
newsizes <- file.info(file.path(prefix,texfiles))$size
cat(paste(texfiles,newsizes,sep='\t'),sep='\n',file=f)

# Combine the output files into summary PDFs.
silence <- system( paste('gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=compares.pdf -dBATCH',
	paste(output.list,collapse=' ') ), intern=T, ignore.stderr=T)

# Combine only the test files.
silence <- system( paste('gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=tests.pdf -dBATCH',
	paste(output.list[seq(1,length(output.list),2)],collapse=' ') ), intern=T, ignore.stderr=T)

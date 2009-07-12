#!/usr/bin/env Rscript

library(tikzDevice)
library(getopt)

#Column 3: Argument mask of the flag. An integer. Possible values: 
# 0=no argument, 1=required argument, 2=optional argument. 
optspec <- matrix(c('output-prefix', 'p', 2, "character"),ncol=4,byrow=T)

#parse the command line arguments
opt <- getopt(optspec)

prefix <- ifelse(!is.null(opt$"output-prefix"),opt$"output-prefix",'.')

tests <- list()

tests[[1]] <- function(main="test01"){
    #test a circle and some simple text
    plot(1, axes=F, xlab='', ylab='', main=main)
    text(1, 1.1, 'Some Text')
}

tests[[2]] <- function(main='test02'){
    #test a rectangular box
    plot(1, type='n', axes=F, main=main)
    box()
}

#tests a outline colored circle
tests[[3]] <- function(main='test03'){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(10), rnorm(10), col = "red")
    points(rnorm(10)/2, rnorm(10)/2, col = "blue")
}

#test for filled circle color
tests[[4]] <- function(main='test04'){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(10), rnorm(10), pch=21, col='blue', bg='forestgreen')
}

#test for a colored line
tests[[5]] <- function(main='test05')
    plot(c(0,1), c(0,1), type = "l", axes=F, 
            xlab='', ylab='', col='red3', main=main)


#tests cex, there is actually nothing in the tikzDevice that handles this
# all the work is done by the graphics engine
tests[[6]] <- function(main='test06'){
    plot(1, axes=F, xlab='', ylab='', cex=10, main=main)
    points(1, cex=.5)
}

#test for filled color rectangle
tests[[7]] <- function(main='test07'){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(10), rnorm(10), pch=22, col='red', bg='gold')
}

#test for line types
tests[[8]] <- function(main='test08'){
    plot(0, type='n', xlim=c(0,1), ylim=c(0,6), 
            axes=F, xlab='', ylab='', main=main)
    for(i in 0:6)
    	lines(c(0, 1), c(i, i), lty=i)
}

#test for line weight
tests[[9]] <- function(main='test09'){
    plot(0, type='n', xlim=c(0,1), ylim=c(0,6), 
            axes=F, xlab='', ylab='', main=main)
    for(i in 0:6)
    	lines(c(0,1), c(i,i), lwd=i)
}

#test for transparency
tests[[10]] <- function(main='test10'){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(50), rnorm(50), pch=21, bg=rainbow(50,alpha=.5), cex=10)
}

#test of many points for file size
tests[[11]] <- function(main='test11'){
    plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main=main)
    points(rnorm(500), rnorm(500), pch=21, bg=rainbow(50,alpha=.5), cex=10)
}

# Test with many strings and complex clipping from help(contour)
tests[[12]] <- function(main='test12'){
    x <- -6:16
    op <- par(mfrow = c(2, 2))
    contour(outer(x, x), method = "edge")
    z <- outer(x, sqrt(abs(x)), FUN = "/")
    image(x, x, z)
    contour(x, x, z, col = "pink", add = TRUE, method = "edge")
    contour(x, x, z, ylim = c(1, 6), method = "simple", labcex = 1)
    contour(x, x, z, ylim = c(-6, 6), nlev = 20, lty = 2, method = "simple")
    par(op)
}

# test for string placement, symbol should be centered on point
tests[[13]] <- function(main='test13'){

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
    
}

## ADD NEW TESTS HERE

#Run the tests
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
                        nlines=1,what='character',quiet=T)
    cat("Done, took ",t[['elapsed']],"seconds.\n")
    if(!(info.line == "\\end{document}")){
        # then debugging is turned on 
        cat(info.line,'\n\n')
    }
}

# calculate the file sizes of the output files
f <- 'filesizes.txt'
texfiles <- list.files(prefix,'tex')
newsizes <- file.info(file.path(prefix,texfiles))$size
cat(paste(texfiles,newsizes,sep='\t'),sep='\n',file=f)
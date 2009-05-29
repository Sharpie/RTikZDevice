#!/usr/bin/env Rscript

library(tikzDevice)

#test a circle and some simple text
tikz('test01.tex', standAlone=T)
plot(1, axes=F, xlab='', ylab='', main='test01')
text(1, 1.1, 'Some Text')
dev.off()

#test a rectangular box
tikz('test02.tex', standAlone=T)
plot(1, type='n', axes=F, main='test02')
box()
dev.off()

#tests a outline colored circle
tikz('test03.tex', standAlone=T)
plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main='test03')
points(rnorm(10), rnorm(10), col = "red")
points(rnorm(10)/2, rnorm(10)/2, col = "blue")
dev.off()

#test for filled circle color
tikz('test04.tex', standAlone=T)
plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main='test04')
points(rnorm(10), rnorm(10), pch=21, col='blue', bg='forestgreen')
dev.off()

#test for a colored line
tikz('test05.tex', standAlone=T)
plot(c(0,1), c(0,1), type = "l", axes=F, xlab='', ylab='', col='red3', main='test05')
dev.off()

#tests cex, there is actually nothing in the tikzDevice that handles this
# all the work is done by the graphics engine
tikz('test06.tex', standAlone=T)
plot(1, axes=F, xlab='', ylab='', cex=10, main='test06')
points(1, cex=.5)
dev.off()

#test for filled color rectangle
tikz('test07.tex', standAlone=T)
plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main='test07')
points(rnorm(10), rnorm(10), pch=22, col='red', bg='gold')
dev.off()

#test for line types
tikz('test08.tex', standAlone=T)
plot(0, type='n', xlim=c(0,1), ylim=c(0,6), axes=F, xlab='', ylab='', main='test08')
for(i in 0:6)
	lines(c(0, 1), c(i, i), main='test08', lty=i)
dev.off()

#test for line weight
tikz('test09.tex', standAlone=T)
plot(0, type='n', xlim=c(0,1), ylim=c(0,6), axes=F, xlab='', ylab='', main='test09')
for(i in 0:6)
	lines(c(0,1), c(i,i), lwd=i)
dev.off()

#test for transparency
tikz('test10.tex', standAlone=T)
plot(-2:2, -2:2, type = "n", axes=F, xlab='', ylab='', main='test10')
points(rnorm(50), rnorm(50), pch=21, bg=rainbow(50,alpha=.5), cex=10)
dev.off()

f <- 'filesizes.txt'
texfiles <- list.files(,'tex')
newsizes <- file.info(texfiles)$size
cat(paste(texfiles,newsizes,sep='\t'),sep='\n',file=f)
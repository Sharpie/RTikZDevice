#!/usr/bin/env Rscript

library(tikzDevice)

#test a circle and some simple text
tikz('test01.tex',standAlone=T)
plot(1,axes=F,xlab='',ylab='',main='test01')
text(1,1.1,'Some Text')
dev.off()

#test a rectangular box
tikz('test02.tex',standAlone=T)
plot(1,type='n',axes=F,main='test02')
box()
dev.off()

#tests a outline colored circle
tikz('test03.tex',standAlone=T)
plot(-2:2, -2:2, type = "n",axes=F,xlab='',ylab='',main='test03')
points(rnorm(10), rnorm(10), col = "red")
points(rnorm(10)/2, rnorm(10)/2, col = "blue")
dev.off()

#test for filled circle color
tikz('test04.tex',standAlone=T)
plot(-2:2, -2:2, type = "n",axes=F,xlab='',ylab='',main='test04')
points(rnorm(10), rnorm(10), pch=21, col='blue',bg='forestgreen')
dev.off()

#test for a colored line
tikz('test05.tex',standAlone=T)
plot(c(0,1),c(0,1), type = "l",axes=F,xlab='',ylab='',col='red3',main='test05')
dev.off()

#tests cex, there is actually nothing in the tikzDevice that handles this
tikz('test06.tex',standAlone=T)
plot(1,axes=F,xlab='',ylab='',cex=10,main='test06')
points(1,cex=.5)
dev.off()

#test for filled color rectangle
tikz('test07.tex',standAlone=T)
plot(-2:2, -2:2, type = "n",axes=F,xlab='',ylab='',main='test07')
points(rnorm(10), rnorm(10), pch=22, col='red',bg='gold')
dev.off()

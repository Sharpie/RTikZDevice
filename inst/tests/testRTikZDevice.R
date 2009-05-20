#!/usr/bin/env Rscript

library(tikzDevice)

tikz('test1.tex',standAlone=T)
plot(1,axes=F,xlab='X Axis',ylab='Y Axis')
dev.off()

tikz('test2.tex',standAlone=T)
plot(1)
dev.off()

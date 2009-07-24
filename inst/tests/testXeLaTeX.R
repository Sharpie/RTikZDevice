#!/usr/bin/env Rscript
require(tikzDevice)

prefix <- 'output'
this.testfile <- 'testXeLaTeX.tex'

setopts <- function(){
	options(tikzLatex = 'xelatex')
	options(tikzDocumentDeclaration = '\\documentclass{article}')
	options( tikzLatexPackages = c(
		"\\usepackage{fontspec}"
		,"\\usepackage[dvipdfm, colorlinks, breaklinks, pdftitle={The Beauty of LaTeX},pdfauthor={Taraborelli, Dario}]{hyperref}"
		,"\\usepackage{tikz}"
		,"\\usepackage{color}"
		,"\\definecolor{Gray}{rgb}{.7,.7,.7}"
		,"\\definecolor{lightblue}{rgb}{.2,.5,1}"
		,"\\definecolor{myred}{rgb}{1,0,0}"
		,"\\newcommand{\\red}[1]{\\color{myred} #1}"
		,"\\newcommand{\\reda}[1]{\\color{myred}\\fontspec[Variant=2]{Zapfino}#1}"
		,"\\newcommand{\\redb}[1]{\\color{myred}\\fontspec[Variant=3]{Zapfino}#1}"
		,"\\newcommand{\\redc}[1]{\\color{myred}\\fontspec[Variant=4]{Zapfino}#1}"
		,"\\newcommand{\\redd}[1]{\\color{myred}\\fontspec[Variant=5]{Zapfino}#1}"
		,"\\newcommand{\\rede}[1]{\\color{myred}\\fontspec[Variant=6]{Zapfino}#1}"
		,"\\newcommand{\\redf}[1]{\\color{myred}\\fontspec[Variant=7]{Zapfino}#1}"
		,"\\newcommand{\\redg}[1]{\\color{myred}\\fontspec[Variant=8]{Zapfino}#1}"
		,"\\newcommand{\\lbl}[1]{\\color{lightblue} #1}"
		,"\\newcommand{\\lbla}[1]{\\color{lightblue}\\fontspec[Variant=2]{Zapfino}#1}"
		,"\\newcommand{\\lblb}[1]{\\color{lightblue}\\fontspec[Variant=3]{Zapfino}#1}"
		,"\\newcommand{\\lblc}[1]{\\color{lightblue}\\fontspec[Variant=4]{Zapfino}#1}"
		,"\\newcommand{\\lbld}[1]{\\color{lightblue}\\fontspec[Variant=5]{Zapfino}#1}"
		,"\\newcommand{\\lble}[1]{\\color{lightblue}\\fontspec[Variant=6]{Zapfino}#1}"
		,"\\newcommand{\\lblf}[1]{\\color{lightblue}\\fontspec[Variant=7]{Zapfino}#1}"
		,"\\newcommand{\\lblg}[1]{\\color{lightblue}\\fontspec[Variant=8]{Zapfino}#1}"
		,"\\newcommand{\\old}[1]{"
		,"\\fontspec[Ligatures={Common, Rare},Variant=1,Swashes={LineInitial, LineFinal}]{Zapfino}"
		,"\\fontsize{25pt}{30pt}\\selectfont #1}%"
		,"\\newcommand{\\smallprint}[1]{\\fontspec{Hoefler Text}\\fontsize{10pt}{13pt}\\color{Gray}\\selectfont #1}%"
		))
	
}
x <- function(){
	label <- c(  
		"\\noindent{\\red d}roo{\\lbl g}"
		,"\\noindent{\\reda d}roo{\\lbla g}"
		,"\\noindent{\\redb d}roo{\\lblb g}"
		,"\\noindent{\\redf d}roo{\\lblf g}\\\\[.3cm]"
		,"\\noindent{\\redc d}roo{\\lblc g}"
		,"\\noindent{\\redd d}roo{\\lbld g}"
		,"\\noindent{\\rede d}roo{\\lble g}"
		,"\\noindent{\\redg d}roo{\\lblg g}\\\\[.2cm]"
	)
	title <- c(
		"\\smallprint{D. Taraborelli (2008), \\href{http://nitens.org/taraborelli/latex}{The Beauty of \\LaTeX}}"
		,"\\smallprint{\\\\\\emph{Some rights reserved}. \\href{http://creativecommons.org/licenses/by-sa/3.0/}{\\textsc{cc-by-sa}}}"
	)
lim <- 0:(length(label)+1)
plot(lim,lim,cex=0,pch='.',xlab = 'XeLaTeX Test',ylab='', main = title[1], sub = title[2])
for(i in 1:length(label))
	text(i,i,label[i])


}

setopts()

cat("  Running XeLaTeX Test ... ")
t <- system.time(
{
	tikz(file.path(prefix,this.testfile),standAlone=T,width=5,height=5)
	x()
	dev.off()
})
cat("Done, took ",t[['elapsed']],"seconds.\n")

# Compile the resulting TeX file.
cat("Compiling XeLaTeX Test ... ")
t <- system.time(
{
	silence <- system( paste('xelatex -output-directory', 
		prefix, this.testfile), intern = T)
})
cat("Done, took ",t[['elapsed']],"seconds.\n")
success <- file.copy(file.path(prefix,
				paste(strsplit(this.testfile,'\\.tex'),'pdf',sep='.')),'.',
				overwrite = T)

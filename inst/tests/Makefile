
all:
	R CMD INSTALL ../../
	Rscript testRTikZDevice.R
	pdflatex *.tex

clean:
	rm *.{tex,log,pdf,aux}

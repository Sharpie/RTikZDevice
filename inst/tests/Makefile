all: install tests pdfs

install: 
	R CMD INSTALL ../../

tests:
	Rscript testRTikZDevice.R 

pdfs:
	for i in $(shell ls *.tex) ; do pdflatex $$i ; done
	gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=tests.pdf -dBATCH *.pdf
	@echo
	@echo --------------------------------------------
	@echo All Tests ran successfully and combined into
	@echo tests.pdf, look at the pdfs for wierdness.
	@echo --------------------------------------------

clean:
	rm *.{tex,log,pdf,aux}

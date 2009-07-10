#!/bin/bash

OUTDIR=output/

#
rm $OUTDIR*.{tex,log,pdf,aux}

# Install the package so changes update
R CMD INSTALL ../../

# Run the test suite
mkdir $OUTDIR
Rscript testRTikZDevice.R --output-prefix=$OUTDIR

# compile the tex files
touch tests.pdf
rm tests.pdf
cd $OUTDIR
for i in $(ls *.tex)
do
	echo Compiling test $i
	pdflatex $i >log
done
cd ../
gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=tests.pdf -dBATCH $OUTDIR*.pdf

#clean up a bit
rm str-width.{tex,log}

echo
echo --------------------------------------------
echo All Tests ran successfully and combined into
echo tests.pdf, look at the pdfs for wierdness.
echo --------------------------------------------

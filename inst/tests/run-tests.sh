#!/bin/bash -e

OUTDIR=output/

#
touch $OUTDIR/foo.{tex,log,pdf,aux}
rm $OUTDIR*.{tex,log,pdf,aux}

# Install the package so changes update
R CMD INSTALL ../../

# Run the test suite
rm -rf $OUTDIR
mkdir $OUTDIR

Rscript testRTikZDevice.R --output-prefix=$OUTDIR

# compile the tex files
touch tests.pdf
rm tests.pdf
cd $OUTDIR
for i in $(ls *.tex)
do
	echo Compiling test $i
	# create a temporary file with 100 r's to pipe to latex if there is an 
	# error, 100 is the max errors in latex. this way the tests wont hang when 
	# compiling and we dont have to see all of the output.
	jot -b r 100 > tempfile
	pdflatex $i < tempfile > log
done
cd ../
gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=tests.pdf -dBATCH $OUTDIR*.pdf

#clean up a bit
#rm str-width.{tex,log}

echo
echo --------------------------------------------
echo All Tests ran successfully and combined into
echo tests.pdf, look at the pdfs for wierdness.
echo --------------------------------------------

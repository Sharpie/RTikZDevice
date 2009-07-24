#!/bin/bash -e

OUTDIR=output

# wipe the output directory and old builds
rm -rf $OUTDIR
rm -rf tikzDevice_*
mkdir $OUTDIR

# Install the package so changes update
R CMD BUILD ../../
R CMD INSTALL tikzDevice_*.tar.gz

# Run the test suite
Rscript testRTikZDevice.R --output-prefix=$OUTDIR

echo
echo --------------------------------------------
echo All Tests ran successfully and combined into
echo tests.pdf, look at the pdfs for wierdness.
echo --------------------------------------------

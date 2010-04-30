@echo off
setlocal

set OUTDIR=output

rem %OUTDIR% should be empty
if not exist %OUTDIR% md %OUTDIR%
dir %OUTDIR% | findstr.exe /i /c:"0 File(s)" >nul 2>&1
if errorlevel 1 (echo Delete files in folder "%OUTDIR%" and rerun) & goto:eof
del tikzDevice_*

rem # Install the package so changes update
echo if tikzDevice R package is not installed then install it like this:
echo   Rcmd BUILD ../../ 
echo   Rcmd INSTALL tikzDevice_*.tar.gz

rem Run the test suite
Rscript testRTikZDevice.R --output-prefix=%OUTDIR%

echo
echo --------------------------------------------
echo All Tests ran successfully and combined into
echo tests.pdf, look at the pdfs for wierdness.
echo --------------------------------------------

/* Declarations for functions provided by the R language */
#include "Rinternals.h"
#include "R_ext/GraphicsEngine.h"


SEXP pgfDevice ( SEXP args ){

	/*
	 * Make sure the version number of the R running this
	 * routine is compatible with the version number of 
	 * the R that compiled this routine.
	*/
	R_GE_checkVersionOrDie(R_GE_version);

	/* Declare local variabls for holding function arguments. */
	const char *fileName;

	/*
	 * Skip first argument. It holds the name of the R function
	 * that called this C routine.
  */ 
	args = CDR(args);

	/* Retrieve function arguments from input SEXP. */

	/* Recover file name. */
	fileName = translateChar(asChar(CAR(args)));
	/* Advance to next argument stored in SEXPR. */
	args = CDR(args);

	/* Attempt to open file. */
	FILE *testFile;
	testFile = R_fopen(R_ExpandFileName(fileName), "w");

	/* Print test string and close. */
	fprintf( testFile, "Hello, world!");
	fclose( testFile);

	return R_NilValue;
}

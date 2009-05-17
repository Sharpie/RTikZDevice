
/* 
 * Function prototypes are defined in here. Apparently in C
 * it is absolutely necessary for function definitions to appear 
 * BEFORE they are called by other functions. Hence many source code
 * files do not present code in the order in which that code
 * is used. Using a header file with function declarations allows
 * the programmer to order the code in any sequence they choose.
 *
 * NOTE:
 * 	This is the first effort of a dyed-in-the-wool Fortran programmer
 * 	to write C code. Hence the comments in this file will make many
 * 	observations that may seem obvious. There also may be a generous
 * 	amount of snide comments concerning the syntax of the C language.
 *
 * This header also includes other header files describing functions 
 * provided by the R language.
*/
#include "tikzDevice.h"

SEXP tikzDevice ( SEXP args ){

	/*
	 * Make sure the version number of the R running this
	 * routine is compatible with the version number of 
	 * the R that compiled this routine.
	*/
	R_GE_checkVersionOrDie(R_GE_version);

	/* Declare local variabls for holding function arguments. */
	const char *fileName;

	/* 
	 * pGEDevDesc is a variable provided by the R Graphics Engine
	 * that contains all device information required by the parent
	 * R system. It contains one important componant of type pDevDesc
	 * which containts information specific to the implementation of
	 * the tikz device. The creation and initialization of this component
	 * is one ofthe main tasks of this routine.
  */
	pGEDevDesc tikzDev;



	/* Retrieve function arguments from input SEXP. */

	/*
	 * Skip first argument. It holds the name of the R function
	 * that called this C routine.
  */ 
	args = CDR(args);

	/* Recover file name. */
	fileName = translateChar(asChar(CAR(args)));
	/* Advance to next argument stored in SEXPR. */
	args = CDR(args);

	/* Ensure there is an empty slot avaliable for a new device. */
	R_CheckDeviceAvailable();

	BEGIN_SUSPEND_INTERRUPTS{

		/* 
		 * The pDevDesc variable specifies which funtions and components 
		 * which describe the specifics of this graphics device. After
     * setup, this information will be incorporated into the pGEDevDesc
		 * variable tikzDev.
	  */ 
		pDevDesc deviceInfo;

		/* 
		 * Create the deviceInfo variable. If this operation fails, 
		 * a 0 is returned in order to cause R to shut down due to the
		 * possibility of corrupted memory.
	  */
		if( !( deviceInfo = (pDevDesc) calloc(1, sizeof(DevDesc))) )
			return 0;

		/*
		 * Call setup routine to initialize deviceInfo and associate
		 * R graphics function hooks with the appropriate C routines
		 * in this file.
		*/
		if( !tikzDeviceSetup( deviceInfo, fileName ) ){
			/* 
			 * If setup was unsuccessful, destroy the device and return
			 * an error message.
			*/
			free( deviceInfo );
			error("TikZ device setup was unsuccessful!");
		}

		/* Create tikzDev as a Graphics Engine device using deviceInfo. */
		tikzDev = GEcreateDevDesc( deviceInfo );

		GEaddDevice2( tikzDev, "tikz output" );

	} END_SUSPEND_INTERRUPTS;


	return R_NilValue;

}


/*
 * This function is responsible for initializing device parameters
 * contained in the variable deviceInfo. It returns a true or false
 * value depending on the success of initialization operations. The
 * static keyword means this function can only be seen by other functions
 * in this file. A better choice for the keyword might have been something
 * like "private"... 
*/

static Rboolean tikzDeviceSetup(
	pDevDesc deviceInfo,
	const char *fileName){

	/* 
	 * Create tikzInfo, this variable contains information which is
	 * unique to the implementation of the TikZ Device. The deviceInfo
	 * variable contains a slot into which tikzInfo can be placed so that
	 * this information persists and is retrievable during the lifespan
	 * of this device.
	 *
	 * tikzInfo is a structure which is defined in the file tikzDevice.h
	 *
	*/
	tikzDevDesc *tikzInfo;

	/* 
	 * Initialize tikzInfo, return false if this fails. A false return
	 * value will cause the whole device initialization routine to fail.
  */
	if( !( tikzInfo = (tikzDevDesc *) malloc(sizeof(tikzDevDesc)) ) )
		return FALSE;

	/* Copy information to the tikzInfo variable. */
	strcpy( tikzInfo->outFileName, fileName);

	/* Incorporate tikzInfo into deviceInfo. */
	deviceInfo->deviceSpecific = (void *) tikzInfo;

	/* 
	 * Connect R graphic function hooks to TikZ Routines. These routines
	 * are declared in tikzDevice.h and implenented later
   * on in this file. Each routine performs a specific
   * function such as adding text, drawing a line or
   * reporting or adjusting the status of the device.
	*/
	deviceInfo->close = TikZ_Close;
	deviceInfo->activate = TikZ_Activate;
	deviceInfo->deactivate = TikZ_Deactivate;

	/* Call TikZ_Open to create and initialize the output file. */
	if( !TikZ_Open( deviceInfo ) )
		return FALSE;

	return TRUE;

}


static Rboolean TikZ_Open( pDevDesc deviceInfo ){

	/* 
	 * Shortcut pointers to variables of interest. 
	 * It seems like there HAS to be a more elegent way of accesing
	 * these...
	*/
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	if( !( tikzInfo->outputFile = fopen(R_ExpandFileName(tikzInfo->outFileName), "w") ) )
		return FALSE;

	/* Start the tikz environment. */
	fprintf(tikzInfo->outputFile, "\\begin{tikzpicture}\n");

	return TRUE;

}

static void TikZ_Close( pDevDesc deviceInfo){

	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	/* End the tikz environment. */
	fprintf(tikzInfo->outputFile, "\\end{tikzpicture}\n");

	/* Close the file and destroy the tikzInfo structure. */
	fclose(tikzInfo->outputFile);
	free(tikzInfo);

}

/* 
 * Activate and deactivate execute commands when the active R device is changed.
 * For devices using plotting windows, these routines usually change the window
 * title to something like "Active" or "Inactive". For devices plotting to files
 * these functions are usually left as dummy routines.
*/
static void TikZ_Activate( pDevDesc deviceInfo ){}
static void TikZ_Deactivate( pDevDesc deviceInfo ){}

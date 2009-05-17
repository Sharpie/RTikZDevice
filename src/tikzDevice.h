/* Declarations for functions provided by the R language */
#include "R.h"
#include "Rinternals.h"
#include "R_ext/GraphicsEngine.h"

/*
 * tikzDevDesc is a structure that is used to hold information
 * that is unique to the implementation of the TikZ Device. A
 * new component may be created for any information that it is
 * deemed desirable to have available during execution of TikZ
 * Device routines.
*/

typedef struct{
	FILE *outputFile;
	char outFileName[128];
} tikzDevDesc;


/* Function Prototypes */

static Rboolean tikzDeviceSetup(
		pDevDesc deviceInfo,
		const char *fileName);

static Rboolean TikZ_Open( pDevDesc deviceInfo );
static void TikZ_Close( pDevDesc deviceInfo );
static void TikZ_Activate( pDevDesc deviceInfo );
static void TikZ_Deactivate( pDevDesc deviceInfo );

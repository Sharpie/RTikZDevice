/* Declarations for functions provided by the R language */


/*
 * There probably won't be more than one C source file using
 * this header, but it's still a good idea to make sure the
 * compiler will only include it once. Errors could result
 * otherwise.
*/

#ifndef HAVE_TIKZDEV_H

#define HAVE_TIKZDEV_H 

/* Use default graphics engine function declarations. */
#define R_USE_PROTOTYPES 1

#include <R.h>
#include <Rinternals.h>
#include <R_ext/GraphicsEngine.h>

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
	Rboolean firstPage;
	Rboolean debug;
	Rboolean standAlone;
	Rboolean firstClip;
	int oldFillColor;
	int oldDrawColor;
	int oldLineType;
	pGEcontext plotParams;
	int stringWidthCalls;
} tikzDevDesc;


/* Function Prototypes */

static Rboolean TikZ_Setup(
		pDevDesc deviceInfo,
		const char *fileName,
		double width, double height,
		const char *bg, const char *fg,
		Rboolean standAlone );

double dim2dev( double length );

static Rboolean TikZ_Open( pDevDesc deviceInfo );

/* Graphics Engine function hooks. Defined in GraphicsDevice.h . */

/* Utility routines. */
static void TikZ_Close( pDevDesc deviceInfo );
static void TikZ_NewPage( const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Clip( double x0, double x1,
		double y0, double y1, pDevDesc deviceInfo );
static void TikZ_Size( double *left, double *right,
		double *bottom, double *top, pDevDesc deviceInfo);


/* Text routines. */
static void TikZ_MetricInfo( int c, const pGEcontext plotParams,
		double *ascent, double *descent, double *width, pDevDesc deviceInfo );
static double TikZ_StrWidth( const char *str,
		const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Text( double x, double y, const char *str,
		double rot, double hadj, const pGEcontext plotParams, pDevDesc deviceInfo);


/* Drawing routines. */
static void TikZ_Line( double x1, double y1,
		double x2, double y2, const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Circle( double x, double y, double r,
		const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Rectangle( double x0, double y0, 
		double x1, double y1, const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Polyline( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Polygon( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo );
		
/*Internal style definition routines*/
static void StyleDef(Rboolean defineColor, const pGEcontext plotParams, 
	pDevDesc deviceInfo);
static void SetColor(int color, Rboolean def, pDevDesc deviceInfo);
static void SetFill(int color, Rboolean def, pDevDesc deviceInfo);
static void SetAlpha(int color, Rboolean fill, pDevDesc deviceInfo);
static void SetLineStyle(int lty, int lwd, pDevDesc deviceInfo);
static void SetDashPattern(int lty, FILE *outputFile);
static void SetLineWeight(int lwd, FILE *outputFile);
static void SetLineJoin(R_GE_linejoin ljoin, double lmitre, pDevDesc deviceInfo);
static void SetLineEnd(R_GE_linejoin lend, pDevDesc deviceInfo);
static void SetMitreLimit(double lmitre, FILE *outputFile);
static void TeXText(const char *str,  tikzDevDesc *tikzInfo);
static double GetLatexStringWidth(const char *str, tikzDevDesc *tikzInfo);


/* Dummy routines. */
static void TikZ_Activate( pDevDesc deviceInfo );
static void TikZ_Deactivate( pDevDesc deviceInfo );
static Rboolean TikZ_Locator( double *x, double *y, pDevDesc deviceInfo );
static void TikZ_Mode( int mode, pDevDesc deviceInfo );

#endif // End of Once Only header

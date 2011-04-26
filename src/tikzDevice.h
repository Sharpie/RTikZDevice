/*
 * There probably won't be more than one C source file using
 * this header, but it's still a good idea to make sure the
 * compiler will only include it once. Errors could result
 * otherwise.
*/

#ifndef HAVE_TIKZDEV_H // Begin once-only header
#define HAVE_TIKZDEV_H

#ifndef DEBUG
#define DEBUG FALSE
#endif

/* Use default graphics engine function declarations. */
#define R_USE_PROTOTYPES 1

/* Declarations for functions provided by the R language */
#include <R.h>
#include <Rinternals.h>
#include <R_ext/GraphicsEngine.h>

/* Check R Graphics Engine for minimum supported version */
#if R_GE_version < 6
#error "This version of the tikzDevice must be compiled against R 2.11.0 or newer!"
#endif

/* Macro definitions */
#define TIKZ_NAMESPACE eval(lang2(install("getNamespace"), mkString("tikzDevice")), R_GlobalEnv)


/*
 * tikz_engine can take on possible values from a list of all the TeX engines
 * we support.
 */
typedef enum {
  pdftex = 1,
  xetex = 2
} tikz_engine;


/*
 * tikzDevDesc is a structure that is used to hold information
 * that is unique to the implementation of the TikZ Device. A
 * new component may be created for any information that it is
 * deemed desirable to have available during execution of TikZ
 * Device routines.
*/
typedef struct {
	FILE *outputFile;
  char *outFileName;
  tikz_engine engine;
  int rasterFileCount;
	Rboolean firstPage;
	Rboolean debug;
	Rboolean standAlone;
	Rboolean bareBones;
	Rboolean firstClip;
	int oldFillColor;
	int oldDrawColor;
	int oldLineType;
	pGEcontext plotParams;
	int stringWidthCalls;
	const char *documentDeclaration;
	const char *packages;
	const char *footer;
	Rboolean polyLine;
	Rboolean console;
	Rboolean sanitize;
	Rboolean onefile;
  char *originalFileName;
  int pageNum;
} tikzDevDesc;


/* Function Prototypes */

/* Public Functions */
SEXP TikZ_StartDevice(SEXP args);
void TikZ_Annotate(const char **annotation, int *size);
SEXP TikZ_DeviceInfo(SEXP device_num);


static Rboolean TikZ_Setup(
		pDevDesc deviceInfo,
		const char *fileName,
		double width, double height, Rboolean onefile,
		const char *bg, const char *fg, double baseSize,
		Rboolean standAlone, Rboolean bareBones,
		const char *documentDeclaration,
		const char *packages, const char *footer,
		Rboolean console, Rboolean sanitize, int engine );


/* Graphics Engine function hooks. Defined in GraphicsDevice.h . */

/* Device State */
static Rboolean TikZ_Open( pDevDesc deviceInfo );
static void TikZ_Close( pDevDesc deviceInfo );
static void TikZ_NewPage( const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Clip( double x0, double x1,
		double y0, double y1, pDevDesc deviceInfo );
static void TikZ_Size( double *left, double *right,
		double *bottom, double *top, pDevDesc deviceInfo);

/* Font Metrics*/
static void TikZ_MetricInfo( int c, const pGEcontext plotParams,
		double *ascent, double *descent, double *width, pDevDesc deviceInfo );
static double TikZ_StrWidth( const char *str,
		const pGEcontext plotParams, pDevDesc deviceInfo );

/* Drawing routines. */
static void TikZ_Text( double x, double y, const char *str,
		double rot, double hadj, const pGEcontext plotParams, pDevDesc deviceInfo);
static void TikZ_Circle( double x, double y, double r,
		const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Rectangle( double x0, double y0, 
		double x1, double y1, const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Line( double x1, double y1,
		double x2, double y2, const pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Polyline( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo );
static void TikZ_Polygon( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo );
/*
 * Path routine, a polygon with "holes", was added in R 2.12.0,
 * Graphics Engine version 8.  No idea what happened to version 7,
 * guess it was internal
*/
#if R_GE_version >= 8
static void
TikZ_Path( double *x, double *y,
  int npoly, int *nper,
  Rboolean winding,
  const pGEcontext plotParams, pDevDesc deviceInfo
);
#endif

static void TikZ_Raster(
  unsigned int *raster,
  int w, int h,
  double x, double y,
  double width, double height,
  double rot,
  Rboolean interpolate,
  const pGEcontext plotParams, pDevDesc deviceInfo
);

/* Dummy/Unimplemented routines. */
static SEXP TikZ_Cap( pDevDesc deviceInfo );
static void TikZ_Activate( pDevDesc deviceInfo );
static void TikZ_Deactivate( pDevDesc deviceInfo );
static Rboolean TikZ_Locator( double *x, double *y, pDevDesc deviceInfo );
static void TikZ_Mode( int mode, pDevDesc deviceInfo );

/* End R Graphics engine function hooks. */



/*Internal style definition routines*/
static void StyleDef(Rboolean defineColor, const pGEcontext plotParams, 
	pDevDesc deviceInfo);
static void SetColor(int color, Rboolean def, tikzDevDesc *tikzInfo);
static void SetFill(int color, Rboolean def, tikzDevDesc *tikzInfo);
static void SetAlpha(int color, Rboolean fill, tikzDevDesc *tikzInfo);
static void SetLineStyle(int lty, double lwd, tikzDevDesc *tikzInfo);
static void SetDashPattern(int lty, tikzDevDesc *tikzInfo);
static void SetLineWeight(double lwd, tikzDevDesc *tikzInfo);
static void SetLineJoin(R_GE_linejoin ljoin, double lmitre, tikzDevDesc *tikzInfo);
static void SetLineEnd(R_GE_lineend lend, tikzDevDesc *tikzInfo);
static void SetMitreLimit(double lmitre, tikzDevDesc *tikzInfo);
static double ScaleFont( const pGEcontext plotParams, pDevDesc deviceInfo );

/* Utility Routines*/
static void printOutput(tikzDevDesc *tikzInfo, const char *format, ...);
static void Print_TikZ_Header( tikzDevDesc *tikzInfo );
static char *Sanitize(const char *str);
static Rboolean contains_multibyte_chars(const char *str);
static double dim2dev( double length );

#endif // End of Once Only header

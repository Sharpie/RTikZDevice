/*
 * There probably won't be more than one C source file using
 * this header, but it's still a good idea to make sure the
 * compiler will only include it once. Errors could result
 * otherwise.
*/

#ifndef HAVE_METAPDEV_H // Begin once-only header
#define HAVE_METAPDEV_H

#ifndef DEBUG
#define DEBUG TRUE
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
 * that is unique to the implementation of the MetaP Device. A
 * new component may be created for any information that it is
 * deemed desirable to have available during execution of MetaP
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
  char *fill_color;
	int oldDrawColor;
  char *draw_color;
	int oldLineType;
	pGEcontext plotParams;
	int stringWidthCalls;
	const char *documentDeclaration;
	const char *packages;
	const char *footer;
	Rboolean polyLine;
	Rboolean console;
	Rboolean sanitize;
  SEXP colors;
} tikzDevDesc;


/* Function Prototypes */

static Rboolean MetaP_Setup(
		pDevDesc deviceInfo,
		const char *fileName,
		double width, double height,
		const char *bg, const char *fg, double baseSize,
		Rboolean standAlone, Rboolean bareBones,
		const char *documentDeclaration,
		const char *packages, const char *footer,
		Rboolean console, Rboolean sanitize, int engine );

static Rboolean MetaP_Open( pDevDesc deviceInfo );

/* Graphics Engine function hooks. Defined in GraphicsDevice.h . */

/* Utility routines. */
static void MetaP_Close( pDevDesc deviceInfo );
static void MetaP_NewPage( const pGEcontext plotParams, pDevDesc deviceInfo );
static void MetaP_Clip( double x0, double x1,
		double y0, double y1, pDevDesc deviceInfo );
static void MetaP_Size( double *left, double *right,
		double *bottom, double *top, pDevDesc deviceInfo);
double MetaP_ScaleFont( const pGEcontext plotParams, pDevDesc deviceInfo );

/* Text routines. */
static void MetaP_MetricInfo( int c, const pGEcontext plotParams,
		double *ascent, double *descent, double *width, pDevDesc deviceInfo );
static double MetaP_StrWidth( const char *str,
		const pGEcontext plotParams, pDevDesc deviceInfo );
static void MetaP_Text( double x, double y, const char *str,
		double rot, double hadj, const pGEcontext plotParams, pDevDesc deviceInfo);


/* Drawing routines. */
static void MetaP_Line( double x1, double y1,
		double x2, double y2, const pGEcontext plotParams, pDevDesc deviceInfo );
static void MetaP_Circle( double x, double y, double r,
		const pGEcontext plotParams, pDevDesc deviceInfo );
static void MetaP_Rectangle( double x0, double y0, 
		double x1, double y1, const pGEcontext plotParams, pDevDesc deviceInfo );
static void MetaP_Polyline( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo );
static void MetaP_Polygon( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo );
static void MetaP_DrawLines( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo, Rboolean close_path );

/*
 * Path routine, a polygon with "holes", was added in R 2.12.0,
 * Graphics Engine version 8.  No idea what happened to version 7,
 * guess it was internal
*/ 
#if R_GE_version >= 8
static void
MetaP_Path( double *x, double *y,
  int npoly, int *nper,
  Rboolean winding,
  const pGEcontext plotParams, pDevDesc deviceInfo
);
#endif

static void MetaP_Raster( 
  unsigned int *raster,
  int w, int h,
  double x, double y,
  double width, double height,
  double rot,
  Rboolean interpolate,
  const pGEcontext plotParams, pDevDesc deviceInfo
);

static SEXP MetaP_Cap( pDevDesc deviceInfo );

/* Dummy routines. */
static void MetaP_Activate( pDevDesc deviceInfo );
static void MetaP_Deactivate( pDevDesc deviceInfo );
static Rboolean MetaP_Locator( double *x, double *y, pDevDesc deviceInfo );
static void MetaP_Mode( int mode, pDevDesc deviceInfo );

/* End R Graphics engin function hooks. */



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
static void MetaP_DrawStyle(pGEcontext plotParams, tikzDevDesc *tikzInfo, Rboolean fill);

/* Auxilury routines*/
SEXP MetaP_GetEngine(SEXP device_num);
SEXP MetaP_DeviceInfo(SEXP device_num);
SEXP MetaP_SetColors(SEXP color_list, SEXP device_num);
static char *MetaP_GetColorName(int rgb_value);
static double dim2dev( double length );
static void Print_MetaP_Header( tikzDevDesc *tikzInfo );
static void printOutput(tikzDevDesc *tikzInfo, const char *format, ...);
static char *Sanitize(const char *str);
static Rboolean contains_multibyte_chars(const char *str);

#endif // End of Once Only header

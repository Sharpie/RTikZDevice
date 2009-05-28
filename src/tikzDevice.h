/* Declarations for functions provided by the R language */

/* Use default graphics engine function declarations. */
#define R_USE_PROTOTYPES 1

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
	Rboolean firstPage;
	Rboolean debug;
	Rboolean standAlone;
	Rboolean firstClip;
	int oldFillColor;
	int oldDrawColor;
	int oldLineType;
	pGEcontext plotParams;
} tikzDevDesc;


/* Function Prototypes */

static Rboolean TikZ_Setup(
		pDevDesc deviceInfo,
		const char *fileName,
		double width, double height,
		const char *bg, const char *fg,
		Rboolean standAlone);

double dim2dev( double length );
static void TeXText(const char *str,  tikzDevDesc *tikzInfo);

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
static void SetLineJoin(R_GE_linejoin ljoin, pDevDesc deviceInfo);
static void SetLineEnd(R_GE_linejoin lend, pDevDesc deviceInfo);


/* Dummy routines. */
static void TikZ_Activate( pDevDesc deviceInfo );
static void TikZ_Deactivate( pDevDesc deviceInfo );
static Rboolean TikZ_Locator( double *x, double *y, pDevDesc deviceInfo );
static void TikZ_Mode( int mode, pDevDesc deviceInfo );

/* Global device information */
/* From devPicTeX.c, width of computer modern characters*/
static const double charwidth[4][128] = {
{
  0.5416690, 0.8333360, 0.7777810, 0.6111145, 0.6666690, 0.7083380, 0.7222240,
  0.7777810, 0.7222240, 0.7777810, 0.7222240, 0.5833360, 0.5361130, 0.5361130,
  0.8138910, 0.8138910, 0.2388900, 0.2666680, 0.5000020, 0.5000020, 0.5000020,
  0.5000020, 0.5000020, 0.6666700, 0.4444460, 0.4805580, 0.7222240, 0.7777810,
  0.5000020, 0.8611145, 0.9722260, 0.7777810, 0.2388900, 0.3194460, 0.5000020,
  0.8333360, 0.5000020, 0.8333360, 0.7583360, 0.2777790, 0.3888900, 0.3888900,
  0.5000020, 0.7777810, 0.2777790, 0.3333340, 0.2777790, 0.5000020, 0.5000020,
  0.5000020, 0.5000020, 0.5000020, 0.5000020, 0.5000020, 0.5000020, 0.5000020,
  0.5000020, 0.5000020, 0.2777790, 0.2777790, 0.3194460, 0.7777810, 0.4722240,
  0.4722240, 0.6666690, 0.6666700, 0.6666700, 0.6388910, 0.7222260, 0.5972240,
  0.5694475, 0.6666690, 0.7083380, 0.2777810, 0.4722240, 0.6944480, 0.5416690,
  0.8750050, 0.7083380, 0.7361130, 0.6388910, 0.7361130, 0.6458360, 0.5555570,
  0.6805570, 0.6875050, 0.6666700, 0.9444480, 0.6666700, 0.6666700, 0.6111130,
  0.2888900, 0.5000020, 0.2888900, 0.5000020, 0.2777790, 0.2777790, 0.4805570,
  0.5166680, 0.4444460, 0.5166680, 0.4444460, 0.3055570, 0.5000020, 0.5166680,
  0.2388900, 0.2666680, 0.4888920, 0.2388900, 0.7944470, 0.5166680, 0.5000020,
  0.5166680, 0.5166680, 0.3416690, 0.3833340, 0.3611120, 0.5166680, 0.4611130,
  0.6833360, 0.4611130, 0.4611130, 0.4347230, 0.5000020, 1.0000030, 0.5000020,
  0.5000020, 0.5000020
},
{
  0.5805590, 0.9166720, 0.8555600, 0.6722260, 0.7333370, 0.7944490, 0.7944490,
  0.8555600, 0.7944490, 0.8555600, 0.7944490, 0.6416700, 0.5861150, 0.5861150,
  0.8916720, 0.8916720, 0.2555570, 0.2861130, 0.5500030, 0.5500030, 0.5500030,
  0.5500030, 0.5500030, 0.7333370, 0.4888920, 0.5652800, 0.7944490, 0.8555600,
  0.5500030, 0.9472275, 1.0694500, 0.8555600, 0.2555570, 0.3666690, 0.5583360,
  0.9166720, 0.5500030, 1.0291190, 0.8305610, 0.3055570, 0.4277800, 0.4277800,
  0.5500030, 0.8555600, 0.3055570, 0.3666690, 0.3055570, 0.5500030, 0.5500030,
  0.5500030, 0.5500030, 0.5500030, 0.5500030, 0.5500030, 0.5500030, 0.5500030,
  0.5500030, 0.5500030, 0.3055570, 0.3055570, 0.3666690, 0.8555600, 0.5194470,
  0.5194470, 0.7333370, 0.7333370, 0.7333370, 0.7027820, 0.7944490, 0.6416700,
  0.6111145, 0.7333370, 0.7944490, 0.3305570, 0.5194470, 0.7638930, 0.5805590,
  0.9777830, 0.7944490, 0.7944490, 0.7027820, 0.7944490, 0.7027820, 0.6111145,
  0.7333370, 0.7638930, 0.7333370, 1.0388950, 0.7333370, 0.7333370, 0.6722260,
  0.3430580, 0.5583360, 0.3430580, 0.5500030, 0.3055570, 0.3055570, 0.5250030,
  0.5611140, 0.4888920, 0.5611140, 0.5111140, 0.3361130, 0.5500030, 0.5611140,
  0.2555570, 0.2861130, 0.5305590, 0.2555570, 0.8666720, 0.5611140, 0.5500030,
  0.5611140, 0.5611140, 0.3722250, 0.4216690, 0.4041690, 0.5611140, 0.5000030,
  0.7444490, 0.5000030, 0.5000030, 0.4763920, 0.5500030, 1.1000060, 0.5500030,
  0.5500030, 0.550003 },
{
  0.5416690, 0.8333360, 0.7777810, 0.6111145, 0.6666690, 0.7083380, 0.7222240,
  0.7777810, 0.7222240, 0.7777810, 0.7222240, 0.5833360, 0.5361130, 0.5361130,
  0.8138910, 0.8138910, 0.2388900, 0.2666680, 0.5000020, 0.5000020, 0.5000020,
  0.5000020, 0.5000020, 0.7375210, 0.4444460, 0.4805580, 0.7222240, 0.7777810,
  0.5000020, 0.8611145, 0.9722260, 0.7777810, 0.2388900, 0.3194460, 0.5000020,
  0.8333360, 0.5000020, 0.8333360, 0.7583360, 0.2777790, 0.3888900, 0.3888900,
  0.5000020, 0.7777810, 0.2777790, 0.3333340, 0.2777790, 0.5000020, 0.5000020,
  0.5000020, 0.5000020, 0.5000020, 0.5000020, 0.5000020, 0.5000020, 0.5000020,
  0.5000020, 0.5000020, 0.2777790, 0.2777790, 0.3194460, 0.7777810, 0.4722240,
  0.4722240, 0.6666690, 0.6666700, 0.6666700, 0.6388910, 0.7222260, 0.5972240,
  0.5694475, 0.6666690, 0.7083380, 0.2777810, 0.4722240, 0.6944480, 0.5416690,
  0.8750050, 0.7083380, 0.7361130, 0.6388910, 0.7361130, 0.6458360, 0.5555570,
  0.6805570, 0.6875050, 0.6666700, 0.9444480, 0.6666700, 0.6666700, 0.6111130,
  0.2888900, 0.5000020, 0.2888900, 0.5000020, 0.2777790, 0.2777790, 0.4805570,
  0.5166680, 0.4444460, 0.5166680, 0.4444460, 0.3055570, 0.5000020, 0.5166680,
  0.2388900, 0.2666680, 0.4888920, 0.2388900, 0.7944470, 0.5166680, 0.5000020,
  0.5166680, 0.5166680, 0.3416690, 0.3833340, 0.3611120, 0.5166680, 0.4611130,
  0.6833360, 0.4611130, 0.4611130, 0.4347230, 0.5000020, 1.0000030, 0.5000020,
  0.5000020, 0.5000020 },
{
  0.5805590, 0.9166720, 0.8555600, 0.6722260, 0.7333370, 0.7944490, 0.7944490,
  0.8555600, 0.7944490, 0.8555600, 0.7944490, 0.6416700, 0.5861150, 0.5861150,
  0.8916720, 0.8916720, 0.2555570, 0.2861130, 0.5500030, 0.5500030, 0.5500030,
  0.5500030, 0.5500030, 0.8002530, 0.4888920, 0.5652800, 0.7944490, 0.8555600,
  0.5500030, 0.9472275, 1.0694500, 0.8555600, 0.2555570, 0.3666690, 0.5583360,
  0.9166720, 0.5500030, 1.0291190, 0.8305610, 0.3055570, 0.4277800, 0.4277800,
  0.5500030, 0.8555600, 0.3055570, 0.3666690, 0.3055570, 0.5500030, 0.5500030,
  0.5500030, 0.5500030, 0.5500030, 0.5500030, 0.5500030, 0.5500030, 0.5500030,
  0.5500030, 0.5500030, 0.3055570, 0.3055570, 0.3666690, 0.8555600, 0.5194470,
  0.5194470, 0.7333370, 0.7333370, 0.7333370, 0.7027820, 0.7944490, 0.6416700,
  0.6111145, 0.7333370, 0.7944490, 0.3305570, 0.5194470, 0.7638930, 0.5805590,
  0.9777830, 0.7944490, 0.7944490, 0.7027820, 0.7944490, 0.7027820, 0.6111145,
  0.7333370, 0.7638930, 0.7333370, 1.0388950, 0.7333370, 0.7333370, 0.6722260,
  0.3430580, 0.5583360, 0.3430580, 0.5500030, 0.3055570, 0.3055570, 0.5250030,
  0.5611140, 0.4888920, 0.5611140, 0.5111140, 0.3361130, 0.5500030, 0.5611140,
  0.2555570, 0.2861130, 0.5305590, 0.2555570, 0.8666720, 0.5611140, 0.5500030,
  0.5611140, 0.5611140, 0.3722250, 0.4216690, 0.4041690, 0.5611140, 0.5000030,
  0.7444490, 0.5000030, 0.5000030, 0.4763920, 0.5500030, 1.1000060, 0.5500030,
  0.5500030, 0.550003
}
};

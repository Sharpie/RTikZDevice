
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
#include <stdio.h>
#define DEBUG TRUE

SEXP tikzDevice ( SEXP args ){

	/*
	 * Make sure the version number of the R running this
	 * routine is compatible with the version number of 
	 * the R that compiled this routine.
	*/
	R_GE_checkVersionOrDie(R_GE_version);

	/* Declare local variabls for holding function arguments. */
	const char *fileName;
	const char *bg, *fg;
	double width, height;
	Rboolean standAlone;
	const char *latexCmd;

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

	/* Recover figure dimensions. */
	/* For now these are assumed to be in inches. */
	width = asReal(CAR(args)); args = CDR(args);
	height = asReal(CAR(args)); args = CDR(args);
    
	/* Recover initial background and foreground colors. */
	bg = CHAR(asChar(CAR(args))); args = CDR(args);
	fg = CHAR(asChar(CAR(args))); args = CDR(args);


	/* 
	* Set the standalone parameter for wrapping the picture in a LaTeX 
	* document
	*/
	standAlone = asLogical(CAR(args)); args = CDR(args);

	/*
	 * Recover the path to latex as given by the user or reported by
	 * Sys.getenv('R_PDFLATEX') in R. This is added due to the fact
	 * The certain GUIs (such as the Mac GUI) do not have extensive
	 * knowlege of executable PATHs. Running LaTeX in order to determine
	 * string width without a PATH that contains LaTeX causes a crash.
  */
	latexCmd = translateChar(asChar(CAR(args))); args = CDR(args);

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
		if( !TikZ_Setup( deviceInfo, fileName, 
					width, height, bg, fg, standAlone, latexCmd ) ){
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

static Rboolean TikZ_Setup(
	pDevDesc deviceInfo,
	const char *fileName,
	double width, double height,
	const char *bg, const char *fg,
	Rboolean standAlone,
	const char *latexCmd ){

	/* 
	 * Create tikzInfo, this variable contains information which is
	 * unique to the implementation of the TikZ Device. The deviceInfo
	 * variable contains a slot into which tikzInfo can be placed so that
	 * this information persists and is retrievable during the lifespan
	 * of this device.
	 *
	 * More information on the components of the deviceInfo structure,
	 * which is a pointer to a DevDesc variable, can be found under
	 * struct _DevDesc in the R header file GraphicsDevice.h
	 *
	 * tikzInfo is a structure which is defined in the file tikzDevice.h
	 *
	*/
	tikzDevDesc *tikzInfo;
	
	pGEcontext plotParams;

	/* 
	 * Initialize tikzInfo, return false if this fails. A false return
	 * value will cause the whole device initialization routine to fail.
	*/
	if( !( tikzInfo = (tikzDevDesc *) malloc(sizeof(tikzDevDesc)) ) )
		return FALSE;

	/* Copy TikZ-specific information to the tikzInfo variable. */
	strcpy( tikzInfo->outFileName, fileName);
	strcpy( tikzInfo->latexCmd, latexCmd);
	tikzInfo->firstPage = TRUE;
	tikzInfo->debug = DEBUG;
	tikzInfo->standAlone = standAlone;
	tikzInfo->firstClip = TRUE;
	tikzInfo->oldFillColor = 0;
	tikzInfo->oldDrawColor = 0;
	tikzInfo->oldLineType = 0;
	tikzInfo->plotParams = plotParams;
	tikzInfo->stringWidthCalls = 0;

	/* Incorporate tikzInfo into deviceInfo. */
	deviceInfo->deviceSpecific = (void *) tikzInfo;

	/* 
	 * These next statements define the capabilities of the device.
	 * These capabilities include:
	 *	-Device/user interaction
	 *	-Gamma correction
	 *	-Clipping abilities
	 *	-UTF8 support
	 *  -Text justification/alignment abilities
	*/

	/* 
	 * Define the gamma factor- used to adjust the luminosity of an image. 
	 * Set to 1 since there is no gamma correction in the TikZ device. Also,
	 * canChangeGamma is set to FALSE to disallow user adjustment of this
	 * default
	*/
	deviceInfo->startgamma = 1;
	deviceInfo->canChangeGamma = FALSE;

	/*
	 * canHAdj is an integer specifying the level of horizontal adjustment
	 * or justification provided by this device. Currently set to 0 as this
	 * is not implemented. Level 1 would be possible by having the device
	 * insert /raggedleft, /raggedright and /centering directives. Level 2
	 * represents support for continuous variation between left aligned and
	 * right aligned- this is certainly possible in TeX but would take some
	 * though to implement.
	*/
	deviceInfo->canHAdj = 0;

	/*
	 * useRotatedTextInContour specifies if the text function along with
	 * rotation parameters should be used over Hershey fonts when printing
	 * contour plot labels. As one of the primary goals of this device
	 * is to unify font choices, this value is set to true.
	*/
	deviceInfo->useRotatedTextInContour = TRUE; 

	/*
	 * canClip specifies whether the device implements routines for filtering
	 * plotting input such that it falls within a rectangular clipping area.
	 * Implementing this leads to an interesting design choice- to implement
	 * clipping here in the C code or hand it off to the TikZ clipping 
	 * routines.  Clipping at the C level may reduce  and simplify the final 
	 * output file by not printing objects that fall outside the plot 
	 * boundaries. 
	*/
	deviceInfo->canClip = TRUE;

	/*
	 * These next parameters speficy if the device reacts to keyboard and 
	 * mouse events. Since this device outputs to a file, not a screen window, 
	 * these actions are disabled.
	*/
	deviceInfo->canGenMouseDown = FALSE;
	deviceInfo->canGenMouseMove = FALSE;
	deviceInfo->canGenMouseUp = FALSE;
	deviceInfo->canGenKeybd = FALSE;

	/* 
	 * This parameter specifies whether the device is set up to handle UTF8
	 * characters. This makes a difference in the complexity of the text
	 * handling functions that must be built into the device. If set to true
	 * both hook functions textUTF8 and strWidthUTF8 must be implemented.
	 * Compared to ASCII, which only has 128 character values, UTF8 has
	 * thousends. This will require a fairly sophisticated function for
	 * calculating string widths.
	 *
	 * UTF8 support would be a great feature to include as it would make
	 * this device useful for an international audience. For now only
	 * the ASCII character set will be used as it is easy to implement.
	 * 
	 * wantSymbolUTF8 indicates if mathematical symbols should be treated
	 * as UTF8 characters.
	*/
	deviceInfo->hasTextUTF8 = FALSE;
	deviceInfo->wantSymbolUTF8 = FALSE;

	/*
	 * Initialize device parameters. These concern properties such as the 
	 * plotting canvas size, the initial foreground and background colors and 
	 * the initial clipping area. Other parameters related to fonts and text 
	 * output are also included.
	*/

	/*
	* Set canvas size. The bottom left corner is considered the origin and 
	* assigned the value of 0pt, 0pt. The upper right corner is assigned by 
	* converting the specified height and width of the device to points.
	*/
	deviceInfo->bottom = 0;
	deviceInfo->left = 0;
	deviceInfo->top = dim2dev( height );
	deviceInfo->right = dim2dev( width );

	/* Set default character size in pixels. */
	deviceInfo->cra[0] = 9;
	deviceInfo->cra[1] = 12;

	/* Set initial font. */
	deviceInfo->startfont = 1;

	/* Set initial font size. */
	deviceInfo->startps = 10;

	/* 
	* Apparently these are supposed to center text strings over the points at
    * which they are plottet. TikZ does this automagically.
	*/
	deviceInfo->xCharOffset = 0;	
	deviceInfo->yCharOffset = 0;	
	deviceInfo->yLineBias = 0;	

	/* Specify the number of inches per pixel in the x and y directions. */
	deviceInfo->ipr[0] = 1/dim2dev(1);
	deviceInfo->ipr[1] = 1/dim2dev(1);

	/* Set initial foreground and background colors. */
	deviceInfo->startfill = R_GE_str2col( bg );
	deviceInfo->startcol = R_GE_str2col( fg );

	/* Set initial line type. */
	deviceInfo->startlty = 0;


	/* 
	 * Connect R graphic function hooks to TikZ Routines implemented in this
	 * file. Each routine performs a specific function such as adding text, 
	 * drawing a line or reporting/adjusting the status of the device.
	*/

	/* Utility routines. */
	deviceInfo->close = TikZ_Close;
	deviceInfo->newPage = TikZ_NewPage;
	deviceInfo->clip = TikZ_Clip;
	deviceInfo->size = TikZ_Size;

	/* Text routines. */
	deviceInfo->metricInfo = TikZ_MetricInfo;
	deviceInfo->strWidth = TikZ_StrWidth;
	deviceInfo->text = TikZ_Text;

	/* Drawing routines. */
	deviceInfo->line = TikZ_Line;
	deviceInfo->circle = TikZ_Circle;
	deviceInfo->rect = TikZ_Rectangle;
	deviceInfo->polyline = TikZ_Polyline;
	deviceInfo->polygon = TikZ_Polygon;

	/* Dummy routines. */
	deviceInfo->activate = TikZ_Activate;
	deviceInfo->deactivate = TikZ_Deactivate;
	deviceInfo->locator = TikZ_Locator;
	deviceInfo->mode = TikZ_Mode;

	/* Call TikZ_Open to create and initialize the output file. */
	if( !TikZ_Open( deviceInfo ) )
		return FALSE;

	return TRUE;

}

/*
 * This function is responsible for converting lengths given in page
 * dimensions (ie. inches, cm, etc.) to device dimensions (currenty
 * points- 1/72 of an inch). However, due to the flexability of TeX
 * and TikZ, any combination of device and user dimensions could
 * theoretically be supported.
*/
double dim2dev( double length ){
	return length*72;
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

	/* Header for a standalone LaTeX document*/
	if(tikzInfo->standAlone == TRUE){
		fprintf(tikzInfo->outputFile,"%% %s\n",tikzInfo->latexCmd);
		fprintf(tikzInfo->outputFile,"\\documentclass{article}\n");
		fprintf(tikzInfo->outputFile,"\\usepackage{tikz}\n");
		fprintf(tikzInfo->outputFile,"\\usepackage[active,tightpage]{preview}\n");
		fprintf(tikzInfo->outputFile,"\\PreviewEnvironment{pgfpicture}\n");
		fprintf(tikzInfo->outputFile,"\\setlength\\PreviewBorder{0pt}\n\n");
		fprintf(tikzInfo->outputFile,"\\begin{document}\n\n");
	}

	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Beginning tikzpicture, this file is %s\n",
			R_ExpandFileName(tikzInfo->outFileName));

	/* Start the tikz environment. */
	fprintf(tikzInfo->outputFile,"%% Created by tikzDevice x.x.x, on DATE, at TIME\n");
	fprintf(tikzInfo->outputFile, "\\begin{tikzpicture}[x=1pt,y=1pt]\n");

	/* 
	 * For now, print an invisible rectangle to ensure all of the plotting 
	 * area is used. Once color options are implemented, this could be 
	 * replaced with a call to TikZ_Rectangle, if feasible.
	*/
	fprintf(tikzInfo->outputFile, 
			"\\draw[color=white,opacity=0] (0,0) rectangle (%6.2f,%6.2f);\n",
			deviceInfo->right,deviceInfo->top);

	return TRUE;

}

static void TikZ_Close( pDevDesc deviceInfo){

	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	/* End the tikz environment. */
	fprintf(tikzInfo->outputFile, "\\end{scope}\n");
	fprintf(tikzInfo->outputFile, "\\end{tikzpicture}\n");
	
	/* Close off the standalone document*/
	if(tikzInfo->standAlone == TRUE)
		fprintf(tikzInfo->outputFile,"\n\\end{document}\n");
	
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Calculated string width %d times\n",
			tikzInfo->stringWidthCalls);

	/* Close the file and destroy the tikzInfo structure. */
	fclose(tikzInfo->outputFile);
	free(tikzInfo);

}

static void TikZ_NewPage( const pGEcontext plotParams, pDevDesc deviceInfo ){

	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	if ( tikzInfo->firstPage ){
		tikzInfo->firstPage = FALSE;
	}else{

		/* End the current TikZ environment. */
		fprintf(tikzInfo->outputFile, "\\end{tikzpicture}\n");

		/*Show only for debugging*/
		if(tikzInfo->debug == TRUE) 
			fprintf(tikzInfo->outputFile,
				"%% Beginning new tikzpicture 'page'\n");

		/* Start a new TikZ envioronment. */
		fprintf(tikzInfo->outputFile, 
			"\n\\begin{tikzpicture}[x=1pt,y=1pt]\n");
		
		/* 
		 * For now, print an invisible rectangle to ensure all of the plotting 
		 * area is used. Once color options are implemented, this could be 
		 * replaced with a call to TikZ_Rectangle, if feasible.
		*/
		fprintf(tikzInfo->outputFile, 
			"\\draw[color=white,opacity=0] (0,0) rectangle (%6.2f,%6.2f);\n",
			deviceInfo->right,deviceInfo->top);
				
		/*Define default colors*/
		SetColor(plotParams->col, TRUE, deviceInfo);
		SetFill(plotParams->fill, TRUE, deviceInfo);
		
	}

}

static void TikZ_Clip( double x0, double x1, 
		double y0, double y1, pDevDesc deviceInfo ){
	
	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	deviceInfo->clipBottom = y0;
	deviceInfo->clipLeft = x0;
	deviceInfo->clipTop = y1;
	deviceInfo->clipRight = x1;
	
	if(tikzInfo->firstClip != TRUE)
		fprintf(tikzInfo->outputFile, "\\end{scope}\n");
	else
		tikzInfo->firstClip = FALSE;
	
	fprintf(tikzInfo->outputFile, "\\begin{scope}\n");
	fprintf(tikzInfo->outputFile,
			"\\path[clip] (%6.2f,%6.2f) rectangle (%6.2f,%6.2f);\n",
			x0,y0,x1,y1);
	if(tikzInfo->debug == TRUE)
		fprintf(tikzInfo->outputFile,
				"\\path[draw=red,very thick,dashed] (%6.2f,%6.2f) rectangle (%6.2f,%6.2f);\n",
				x0,y0,x1,y1);
			
	/*Define the colors for fill and border*/
	StyleDef(TRUE, tikzInfo->plotParams, deviceInfo);
}

static void TikZ_Size( double *left, double *right,
		double *bottom, double *top, pDevDesc deviceInfo){
	
	/* Return canvas size. */
	*bottom = deviceInfo->bottom;
	*left = deviceInfo->left;
	*top = deviceInfo->top;
	*right = deviceInfo->right;
}


/*
 * This function is supposed to calculate character metrics (such as raised 
 * letters, stretched letters, ect). Currently the TikZ device does not 
 * perform such functions, so this function returns a mandatory 0 for each 
 * component.
*/ 
static void TikZ_MetricInfo(int c, const pGEcontext plotParams,
		double *ascent, double *descent, double *width, pDevDesc deviceInfo ){

	*ascent = 0.0;
	*descent = 0.0;
	*width = 0.0;

}

/*
 * This function is supposed to calculate the plotted with, in device raster
 * units of an arbitrary string. This is perhaps the most difficult function
 * that a device needs to implement.  Calculating the exact with of a string 
 * is actually impossible because this device is designed to print characters 
 * in whatever font is being used in the the TeX document. The font is unknown
 * (and cannot be known) in the device. The problem is further complicated by 
 * the fact that TeX strings can be used directly in annotations.  For example 
 * the string \textit{x} would be seen by the device as 10 characters when it 
 * should only count as 1.  Given this difficulty the function currently 
 * returns a nice round number- 42.
*/
static double TikZ_StrWidth( const char *str,
		const pGEcontext plotParams, pDevDesc deviceInfo ){
			
	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;
	
	double width = GetLatexStringWidth(str,tikzInfo);
	
	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Calculated string width of %s as %f\n",str,width);
	
	return(width);
		
}

/*
 * This function should plot a string of text at coordinates x and y with
 * a rotation value specified by rot and horizontal alignment specified by
 * hadj. Additional parameters such as color, font type, font style, line
 * height and font size are specified in the pGEcontext variable plotParams.
 *
 * The rotation value is given in degrees.
*/
static void TikZ_Text( double x, double y, const char *str,
		double rot, double hadj, const pGEcontext plotParams, pDevDesc deviceInfo){
	
	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Drawing node at x = %f, y = %f\n",
			x,y);

	/* Start a node for the text, open an options bracket. */
	fprintf( tikzInfo->outputFile,"\n\\node[");

	/* Rotate the text if desired. */
	if( rot != 0 )
		fprintf( tikzInfo->outputFile, "rotate=%6.2f", rot );

	/* More options would go here such as scaling, color etc. */
	
	/* End options, print coordinates and string. */
	fprintf( tikzInfo->outputFile, ",anchor=south west, inner sep=0pt, outer sep=0pt] at (%6.2f,%6.2f) {%s};\n",
		x, y, str);

	// Add a small red marker to indicate the point the text string is being aligned to.
	if( DEBUG == TRUE )
		fprintf( tikzInfo->outputFile, "\n\\draw[color=red, fill=red] (%6.2f,%6.2f) circle (0.5pt);\n", x, y);

}


static void TikZ_Line( double x1, double y1,
		double x2, double y2, const pGEcontext plotParams, pDevDesc deviceInfo){

	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Drawing line from x1 = %10.4f, y1 = %10.4f to x2 = %10.4f, y2 = %10.4f\n",
			x1,y1,x2,y2);

	/*Define the colors for fill and border*/
	StyleDef(TRUE, plotParams, deviceInfo);

	/* Start drawing a line, open an options bracket. */
	fprintf( tikzInfo->outputFile,"\n\\draw[");
	
	/*Define the draw styles*/
	StyleDef(FALSE, plotParams, deviceInfo);

	/* More options would go here such as line thickness, style, color etc. */
	
	/* End options, print coordinates. */
	fprintf( tikzInfo->outputFile, "] (%6.2f,%6.2f) -- (%6.2f,%6.2f);\n",
		x1,y1,x2,y2);

}

static void TikZ_Circle( double x, double y, double r,
		const pGEcontext plotParams, pDevDesc deviceInfo){

	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Drawing Circle at x = %f, y = %f, r = %f\n",
			x,y,r);

	/*Define the colors for fill and border*/
	StyleDef(TRUE, plotParams, deviceInfo);

	/* Start drawing, open an options bracket. */
	fprintf( tikzInfo->outputFile,"\n\\draw[");

	/* 
	 * More options would go here such as line thickness, style, line 
	 * and fill color etc. 
	*/ 
	
	/*Define the draw styles*/
	StyleDef(FALSE, plotParams, deviceInfo);

	
	/* End options, print coordinates. */
	fprintf( tikzInfo->outputFile, "] (%6.2f,%6.2f) circle (%6.2f);\n",
		x,y,r);
}

static void TikZ_Rectangle( double x0, double y0,
		double x1, double y1, const pGEcontext plotParams, pDevDesc deviceInfo){

	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Drawing Rectangle from x0 = %f, y0 = %f to x1 = %f, y1 = %f\n",
			x0,y0,x1,y1);

	/*Define the colors for fill and border*/
	StyleDef(TRUE, plotParams, deviceInfo);

	/* Start drawing, open an options bracket. */
	fprintf( tikzInfo->outputFile,"\n\\draw[");

	/*Define the draw styles*/
	StyleDef(FALSE, plotParams, deviceInfo);

	/* 
	 * More options would go here such as line thickness, style, line 
	 * and fill color etc. 
	*/
	
	/* End options, print coordinates. */
	fprintf( tikzInfo->outputFile, 
		"] (%6.2f,%6.2f) rectangle (%6.2f,%6.2f);\n",
		x0,y0,x1,y1);

}

static void TikZ_Polyline( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo ){

	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Starting Polyline\n");

	/*Define the colors for fill and border*/
	StyleDef(TRUE, plotParams, deviceInfo);

	/* Start drawing, open an options bracket. */
	fprintf( tikzInfo->outputFile,"\n\\draw[");

	/* More options would go here such as line thickness, style and color */
	/*Define the draw styles*/
	StyleDef(FALSE, plotParams, deviceInfo);

	/* End options, print first set of coordinates. */
	fprintf( tikzInfo->outputFile, "] (%6.2f,%6.2f) --\n",
		x[0],y[0]);
	
	/* Print coordinates for the middle segments of the line. */
	int i;
	for ( i = 1; i < n-1; i++ ){
		
		fprintf( tikzInfo->outputFile, "\t(%6.2f,%6.2f) --\n",
			x[i],y[i]);

	}

	/* Print last set of coordinates. End path. */
	fprintf( tikzInfo->outputFile, "\t(%6.2f,%6.2f);\n",
		x[n-1],y[n-1]);
		
	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% End Polyline\n");

}

static void TikZ_Polygon( int n, double *x, double *y,
		pGEcontext plotParams, pDevDesc deviceInfo ){

	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;

	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% Starting Polygon\n");
			
	/*Define the colors for fill and border*/
	StyleDef(TRUE, plotParams, deviceInfo);
	
	/* Start drawing, open an options bracket. */
	fprintf( tikzInfo->outputFile,"\n\\draw[");
	
	/* 
	 * More options would go here such as line thickness, style, line 
	 * and fill color etc. 
	*/
	
	/*Define the draw styles*/
	StyleDef(FALSE, plotParams, deviceInfo);

	/* End options, print first set of coordinates. */
	fprintf( tikzInfo->outputFile, "] (%6.2f,%6.2f) --\n",
		x[0],y[0]);
	
	/* Print coordinates for the middle segments of the line. */
	int i;
	for ( i = 1; i < n; i++ ){
		
		fprintf( tikzInfo->outputFile, "\t(%6.2f,%6.2f) --\n",
			x[i],y[i]);

	}

	/* End path by cycling to first set of coordinates. */
	fprintf( tikzInfo->outputFile, "\tcycle;\n" );

	/*Show only for debugging*/
	if(tikzInfo->debug == TRUE) 
		fprintf(tikzInfo->outputFile,
			"%% End Polyline\n");

}

/* This function either prints out the color definitions for outline and fill 
 * colors or the style tags in the \draw[] command, the defineColor parameter 
 * tells if the color/style is being defined or used.
 * SetLineStyle and CheckAndSetAlpha are only run if the style is being used 
 * because there are no color definitions outside of the draw command. 
*/
static void StyleDef(Rboolean defineColor, const pGEcontext plotParams, 
						pDevDesc deviceInfo){
	
	/*From devPS.c, PS_Circle()*/
	int code;
    /* code is set as follows */
    /* code == 0, nothing to draw */
    /* code == 1, outline only */
    /* code == 2, fill only */
    /* code == 3, outline and fill */

    code = 3 - 2 * (R_TRANSPARENT(plotParams->fill)) - 
					(R_TRANSPARENT(plotParams->col));

	if (code) {
		if(code & 1) {
			/* Define outline draw color*/
			SetColor(plotParams->col, defineColor, deviceInfo);
			if(defineColor == FALSE){
				SetLineStyle(plotParams->lty, plotParams->lwd, deviceInfo);
				SetLineEnd(plotParams->lend, deviceInfo);
				SetLineJoin(plotParams->ljoin, 
							plotParams->lmitre, deviceInfo);
			}
		}
		if(code & 2){
			/* Define fill color*/
			SetFill(plotParams->fill, defineColor, deviceInfo);
		}
	}
	/*Set Alpha*/
	if(defineColor == FALSE){
		/*Set Fill opacity Alpha*/
		SetAlpha(plotParams->fill, TRUE, deviceInfo);
		/*Set Draw opacity Alpha*/
		SetAlpha(plotParams->col, FALSE, deviceInfo);
	}
	
}

static void SetFill(int color, Rboolean def, pDevDesc deviceInfo){
	
	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;
	
	if(def == TRUE){
		if(color != tikzInfo->oldFillColor){
			tikzInfo->oldFillColor = color;
			fprintf(tikzInfo->outputFile,
				"\\definecolor[named]{fillColor}{rgb}{%4.2f,%4.2f,%4.2f}\n",
				R_RED(color)/255.0,
				R_GREEN(color)/255.0,
				R_BLUE(color)/255.0);
		}
	}else{
		fprintf( tikzInfo->outputFile, "fill=fillColor,");
	}
	
}


static void SetColor(int color, Rboolean def, pDevDesc deviceInfo){
	
	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;
	
	if(def == TRUE){
		if(color != tikzInfo->oldDrawColor){
			tikzInfo->oldDrawColor = color;
			fprintf(tikzInfo->outputFile,
				"\\definecolor[named]{drawColor}{rgb}{%4.2f,%4.2f,%4.2f}\n",
				R_RED(color)/255.0,
				R_GREEN(color)/255.0,
				R_BLUE(color)/255.0);
		}
	}else{
		fprintf( tikzInfo->outputFile, "color=drawColor,");
	}
}

static void SetLineStyle(int lty, int lwd, pDevDesc deviceInfo){
	
    /* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;
		
	SetLineWeight(lwd, tikzInfo->outputFile);
	
    if (lty && lwd) {
	
		SetDashPattern(lty, tikzInfo->outputFile);
    }
}

static void SetDashPattern(int lty, FILE *outputFile){
	char dashlist[8];
	int i, nlty;
	
	/* From ?par
	 * Line types can either be specified by giving an index into a small 
	 * built-in table of line types (1 = solid, 2 = dashed, etc, see lty 
	 * above) or directly as the lengths of on/off stretches of line. This 
	 * is done with a string of an even number (up to eight) of characters, 
	 * namely non-zero (hexadecimal) digits which give the lengths in 
	 * consecutive positions in the string. For example, the string "33" 
	 * specifies three units on followed by three off and "3313" specifies 
	 * three units on followed by three off followed by one on and finally 
	 * three off. The ‘units’ here are (on most devices) proportional to lwd, 
	 * and with lwd = 1 are in pixels or points or 1/96 inch.

	 * The five standard dash-dot line types (lty = 2:6) correspond to 
	 * c("44", "13", "1343", "73", "2262").
	 * 
	 * (0=blank, 1=solid (default), 2=dashed, 
	 *  3=dotted, 4=dotdash, 5=longdash, 6=twodash) 
	*/
	
	/*Retrieve the line type pattern*/
	for(i = 0; i < 8 && lty & 15 ; i++) {
		dashlist[i] = lty & 15;
		lty = lty >> 4;
	}
	nlty = i; i = 0; 
	
	fprintf(outputFile, "dash pattern=");
	
	/*Set the dash pattern*/
	while(i < nlty){
		if( (i % 2) == 0 ){
			fprintf(outputFile, "on %dpt ", dashlist[i]);
		}else{
			fprintf(outputFile, "off %dpt ", dashlist[i]);
		}
		i++;
	}
	fprintf(outputFile, ",");
}

static void SetLineWeight(int lwd, FILE *outputFile){
	
	/*Set the line width, 0.4pt is the TikZ default so scale lwd=1 to that*/
	if(lwd != 1)
		fprintf(outputFile,"line width=%4.1fpt,",0.4*lwd);
}

static void SetAlpha(int color, Rboolean fill, pDevDesc deviceInfo){
	
	/* If the parameter fill == TRUE then set the fill opacity otherwise set 
	 * the outline opacity
	*/
	
	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;
	
	unsigned int alpha = R_ALPHA(color);
	
	/*draw opacity and fill opacity separately here*/
	if(!R_OPAQUE(color)){
		if(fill == TRUE)
			fprintf(tikzInfo->outputFile,"fill opacity=%4.2f,",alpha/255.0);
		else
			fprintf(tikzInfo->outputFile,"draw opacity=%4.2f,",alpha/255.0);
	}
	
}


static void SetLineJoin(R_GE_linejoin ljoin, double lmitre, 
						pDevDesc deviceInfo){
	
	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;
	
	switch (ljoin) {
		case GE_ROUND_JOIN:
			fprintf(tikzInfo->outputFile, "line join=round,");
			break;
		case GE_MITRE_JOIN:
			/*Default if nothing is specified*/
			SetMitreLimit(lmitre, tikzInfo->outputFile);
			break;
		case GE_BEVEL_JOIN:
			fprintf(tikzInfo->outputFile, "line join=bevel,");
	}
}

static void SetMitreLimit(double lmitre, FILE *outputFile){
	
	if(lmitre != 10)
		fprintf(outputFile, "mitre limit=%4.2f,",lmitre);
	
}

static void SetLineEnd(R_GE_linejoin lend, pDevDesc deviceInfo){
	
	/* Shortcut pointers to variables of interest. */
	tikzDevDesc *tikzInfo = (tikzDevDesc *) deviceInfo->deviceSpecific;
	
	switch (lend) {
		case GE_ROUND_CAP:
			fprintf(tikzInfo->outputFile, "line cap=round,");
			break;
		case GE_BUTT_CAP:
			/*Default if nothing is specified*/
			break;
		case GE_SQUARE_CAP:
			fprintf(tikzInfo->outputFile, "line cap=rect,");
	}
}

/* 
 * Returns the width of a latex string in points by doing a system call to latex
 */

static double GetLatexStringWidth(const char *str, tikzDevDesc *tikzInfo){

	/*Increment the number of times this function has been called*/
	tikzInfo->stringWidthCalls++;
	
	char *width;
  FILE *pLatexFile = NULL;
	FILE *pLatexOutput = NULL;
	FILE *pLatexLogFile = NULL;
	int lineLen = 512;
	char line[lineLen];
	char *latexFile = "str-width.tex";
	char *latexLogFile = "str-width.log";
	char *writeMode = "w";
	char *readMode = "r";

	/*
	 * Build LaTeX command from the value passed into this function
	 * by R or the user.
	*/
	char cmd[512];
 	strcpy(cmd, tikzInfo->latexCmd );
	/*Just about every output suppressing option possible.
	 Hopefully other platforms will just ride over the unknown options*/
	strcat(cmd," -interaction=batchmode ");

	/* Open the LaTeX file */
	pLatexFile = fopen(latexFile, writeMode);

	/*Write the contents of the latex file that will return the width */
	fprintf(pLatexFile,"\\documentclass{article}\n");
	fprintf(pLatexFile,"\\usepackage[utf8]{inputenc}\n");
	fprintf(pLatexFile,"\\usepackage[T1]{fontenc}\n");
	fprintf(pLatexFile,"\\batchmode\n");

	/* This is here as a reminder, add an argument that allows 
	   the user to specify the font packages, */
	fprintf(pLatexFile,"%%... other font setup stuff\n ");

	fprintf(pLatexFile,"\\sbox0{%s}\n",str);
	fprintf(pLatexFile,"\\typeout{width=\\the\\wd0}\n");

	/*Stop before creating output*/
	fprintf(pLatexFile,"\\makeatletter\n");
	fprintf(pLatexFile,"\\@@end\n");
	
	/*Close the LaTeX file, ready to compile*/ 
	fclose(pLatexFile);

	/*Call LaTeX to calculate the string width, possible allow for 
	  the use of XeTeX here*/
	strcat(cmd,latexFile);

	/* popen creates a pipe so we can read the output
     	of the program we are invoking, but in this case, 
		we are just doing it to supress output.*/
	if (!(pLatexOutput = popen(cmd, "r"))) {
		exit(1);
	}
	/*Cycle through the output*/
	while(fgets(line, lineLen, pLatexOutput) != NULL){}
	pclose(pLatexOutput);
	
	/*Now open the Log file for reading*/
	pLatexLogFile = fopen(latexLogFile, readMode);
	
	/* Parse the log file to get the string width */
	while(fgets(line, lineLen, pLatexLogFile) != NULL){
		if(sscanf(line,"width=%spt",width) == 1){
			//printf("\n%s",line);
			//printf("float: %s\n",width);
			//printf("Returning %f for %s\n",atof(width)/72.0,str);
			
			 /* found the width line so close the file and return width*/
			fclose(pLatexLogFile);
			return(atof(width));
		}
	}

	/*Close the file and return zero in case we didn't find anything*/
	fclose(pLatexLogFile);
	return(0.0);
}

/* TeX Text Translations from the PixTeX Device, I thought we might be able to 
 * use these possibly for an option to sanitize TeX strings
 */
static void TeXText(const char *str,  tikzDevDesc *tikzInfo){
	fputc('{', tikzInfo->outputFile);
	for( ; *str ; str++)
		switch(*str) {
		case '$':
			fprintf(tikzInfo->outputFile, "\\$");
			break;

		case '%':
			fprintf(tikzInfo->outputFile, "\\%%");
			break;

		case '{':
			fprintf(tikzInfo->outputFile, "\\{");
			break;

		case '}':
			fprintf(tikzInfo->outputFile, "\\}");
			break;

		case '^':
			fprintf(tikzInfo->outputFile, "\\^{}");
			break;

		default:
			fputc(*str, tikzInfo->outputFile);
			break;
		}
	fprintf(tikzInfo->outputFile,"} ");
}


/* 
 * Activate and deactivate execute commands when the active R device is 
 * changed. For devices using plotting windows, these routines usually change 
 * the window title to something like "Active" or "Inactive". Locator is a 
 * routine that is determines coordinates on the plotting canvas corresponding 
 * to a mouse click. For devices plotting to files these functions can be left 
 * as dummy routines.
*/
static void TikZ_Activate( pDevDesc deviceInfo ){}
static void TikZ_Deactivate( pDevDesc deviceInfo ){}
static Rboolean TikZ_Locator( double *x, double *y, pDevDesc deviceInfo ){
	return FALSE;
}

/*
 * The mode function is called when R begins drawing and ends drawing using
 * a device. Currently there are no actions necessary under these conditions
 * so this function is a dummy routine. Conciveably this function could be
 * used to wrap TikZ graphics in \begin{scope} and \end{scope} directives.
*/
static void TikZ_Mode( int mode, pDevDesc deviceInfo ){}

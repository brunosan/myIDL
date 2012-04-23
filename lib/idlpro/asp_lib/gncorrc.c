/******************************************************************************
*
*    function:  gncorrc
*
*     purpose:	perform the interpolation loop for the IDL procedure gncorr.pro
*
*       usage:	see gncorr.pro
*
*      author:	rob@ncar, 10/92
*
*       notes:	1) X values <= the first X get the first Y
*       	2) X values >  the last X get an interpolated Y
*       	3) X values in gaintable must increase
*
*		- tried to pass in pointer to 4D array to C for the gaintable,
*		  but didn't work (e.g., needed constant for nx dimension),
*		  thus have to play with pointers
*
******************************************************************************/

#include <stdio.h>

int
gncorrc(argc, argv)
	int		argc;
	void		*argv[];
{
	float		*image_in,		/* (input) image */
			*gaintable,		/* (input) gaintable */
			*image_out,		/* (output) image */
			x, 			/* scalar values */
			*ix, *ox,		/* input and output indices */
			*gx, *gy, *gxn,		/* gaintable indices */
			xprev, yprev;		/* gaintable values */
	int		nx, ny,			/* (input) image dimensions */
			ng,			/* (input) gaintbl 1st dim. */
			ndim,			/* # elements in images */
			g1size, ng1, ng2,
			i, done;

	/*
	 *	Obtain IDL variables.
	 */
	image_in  = (float *) argv[0];
	gaintable = (float *) argv[1];
	nx	  = * (int *) argv[2];
	ny	  = * (int *) argv[3];
	ng	  = * (int *) argv[4];
	image_out = (float *) argv[5];

	/*
	 *	Set other variables.
	 */
	ndim = nx * ny;
	g1size = ng - 1;
	ng1 = ng + 1;
	ng2 = ng * 2;
	ix = image_in;
	ox = image_out;
	gx = gaintable;

	/*
	 *	Loop for each value of the input image.
	 */
	for (i=0; i<ndim; i++, ix++, ox++) {
		x = *ix; 

		/* less than or equal to the 1st value */
		if (x <= *gx) {
			*ox = *(gx + ng);
			gx += ng2;

		/* greater than last value */
		} else if (x > *(gx + g1size)) {
			gx += g1size;
			gy = gx + ng;
			xprev = *(gx - 1);
			yprev = *(gy - 1);

/*  assume gaintable is correct for now, -Rob, 10/26/92
			if (*gx == xprev) {
				(void) printf(
	"GAINTBL err (last), seq %d, val %.3f, curr %.3f, prev %.3f\n",
					i, x, *gx, xprev);
				return(1);
			} else
*/
				*ox = yprev + ((x - xprev)/(*gx - xprev)) *
					(*gy - yprev);

			gx += ng1;

		/* intermediate value */
		} else {
			done = 0;
			gxn = gx + ng2;

			do {	gx++;
				if (x <= *gx) done = 1;
			} while (!done);

			gy = gx + ng;
			xprev = *(gx - 1);
			yprev = *(gy - 1);

/*  assume gaintable is correct for now, -Rob, 10/26/92
			if (*gx == xprev) {
				(void) printf(
	"GAINTBL err (midl), seq %d, val %.3f, curr %.3f, prev %.3f\n",
					i, x, *gx, xprev);
				return(1);
			} else
*/
				*ox = yprev + ((x - xprev)/(*gx - xprev)) *
					(*gy - yprev);

			gx = gxn;
		}
	}			/* for */

	/*
	 *	Return 0 on success.
	 */
	return(0);
}				/* gncorrc */

/*---------------------------------------------------------------------------*/

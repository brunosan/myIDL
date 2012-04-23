/******************************************************************************
*
*    function:  aspinterp
*
*     purpose:	linearly interpolate floating point values
*
*       usage:	y = aspinterp(argc, argv)
*
*		    argv contains:
*			xarr - input X array
*			yarr - input Y array
*			x    - X value at which to interpolate a new Y
*
*			y    - the resulting interpolated Y
*
*	IDL USAGE -
*		x	= ...
*		xarr	= ...
*		yarr	= ...
*		n	= sizeof(xarr, 1)
*		n1	= n - 1
*		nel	= n * 2 + 1
*		arr	= fltarr(nel, /nozero)
*	     arr(0:n1)	= xarr(*)
*	   arr(n:n+n1)	= yarr(*)
*	      arr(n+n)	= x
*		      y = call_external('aspinterp.so', '_aspinterp', $
*				float(arr), nel, /F_VALUE)
*
*      author:	rob@ncar, 5/92
*
*       notes:	1) x values less than the first X get the first Y
*       	2) x values greater than the last X get an interpolated Y
*
******************************************************************************/

float
aspinterp(argc, argv)
	int		argc;			/* number of arguments */
	void		*argv[];		/* the arguments */
{
	int		num,			/* number of val's in arrays */
			num1,
			done = 0;
	float		*xarr, *yarr,		/* inputs */
			x,
			*xptr, *yptr,
			xold, yold;

	/*
	 *	Get inputs.
	 */
	num  = (*(int *) argv[1] - 1) / 2;
	num1 = num - 1;
	xarr = (float *) argv[0];
	yarr = xarr + num;
	x    = *(yarr + num);

	/*
	 *	Return interpolated result.
	 */
	if (x < *xarr) {
		return(*yarr);

	} else if (x > *(xarr + num1)) {
		xptr = xarr + num1;
		yptr = yarr + num1;
		xold = *(xptr - 1);
		yold = *(yptr - 1);
		return(yold + ((x - xold)/(*xptr - xold)) * (*yptr - yold));

	} else {
		xptr = xarr;
		yptr = yarr;

		do {
			xptr++;
			yptr++;
			if (x <= *xptr) done = 1;
		} while (!done);

		xold = *(xptr - 1);
		yold = *(yptr - 1);
		return(yold + ((x - xold)/(*xptr - xold)) * (*yptr - yold));
	}
}

/*---------------------------------------------------------------------------*/

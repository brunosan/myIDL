PRO ROTALIGN , A , B , X0 , Y0 , ANGLE , C , NITER = niter, INTERP = interp, $
	MISSING = missing , OUTSIDE = outside , CHI = chi , FLAG = flag , $
	WEIGHT = w
;+
; NAME:
;	ROTALIGN
;
; PURPOSE:
;	Find the coefficients of an affine transformation to match
;	image B over A. Only field rotation and misalignment are considered.
;
; CALLING SEQUENCE:
;	ROTALIGN , A , B , X0 , Y0 , ANGLE, [ C , NITER = , INTERP = 
;		MISSING = , OUTSIDE = , CHI = , FLAG = , WEIGHT = ] )
;
; INPUTS:
;	A = the reference image.
;
;	B = the distorted image. B is assumed to be the result of a spatial
;		transformation over the image B.
;
; 	X0,Y0 = first guess for the position of center of rotation.
;		A value of 0 means centre of image.
;
;	ANGLE = guess for the angle, in degrees, to rotate B clockwise
;		to match A.
;
; KEYWORDS:
;	NITER = specifies the number of iterations. If not set,
;		niter = 20.
;
;	INTERP = specifies the interpolation method. If set,
;		cubic interpolation is performed. Otherwise, arrays
;		are bilinearly interpolated.
;
;	SILENT = if set, no information about the iterations is 
;		displayed.
;
;	MISSING = specifies the output value for points whose x, y
;		are outside the bounds of B array. If MISSING is not
;		specified, the resulting output value is extrapolated
;		from the nearest pixel of B.
;
;	CHI = condition for stopping. Program will stop convergence
;		whenever changes in chi-square are less than CHI.
;		Default is CHI = 0.001
;
; OUTPUTS:
;	X0, Y0, ANGLE = calculated values for the coefficients of 
;		the transformation.
;
; OPTIONAL OUTPUT:
;	C = spatially shifted and rotated image B. Although the
;		computation is carried on floating point numbers,
;		result will be the same type as B.
;
;	FLAG = flag which is set to 1 on output whenever the convergence
;		is not reached.
;
;	WEIGHT = array of weights, of same dimensions than A and B.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Image B is redistorted by means of a non-linear least-squares
;	analysis to match the image A.
;
; REFERENCES:
;	- R. Molowny: 1994, Ph.D. Thesis, University of Oslo.
;	- "Numerical Recipes", Fortran version, Press et al, 1989,
;	  pag. 521-528
;	- IDL User's Guide, version 2.0, 1990, Research Systems,
;	  pag. B-68
;
; EXAMPLES:
;	Let A be an image, and B the result of:
;
;	IDL> B = SHIFT(ROT_INT(A,2.5),3,-2)
;
;	To find the best match, we must do:
;
;	IDL> X0 = 0.
;	IDL> Y0 = 0.
;	IDL> ANGLE = 0.
;	IDL> ROTALIGN,A,B,X0,Y0,ANGLE
;
;	The outputs should be approximately X0 = 3; Y0 = -2 and
;	ANGLE = -2.5. Bilinear interpolation has been employed.
;
; MODIFICATION HISTORY:
;	R. Molowny-Horas, January 1993.
;	Minor modifications, Sept. 93, RMH.
;	Changed to POLY_2D. Added cubic interpolation. January 1994, RLMH.
;-
;
ON_ERROR,2

	s = SIZE(a)			;Image size.

	IF s(1) NE N_ELEMENTS(b(*,0)) OR s(2) NE N_ELEMENTS(b(0,*)) THEN $
		MESSAGE,'Input arrays have wrong dimensions'
	IF N_PARAMS(0) LT 5 THEN MESSAGE,'Wrong number of inputs'

	np = FLOAT(s(1)) * s(2)				;Number of points.
	IF NOT KEYWORD_SET(niter) THEN niter = 20	;20 iterations.
	IF NOT KEYWORD_SET(interp) THEN in = 1 ELSE $	;Interpolation method.
		in = 2
	IF NOT KEYWORD_SET(chi) THEN chi = 0.001	;Criteria for converg.
	nw = N_ELEMENTS(w)

	theta = angle * !dtor		;Angle in radians CLOCKWISE

	flag = 0			;Sets flag.

	xc = (s(1)-1.)/2.		;Centre of coordinates.
	yc = (s(2)-1.)/2.

	x = LINDGEN(s(1),s(2))		;Coordinates X and Y.
	y = FIX(x / s(1))
	x = FIX(x MOD s(1))

	fb = b - TOTAL(b)/np + TOTAL(a)/np	;Substracting the means.

	derx = SHIFT(FLOAT(b),-1,0) - SHIFT(b,1,0)	;Derivatives in X.
	derx(0,0) = -3.*b(0,*) + 4.*b(1,*) - b(2,*)
	derx(s(1)-1,0) = 3.*b(s(1)-1,*) - 4.*b(s(1)-2,*) + b(s(1)-3,*)
	derx = TEMPORARY(derx)/ 2.

	dery = SHIFT(FLOAT(b),0,-1) - SHIFT(b,0,1)	;Derivatives in Y.
	dery(0,0) = -3.*b(*,0) + 4.*b(*,1) - b(*,2)
	dery(0,s(2)-1) = 3.*b(*,s(2)-1) - 4.*b(*,s(2)-2) + b(*,s(2)-3)
	dery = TEMPORARY(dery) / 2.

	lambda = 0.001			;Parameter of Marquardt's method.
	diag = [0,1,2]			;Diagonal terms in Hessian matrix.

	FOR iter = 1,niter DO BEGIN
		p = [x0+xc-xc*COS(theta)+yc*SIN(theta),-SIN(theta), $
			COS(theta),0.]
		q = [y0+yc-xc*SIN(theta)-yc*COS(theta),COS(theta), $
			SIN(theta),0.]
		chisqr = POLY_2D(fb,p,q,missing=1E32,in);Transform.
		good = chisqr NE 1E32			;Points outside?
		nz = TOTAL(good)			;Number of good points.
		IF nw NE 0 THEN good =TEMPORARY(good)*w	;Masking image.
		chisqr = a - TEMPORARY(chisqr)
		chisq1 = TOTAL(chisqr*good*chisqr)/nz	;Chi-squared.

		derix = POLY_2D(derx,p,q,in)*good	;Interp. the deriv.
		deriy = POLY_2D(dery,p,q,in)*good

		ftheta = -derix*(x*SIN(theta)-xc*SIN(theta)+y*COS(theta)-$
			yc*COS(theta)) + deriy*(x*COS(theta)-xc*COS(theta)-$
			y*SIN(theta)+yc*SIN(theta))

		beta = TOTAL(derix*chisqr)		;Coefficients matrix.
		beta = [beta,TOTAL(deriy*chisqr)]
		beta = [beta,TOTAL(ftheta*chisqr)]
		chisqr = 0

		alpha = FLTARR(3,3)		;Hessian matrix.
		alpha(0,0) = TOTAL(derix*derix)
		alpha(0,1) = TOTAL(derix*deriy) & alpha(1,0) = alpha(0,1)
		alpha(0,2) = TOTAL(derix*ftheta) & alpha(2,0) = alpha(0,2)
		alpha(1,1) = TOTAL(deriy*deriy)
		alpha(1,2) = TOTAL(deriy*ftheta) & alpha(2,1) = alpha(1,2)
		alpha(2,2) = TOTAL(ftheta*ftheta)
		ftheta = 0 & derix = 0 & deriy = 0

		REPEAT BEGIN		;Marquardt's method.
			array = alpha
			array(diag,diag) = array(diag,diag) * (1.+lambda)
			LUDCMP,array,index,delta	;LU decomposition!!!
			delta = beta
			LUBKSB,array,index,delta

			es_x0 = x0 + delta(0)		;Let's try this!
			es_y0 = y0 + delta(1)
			es_theta = theta + delta(2)

			p = [es_x0+xc-xc*COS(es_theta)+yc*SIN(es_theta), $
				-SIN(es_theta),COS(es_theta),0.]
			q = [es_y0+yc-xc*SIN(es_theta)-yc*COS(es_theta), $
				COS(es_theta),SIN(es_theta),0.]

			chisqr = POLY_2D(fb,p,q,missing=1E32,in)
			good = chisqr NE 1E32
			nz = TOTAL(good)
			IF nw NE 0 THEN good = TEMPORARY(good) * w
			chisqr = TEMPORARY(chisqr) - a
			chisqr = TOTAL(chisqr*good*chisqr)/nz	;Chi-squared.
			lambda = lambda * 10.		;Increase lambda
		ENDREP UNTIL chisqr LE chisq1	;Is it a valid step?

		lambda = lambda / 100.
		x0 = es_x0			;Valid estimates.
		y0 = es_y0
		theta = es_theta

		IF NOT KEYWORD_SET(silent) THEN BEGIN	;Print information.
			PRINT,' '
			PRINT,' Iteration = ' + STRTRIM(STRING(iter),2) + $
				'.  Chi-square = ' + STRTRIM(STRING(chisqr),2)
		ENDIF

		IF ((chisq1-chisqr)/chisq1) LE chi THEN GOTO,DONE

	ENDFOR

	MESSAGE,'Failed to converge',/INFORMATIONAL
	flag = 1				;Sets flag.

DONE:

	angle = theta * !radeg		;Output in degrees.
	IF N_PARAMS(0) GT 5 THEN IF N_ELEMENTS(missing) EQ 0 THEN $
	c = POLY_2D(b,p,q,in) ELSE c = POLY_2D(b,p,q,missing=missing,in)

END

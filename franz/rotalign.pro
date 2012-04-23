PRO ROTALIGN , A , B , X0 , Y0 , ANGLE , C , NITER = niter, $
	SILENT = silent , OUTSIDE = outside , CHI = chi , FLAG = flag
;+
; NAME:
;	ROTALIGN
;
; PURPOSE:
;	Find the coefficients of an affine transformation to match
;	image B over A. Only field rotation and misalignment are considered.
;
; CALLING SEQUENCE:
;	ROTALIGN , A , B , X0 , Y0 , ANGLE, [ C , NITER = ,
;		MISSING = , SILENT = ] )
;
; INPUTS:
;	A = the reference image.
;
;	B = the distorted image. B is assumed to be the result of a spatial
;		transformation over the image B.
;
; 	X0,Y0 = first guess for the position of center of rotation.
;
;	ANGLE = guess for the angle, in degrees, to rotate B clockwise
;		for to match A.
;
; KEYWORDS:
;	NITER = specifies the number of iterations. If not set,
;		niter = 20.
;
;	SILENT = if set, no information about the iterations is 
;		displayed.
;
;	OUTSIDE = specifies the output value for points whose x, y
;		are outside the bounds of B array. If OUTSIDE is not
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
;	- R. Molowny: 1993, Ph.D. Thesis, University of Oslo.
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
;	ANGLE = -2.5
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, January 1993.
;-
;
ON_ERROR,2

	s = SIZE(a)
	IF s(1) NE N_ELEMENTS(b(*,0)) OR s(2) NE N_ELEMENTS(b(0,*)) THEN $
		MESSAGE,'Input arrays have wrong dimensions'

	IF NOT KEYWORD_SET(niter) THEN niter = 20	;20 iterations.
	IF NOT KEYWORD_SET(chi) THEN chi = 0.001

	theta = angle * !dtor		;Angle in radians CLOCKWISE

	flag = 0			;Sets flag.

	xc = (s(1)-1.)/2.		;Centre of coordinates.
	yc = (s(2)-1.)/2.

	x = LINDGEN(s(1),s(2))		;Coordinates X and Y.
	y = FLOAT(x / s(1)) - yc
	x = FLOAT(x MOD s(1)) - xc

	fa = a - TOTAL(a)/s(1)/s(2)	;Substract the mean to the images.
	fb = b - TOTAL(b)/s(1)/s(2)

	derx = SHIFT(fb,-1,0) - SHIFT(fb,1,0)	;First derivatives in X.
	derx(0,0) = -3.*fb(0,*) + 4.*fb(1,*) - fb(2,*)
	derx(s(1)-1,0) = 3.*fb(s(1)-1,*) - 4.*fb(s(1)-2,*) + fb(s(1)-3,*)
	derx = derx / 2.

	dery = SHIFT(fb,0,-1) - SHIFT(fb,0,1)	;Derivatives in Y.
	dery(0,0) = -3.*fb(*,0) + 4.*fb(*,1) - fb(*,2)
	dery(0,s(2)-1) = 3.*fb(*,s(2)-1) - 4.*fb(*,s(2)-2) + fb(*,s(2)-3)
	dery = dery / 2.

	lambda = 0.001			;Parameter of Marquardt's method.
	diag = [0,1,2]

	xx = x0 + x*COS(theta) - y*SIN(theta) + xc
	yy = y0 + x*SIN(theta) + y*COS(theta) + yc

	FOR iter = 1,niter DO BEGIN

		bb = INTERPOLATE(fb,xx,yy,missing=-1E32);Interpol. image b.
		nmiss = WHERE(bb NE -1E32,nz);Only these points are good.
		bb = fa - bb
		IF nz NE 0 THEN chisq1 = TOTAL(bb(nmiss)^2)/nz

		derix = INTERPOLATE(derx,xx,yy,missing=0.);Interpol. derivat.
		deriy = INTERPOLATE(dery,xx,yy,missing=0.)

		ftheta = -derix*(x*SIN(theta)+y*COS(theta)) + $
			deriy*(x*COS(theta)-y*SIN(theta))

		beta = TOTAL(derix*bb)		;Coefficients matrix.
		beta = [beta,TOTAL(deriy*bb)]
		beta = [beta,TOTAL(ftheta*bb)]

		alpha = FLTARR(3,3)		;Hessian matrix.
		alpha(0,0) = TOTAL(derix*derix)
		alpha(0,1) = TOTAL(derix*deriy) & alpha(1,0) = alpha(0,1)
		alpha(0,2) = TOTAL(derix*ftheta) & alpha(2,0) = alpha(0,2)
		alpha(1,1) = TOTAL(deriy*deriy)
		alpha(1,2) = TOTAL(deriy*ftheta) & alpha(2,1) = alpha(1,2)
		alpha(2,2) = TOTAL(ftheta*ftheta)
		ftheta = 0 & bb = 0

		REPEAT BEGIN		;Marquardt's method.
			array = alpha
			array(diag,diag) = array(diag,diag) * (1.+lambda)
			array = SVD_SOLVE(array,beta)

			es_x0 = x0 + array(0)		;Let's try this!
			es_y0 = y0 + array(1)
			es_theta = theta + array(2)

			xx = es_x0 + x*COS(es_theta) - y*SIN(es_theta) + xc
			yy = es_y0 + x*SIN(es_theta) + y*COS(es_theta) + yc

			chisqr = INTERPOLATE(fb,xx,yy,missing=-1E32)
			nmiss = WHERE(chisqr NE -1E32,nz)
			IF nz NE 0 THEN chisqr = $
				TOTAL((chisqr(nmiss)-fa(nmiss))^2)/nz
			lambda = lambda * 10.
		ENDREP UNTIL chisqr LE chisq1	;Is it a valid step?

		lambda = lambda / 100.
		x0 = es_x0			;Valid estimates.
		y0 = es_y0
		theta = es_theta

		IF NOT KEYWORD_SET(silent) THEN BEGIN
			PRINT,''
			PRINT,' Iteration = ' + STRTRIM(STRING(iter),2) + $
				'.  Chi-square = ' + STRTRIM(STRING(chisqr),2)
		ENDIF

		IF ((chisq1-chisqr)/chisq1) LE chi THEN GOTO,DONE

	ENDFOR

	MESSAGE,'Failed to converge',/INFORMATIONAL
	flag = 1				;Sets flag.

DONE:

	angle = theta * !radeg		;Output in degrees.
	IF N_PARAMS(0) GT 5 THEN IF N_ELEMENTS(outside) EQ 0 THEN $
	c = INTERPOLATE(b,xx,yy) ELSE c = INTERPOLATE(b,xx,yy,missing=outside)

END
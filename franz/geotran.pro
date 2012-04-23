PRO GEOTRAN,A,B,P,Q, C , WEIGHT = W , INTERP = interp, NITER = niter, $
	OUTSIDE = outside , SILENT = silent , CHI = chi
;+
; NAME:
;	GEOTRAN
;
; PURPOSE:
;	Find the coefficients of the geometrical transformation to match
;	image A over B.
;
; CALLING SEQUENCE:
;	GEOTRAN , A,B,P,Q, [ WEIGHT = W , C , INTERP = , NITER = , 
;		MISSING = , SILENT = , CHI = chi ] )
;
; INPUTS:
;	A = the distorted image. A is assumed to be the result of a spatial
;		transformation over the image B.
;
;	B = the undistorted image.
;
;	P,Q = initial estimates for the coefficients of the geometrical
;		transfomation. See POLY_2D in IDL's users guide for a
;		description.
;
; OPTIONAL INPUTS:
;	W = array of weights. It should be same size as A and B. If not
;		present, w = 1.
;
; KEYWORDS:
;	INTERP = if set, algorithm selects nearest neighbor method;
;		otherwise bilinear interpolation is used.
;
;	NITER = specifies the number of iterations. If not set,
;		niter = 20.
;
;	OUTSIDE = specifies the output value for points whose x', y'
;		is outside the bounds of B array. If OUTSIDE is not
;		specified, the resulting output value is extrapolated
;		from the nearest pixel of B.
;
;	SILENT = if set, no information during the iterations is displayed.
;
;	CHI = condition for stopping. Program will stop convergence
;		whenever changes in chi-square are less than CHI.
;		Default is CHI = 0.001
;
; OUTPUTS:
;	P,Q = calculated values for the coefficients of linear
;		transformation.
;
; OPTIONAL OUTPUT:
;	C = spatially transformed image B. Same type as B.
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
;	The sum of the square differences between the image B and the
;	transformed A is minimized by means of the Marquardt's method.
;	The coefficients P and Q specify the spatial transformation:
;
;		a(x,y) = SUM(i) SUM(j) P(i,j)*X^i*Y^j
;		b(x,y) = SUM(i) SUM(j) Q(i,j)*X^i*Y^j
;
;	Whereas IDL's POLYWARP computes the coefficients of the spatial
;	transformation from the original and the transformed sets
;	of "coordinates", GEOTRAN calculates those coefficients
;	by finding the best match between the two "images", in the sense
;	of least squares. Therefore the transformation parameters do not
;	need to be known; a roughly close initial estimates will suffice.
;	No control points need to be specified.
;
; REFERENCES:
;	- Roberto Luis Molowny Horas, Ph.D. Thesis, University of Oslo.
;	- "Numerical Recipes", Fortran version, Press et al, 1989,
;	  pag. 521-528
;	- "Computer Image Processing and Recognition", Ernest L. Hall
;	  1979, pag. 185-200
;	- IDL User's Guide, version 2.0, 1990, Research Systems, pag. B-68
;	
; EXAMPLES:
;	To find an unknown geometric transformation between images
;	A and B which is described by a 3x3 set of coefficients P and Q,
;	let us take the first estimate as the identity:
;
;	IDL> p = fltarr(3,3) & q = p & p(0,1) = 1. & q(1,0) = 1.
;	IDL> GEOTRAN,a,b,p,q,niter=15,missing=0.
;
;	GEOTRAN will find the P and Q coefficients that will match
;	A into B best, by minimizing the sum of square differences.
;	Bilinear interpolation is selected. Maximum number of 
;	iterations is 15.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, January 1993.
;-
;
ON_ERROR,2

	s = SIZE(a)
	IF s(1) NE N_ELEMENTS(b(*,0)) OR s(2) NE N_ELEMENTS(b(0,*)) THEN $
		MESSAGE,'Input arrays have wrong dimensions'
	n = SIZE(p)
	IF n(1) NE n(2) THEN MESSAGE,'P and Q must be squared'
	IF n(1) NE N_ELEMENTS(q(*,0)) OR n(2) NE N_ELEMENTS(q(0,*)) THEN $
		MESSAGE,'Coefficients have wrong dimensions'

	nterms = 2*n(4)			;There are nterms unknowns.

	IF NOT KEYWORD_SET(interp) THEN interp = 1 $
		ELSE interp = 0				;Default is bilinear.
	IF NOT KEYWORD_SET(niter) THEN niter = 20	;20 iterations.
	IF NOT KEYWORD_SET(chi) THEN chi = 0.001	;Cond. for stopping.

	x = DINDGEN(s(1))		;Coordinates.
	y = DINDGEN(s(2))

	fa = DOUBLE(a) & fa = fa - TOTAL(fa)/s(1)/s(2)	;Substract mean to 
	fb = DOUBLE(b) & fb = fb - TOTAL(fb)/s(1)/s(2)	;the images.

	derx = SHIFT(fb,-1,0) - SHIFT(fb,1,0)	;First derivatives in X.
	derx(0,0) = -3.*fb(0,*) + 4.*fb(1,*) - fb(2,*)
	derx(s(1)-1,0) = 3.*fb(s(1)-1,*) - 4.*fb(s(1)-2,*) + fb(s(1)-3,*)
	derx = derx / 2.

	dery = SHIFT(fb,0,-1) - SHIFT(fb,0,1)	;Derivatives in Y.
	dery(0,0) = -3.*fb(*,0) + 4.*fb(*,1) - fb(*,2)
	dery(0,s(2)-1) = 3.*fb(*,s(2)-1) - 4.*fb(*,s(2)-2) + fb(*,s(2)-3)
	dery = dery / 2.

	lambda = 0.001D			;Parameter of Marquardt's method.
	diag = INDGEN(nterms)		;Diagonal terms in alpha matrix.
	IF N_ELEMENTS(w) EQ 0 THEN w = REPLICATE(1.,s(1),s(2))

	pp = p & qq = q			;Creates temporary arrays.

	FOR iter = 1,niter DO BEGIN
		bb = POLY_2D(fb,p,q,missing=-1E32,interp);Interpol. image b.
		nmiss = WHERE(bb NE -1E32,nz)	;Only these points are good.
		bb = fa - bb
		IF nz NE 0 THEN chisq1 = TOTAL(bb(nmiss)^2*w(nmiss))/nz
		bb = bb * w

		derix = POLY_2D(derx,p,q,missing=0.,interp);Interpol. derivat.
		deriy = POLY_2D(dery,p,q,missing=0.,interp)

		beta = DBLARR(nterms,/nozero)	;Matrix for linear system.
		bx = bb*derix & by = bb*deriy & bb = 0
		FOR i = 0,n(1)-1 DO BEGIN	;Computing the gradient.
			bbx = y^i
			bby = by # bbx		;Temporary arrays.
			bbx = bx # bbx
			FOR j = 0,n(1)-1 DO BEGIN;Tricks to spare computation.
				xj = x^j
				beta(i*n(1)+j) = TOTAL(bbx*xj)
				beta(i*n(1)+j+n(4)) = TOTAL(bby*xj)
				xj = 0
			ENDFOR
			bbx = 0 & bby = 0
		ENDFOR
		bx = 0 & by = 0

		xx = derix*derix*w	;Chi-squared's second derivative.
		xy = derix*deriy*w
		yy = deriy*deriy*w
		derix = 0 & deriy = 0

		alpha = DBLARR(nterms,nterms,/nozero)	;Hessian matrix.
		FOR i = 0,n(1)-1 DO FOR k = 0,n(1)-1 DO BEGIN
			axx = y^(i+k)
			axy = xy # axx		;Temporary arrays.
			ayy = yy # axx
			axx = xx # axx
			FOR j = 0,n(1)-1 DO FOR l = 0,n(1)-1 DO BEGIN
				xjl = x^(j+l)
				dumb = TOTAL(axx*xjl)
				alpha(i*n(1)+j,k*n(1)+l) = dumb
				alpha(k*n(1)+l,i*n(1)+j) = dumb
				dumb = TOTAL(axy*xjl)
				alpha(i*n(1)+j+n(4),k*n(1)+l) = dumb
				alpha(i*n(1)+j,k*n(1)+l+n(4)) = dumb
				alpha(k*n(1)+l,i*n(1)+j+n(4)) = dumb
				alpha(k*n(1)+l+n(4),i*n(1)+j) = dumb
				dumb = TOTAL(ayy*xjl)
				alpha(i*n(1)+j+n(4),k*n(1)+l+n(4)) = dumb
				alpha(k*n(1)+l+n(4),i*n(1)+j+n(4)) = dumb
				xjl = 0
			ENDFOR
			axx = 0 & axy = 0 & ayy = 0
		ENDFOR
		xx = 0 & xy = 0 & yy = 0

		REPEAT BEGIN		;Marquardt's method.
			array = alpha
			array(diag,diag) = array(diag,diag) * (1.+lambda)
			array = SVD_SOLVE(array,beta)	;Estimate.
			inc = 0
			FOR i = 0,n(1)-1 DO FOR j = 0,n(1)-1 DO BEGIN
				pp(i,j) = p(i,j) + array(inc)	;Stores coeff.
				qq(i,j) = q(i,j) + array(inc+n(4))
				inc = inc + 1
			ENDFOR
			chisqr = POLY_2D(fb,pp,qq,interp,missing=-1E32)
			nmiss = WHERE(chisqr NE -1E32,nz)
			chisqr = (fa-chisqr)^2 * w
			IF nz NE 0 THEN chisqr = TOTAL(chisqr(nmiss))/nz
			lambda = lambda * 10.
		ENDREP UNTIL chisqr LE chisq1	;Is it a valid step?

		lambda = lambda / 100.		;Decreases parameter.

		p = pp				;New approximation.
		q = qq

		IF NOT KEYWORD_SET(silent) THEN BEGIN
			PRINT,''
			PRINT,' Iteration = ' + STRTRIM(STRING(iter),2) + $
				'.  Chi-squared = ' + STRTRIM(STRING(chisqr),2)
		ENDIF

		IF ((chisq1-chisqr)/chisq1) LE chi THEN GOTO,DONE

	ENDFOR

	MESSAGE,'Failed to converge',/INFORMATIONAL

DONE:				;We may want to have a corrected image. So...

	IF N_PARAMS(0) GT 4 THEN IF N_ELEMENTS(outside) EQ 0 THEN $
		c = POLY_2D(b,p,q,interp) ELSE $
		c = POLY_2D(b,p,q,interp,missing=outside)

END
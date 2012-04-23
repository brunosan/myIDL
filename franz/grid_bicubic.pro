FUNCTION grid_BICUBIC,A,X,Y,DX,DY,DXY
;+
; NAME:
;	BICUBIC
; PURPOSE:
;	Determine bicubic interpolation at a set of reference points.
; CALLING SEQUENCE:
;	Result = BICUBIC(A,X,Y)
; INPUTS:
;	A = image to be interpolated.
;	X,Y = set of reference points.
; OPTIONAL INPUTS:
;	DX = array with derivatives in X direction.
;	DY = array with derivatives in Y direction.
;	DXY = array with cross derivatives.
; OUTPUTS:
;	Result = the interpolated array.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	Slow.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	It computes the coefficients to multiply the abscisaes, first
;	derivatives and cross derivatives. Afterwards it calculates the
;	new value in the coordinates specified. In case the derivatives
;	in the array A have previously been calculated, they can be given
;	as inputs. It makes this routine fairly general.
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, July 1992.
;-
;
ON_ERROR,2

	s = SIZE(a)
	n = N_PARAMS(0)
	IF n LT 3 THEN MESSAGE,'Wrong number of inputs'
	IF s(0) NE 2 THEN MESSAGE,'Input array must be 2-D'

	cc = FLTARR(16,16)			;Matrix of equation system.
	t = [0,0,1,1]				;Points in vertix of square.
	u = [0,1,1,0]
	FOR k = 0,3 DO BEGIN
		inc = 0
		FOR i = 0,3 DO FOR j = 0,3 DO BEGIN
		cc(inc,k) = t(k)^i * u(k)^j	     	;Abscisae values.
		cc(inc,k+4) = i * t(k)^(i-1) * u(k)^j	;Derivatives with X.
		cc(inc,k+8) = j * t(k)^i * u(k)^(j-1)	;Derivatives with Y.
		cc(inc,k+12) = i * j * t(k)^(i-1) * u(k)^(j-1)	;Cross deriv.
		inc = inc + 1
		ENDFOR
	ENDFOR

	cc = INVERT(cc)					;Inverts coef. matrix.

	IF n LT 6 THEN dxy = (SHIFT(a,-1,-1) - $	;Cross derivatives.
		SHIFT(a,-1,1) + SHIFT(a,1,1) - SHIFT(a,1,-1))/4.
	IF n LT 5 THEN dy = (SHIFT(a,0,-1) - $		;Y derivatives.
		SHIFT(a,0,1)) / 2.
	IF n LT 4 THEN dx = (SHIFT(a,-1,0) - $		;X derivatives.
		SHIFT(a,1,0)) / 2.

	ix = (x > 0.) < (s(1)-1.)			;Grids.
	xx = ix - FIX(ix)
	ix = FIX(ix)
	jy = (y > 0.) < (s(2)-1.)
	yy = jy - FIX(jy)
	jy = FIX(jy)

	b = 0.
	FOR k = 0,15 DO BEGIN
		accum = 0.
		CASE 1 OF
			(k EQ 0): coef = a		;Abscisae values.
			(k EQ 1): coef = SHIFT(a,0,-1)
			(k EQ 2): coef = SHIFT(a,-1,-1)
			(k EQ 3): coef = SHIFT(a,-1,0)
			(k EQ 4): coef = dx		;X-derivatives.
			(k EQ 5): coef = SHIFT(dx,0,-1)
			(k EQ 6): coef = SHIFT(dx,-1,-1)
			(k EQ 7): coef = SHIFT(dx,-1,0)
			(k EQ 8): coef = dy		;Y-derivatives.
			(k EQ 9): coef = SHIFT(dy,0,-1)
			(k EQ 10): coef = SHIFT(dy,-1,-1)
			(k EQ 11): coef = SHIFT(dy,-1,0)
			(k EQ 12): coef = dxy		;Cross derivatives.
			(k EQ 13): coef = SHIFT(dxy,0,-1)
			(k EQ 14): coef = SHIFT(dxy,-1,-1)
			(k EQ 15): coef = SHIFT(dxy,-1,0)
			ENDCASE
		ind = 0
		FOR i = 0,3 DO FOR j = 0,3 DO BEGIN
			IF cc(k,ind) NE 0 THEN CASE 1 OF
				(i EQ 0) AND (j EQ 0): accum = accum+cc(k,ind)
				(i EQ 0) AND (j NE 0): accum = accum + $
					yy^j * cc(k,ind)
				(i NE 0) AND (j EQ 0): accum = accum + $
					xx^i * cc(k,ind)
				ELSE: accum = accum + xx^i * yy^j * cc(k,ind)
				ENDCASE
			ind = ind + 1
		ENDFOR
		b = b + coef(ix,jy) * accum
	ENDFOR

	RETURN,b
END





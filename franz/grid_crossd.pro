FUNCTION GRID_CROSSD,A,X,Y
;+
; NAME:
;	GRID_CROSSD
;
; PURPOSE:
;	Remap an image using a grid X,Y.
;
; CALLING SEQUENCE:
;	Result = GRID_CROSSD(A,X,Y)
;
; INPUTS:
;	A = 2-D array to be remapped.
;
;	X,Y = X and Y coordinates for the new pixels.
;
; OUTPUTS:
;	Result = the remapped image.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	It uses the Taylor expansion:
;
;		Result = a + b*x + c*y + d*x^2 + e*y^2 + f*x*y
;
;	around the nearest point.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, July 1992.
;
;-
;
ON_ERROR,2

	ss = SIZE(a)
	aa = FLOAT(a)			;Converts to floating point data type.

	ix = RFIX(x)			;Rounds to nearest pixel.
	jy = RFIX(y)
	dx = x - ix			;Differences for Taylor expansion.
	dy = y - jy

	b = a(ix,jy)					;Constant "a"
	coef = .5 * (SHIFT(aa,-1,0) - SHIFT(aa,1,0))
	b = b + coef(ix,jy) * dx			;Term "b"
	coef = .5 * (SHIFT(aa,0,-1) - SHIFT(aa,0,1))
	b = b + coef(ix,jy) * dy			;Term "c"
	coef = .5 * (SHIFT(aa,-1,0) + SHIFT(aa,1,0)) - a
	b = b + coef(ix,jy) * dx * dx			;Term "d"
	coef = .5 * (SHIFT(aa,0,-1) + SHIFT(aa,0,1)) - a
	b = b + coef(ix,jy) * dy * dy			;Term "e"
	coef = .25 * (SHIFT(aa,1,1) + SHIFT(aa,-1,-1) - SHIFT(aa,-1,1) - $
		SHIFT(aa,1,-1))
	b = b + coef(ix,jy) * dx * dy			;Term "f"

	aa = 0 & ix = 0 & jy = 0 & dx = 0 & dy = 0
	m = WHERE(x LT 0 OR x GT ss(1)-1 OR y LT 0 OR y GT ss(2)-1,nz)
	a_mean = TOTAL(a)/ss(1)/ss(2)
	IF nz NE 0 THEN b(m) = a_mean			;Points outside.

	RETURN,b
	END

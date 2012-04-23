FUNCTION shift_BICUB,IMAGE,X0,Y0
;+
; NAME:
;	shift_bicub
; PURPOSE:
;	shift an image using 2-D bicubic interpolation.
; CALLING SEQUENCE:
;	Result = shift_bicub(A,X0,Y0)
; INPUTS:
;	IMAGE =  image to be shifted.
; OPTIONAL INPUT PARAMETERS:
;	X0 = Shift to give the image in X-direction.
;	Y0 = 	"	"	"	Y-direction.
; OUTPUTS:
;	Result = Translated input image.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	None.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;
; MODIFICATION HISTORY:
;	Z. Yi, UiO, Feb. 1992
;====================================================================
;-
	ON_ERROR,2

	cc	= FLTARR(16,16)			;Matrix of equation system.
	t	= [0,0,1,1]			;Points in vertix of square.
	u	= [0,1,1,0]
	FOR k	= 0,3 DO BEGIN
		inc	= 0
		FOR i	= 0,3 DO FOR j = 0,3 DO BEGIN
		cc(inc,k) = t(k)^i * u(k)^j	     	;Abscisae values.
		cc(inc,k+4) = i * t(k)^(i-1) * u(k)^j	;Derivatives with X.
		cc(inc,k+8) = j * t(k)^i * u(k)^(j-1)	;Derivatives with Y.
		cc(inc,k+12) = i * j * t(k)^(i-1) * u(k)^(j-1)	;Cross deriv.
		inc	= inc + 1
		ENDFOR
	ENDFOR
	cc	= INVERT(cc)			;The matrix is inverted.
;
	A	= FLOAT(IMAGE)
	siz	= SIZE(A)
	fx	= (SHIFT(A,-1,0) - SHIFT(A,1,0)) / 2.	;Derivatives with X.
	fy	= (SHIFT(A,0,-1) - SHIFT(A,0,1)) / 2.	;Derivatives with Y.
	fxy	= (SHIFT(A,-1,-1) - SHIFT(A,-1,1) - $   ;Cross derivatives
		SHIFT(A,1,-1) + SHIFT(A,1,1)) / 4.
;
	kx	= (X0 GT 0) + FIX(X0) - X0		;Small shifts.
	ky	= (Y0 GT 0) + FIX(Y0) - Y0
	pp	= FLTARR(16)
	FOR i	= 0,3 DO FOR j = 0,3 DO pp(i*4+j) = (kx)^i * (ky)^j
	B	= 0.
	FOR i	= 0,15 DO FOR j	= 0,15 DO IF cc(i,j) NE 0 THEN BEGIN
		CASE 1 OF
			(i EQ 0): coef = A		;Abscisae values.
			(i EQ 1): coef = SHIFT(A,0,-1)
			(i EQ 2): coef = SHIFT(A,-1,-1)
			(i EQ 3): coef = SHIFT(A,-1,0)
			(i EQ 4): coef = fx		;X-derivatives.
			(i EQ 5): coef = SHIFT(fx,0,-1)
			(i EQ 6): coef = SHIFT(fx,-1,-1)
			(i EQ 7): coef = SHIFT(fx,-1,0)
			(i EQ 8): coef = fy		;Y-derivatives.
			(i EQ 9): coef = SHIFT(fy,0,-1)
			(i EQ 10): coef = SHIFT(fy,-1,-1)
			(i EQ 11): coef = SHIFT(fy,-1,0)
			(i EQ 12): coef = fxy		;Cross derivatives.
			(i EQ 13): coef = SHIFT(fxy,0,-1)
			(i EQ 14): coef = SHIFT(fxy,-1,-1)
			(i EQ 15): coef = SHIFT(fxy,-1,0)
		ENDCASE
		B = B + cc(i,j) * pp(j) * coef
	ENDIF
;
RETURN,SHIFT(B,kx+X0,ky+Y0)			;Integer shift and return.
END














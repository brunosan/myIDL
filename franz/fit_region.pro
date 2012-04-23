FUNCTION FIT_REGION,A,N,DX,DY
;+
; NAME:
;	FIT_REGION
;
; PURPOSE:
;	Determine polynomial fit to a region of a surface by using
;	least squares. Sometimes it is desired not to use the whole 
;	array in fitting a surface to it, for they may contain strong
;	gradients which would bias the result.
;
; CALLING SEQUENCE:
;	Result = FIT_REGION(A,N,DX,DY)
;
; INPUTS:
;	A = two dimensional array of data to be fitted to. It is not
;		modified on output.
;	N = vector of subscripts of pixels inside region of interest,
;		like defined by DEFROI.
;	DX & DY = degree of fit in X,Y directions. If only one is
;		specified, program will assume DX = DY
;
; OUTPUTS:
;	Result = two dimensional floating point array with evaluation
;		of the polynomial fit. Same dimensions as A.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Slow.
;	Number of points in A must be greater or equal to (DX+1)*(DY+1).
;
; PROCEDURE:
;	Simple modification of FIT_SURFACE.
;
; EXAMPLES:
;	Let ARRAY be the 500x500 pixels image we want to fit a surface
;	to, using only two regions of it. The procedure would be:
;
;	IDL> TVSCL,array		;Shows the image.
;	IDL> n = [DEFROI(500,500),DEFROI(500,500)]	;Picks the regions.
;	IDL> result = FIT_REGION(array,n,3,2)	;Result. Surface degree is
;						;3 in X and 2 in Y directions.
;
; MODIFICATION HISTORY:
;	Modified from FIT_SURFACE by Roberto Luis Molowny Horas,
;	November 1992.
;
;-
;
ON_ERROR,2

	IF N_PARAMS(0) LT 4 THEN IF N_PARAMS(0) LT 2 THEN MESSAGE, $
		'Wrong number of arguments' ELSE dy = dx

	s = SIZE(a)
	nx = dx + 1
	ny = dy + 1

	x = FLOAT(n MOD s(1)) - (s(1)-1.)/2.	;Rectangular coordinates.
	y = FLOAT(n/s(1)) - (s(2)-1.)/2.

	alfa = FLTARR(nx*ny,nx*ny)	;Matrices for LU decomposition.
	beta = FLTARR(nx*ny)

	inc1 = 0
	FOR i = 0,dx DO FOR j = 0,dy DO BEGIN
		beta(inc1) = TOTAL(a(n) * x^i * y^j)
		inc2 = 0
		FOR k = 0,dx DO FOR l = 0,dy DO BEGIN
			alfa(inc1,inc2) = TOTAL(x^(i+k)*y^(j+l));Matrix to be
			inc2 = inc2 + 1				;LU decomposed.
		ENDFOR
		inc1 = inc1 + 1
	ENDFOR

	dummy = FINDGEN(s(1)) - (s(1)-1.)/2.
	x = FLTARR(s(1),nx,/nozero)
	FOR i = 0,dx DO x(0,i) = dummy^i	;Grids.
	dummy = FINDGEN(s(2)) - (s(2)-1.)/2.
	y = FLTARR(s(2),ny,/nozero)
	FOR i = 0,dy DO y(0,i) = dummy^i	;Grids.

	beta = SVD_SOLVE(alpha,beta)	;Solves the linear system.

	inc = 0
	surface = FLTARR(s(1),s(2))
	FOR i = 0,dx DO FOR j = 0,dy DO BEGIN	;Makes the resulting surface.
		xx = beta(inc) * x(*,i)
		surface = surface + xx # y(*,j)	;Evaluation.
		inc = inc + 1
	ENDFOR

	RETURN,surface			;Fitted surface.
END
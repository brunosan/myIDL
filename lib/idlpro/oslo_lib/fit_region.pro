FUNCTION FIT_REGION,A,N,DX,DY
;+
; NAME:
;	FIT_REGION
;
; PURPOSE:
;	Determine polynomial fit to a region of a surface by using
;	least squares.
;
; CALLING SEQUENCE:
;	Result = FIT_SURFACE(A,N,DX,DY)
;
; INPUTS:
;	A = two dimensional array of data to be fitted to. It is not
;		modified on output.
;
;	N = vector of subscripts of pixels inside region of interest,
;		like defined by DEFROI.
;
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
;	The normal equations of the least-squares problem (Ax = B) are
;	solved by using LU decomposition. The new fitted surface is
;	then evaluated. The coordinates are taken to be centered in the
;	image, thus avoiding some floating overflow errors. If overflow
;	error messages persist, edit the program and change to double
;	precision.
;
; MODIFICATION HISTORY:
;	Modified from FIT_SURFACE by Roberto Molowny-Horas,
;		November 1992.
;	Minor error corrected. Hessian matrix is inverted by LU routines,
;		1993, RMH
;	Slight improvement in the algorithm, June 1994, RMH
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

	an = a(n)

	inc1 = 0			;Fills in gradient matrix.
	FOR i = 0,dx DO BEGIN
		dummy = an*x^i
		FOR j = 0,dy DO BEGIN
			beta(inc1) = TOTAL(dummy * y^j)
			inc1 = inc1 + 1
		ENDFOR
	ENDFOR

	inc1 = 0			;Fills in hessian matrix.
	FOR i = 0,dx DO FOR j = 0,dy DO BEGIN
		inc2 = 0
		FOR k = 0,dx DO FOR l = 0,dy DO BEGIN
			alfa(inc1,inc2) = TOTAL(x^(i+k)*y^(j+l));Matrix to be
			inc2 = inc2 + 1				;LU decomposed.
		ENDFOR
		inc1 = inc1 + 1
	ENDFOR

	LUDCMP,alfa,index,d		;Replaces alfa with its LU decompos.
	LUBKSB,alfa,index,beta		;Solves the set of linear equations.

	dummy = FINDGEN(s(1)) - (s(1)-1.)/2.
	x = FLTARR(s(1),nx,/nozero)
	FOR i = 0,dx DO x(0,i) = dummy^i
	dummy = FINDGEN(s(2)) - (s(2)-1.)/2.
	y = FLTARR(s(2),ny,/nozero)
	FOR i = 0,dy DO y(0,i) = dummy^i

	inc = 0
	surface = FLTARR(s(1),s(2))
	FOR i = 0,dx DO FOR j = 0,dy DO BEGIN
		xx = beta(inc) * x(*,i)
		surface = surface + xx # y(*,j)	;Evaluation.
		inc = inc + 1
	ENDFOR

	RETURN,surface			;Fitted surface.
END
FUNCTION FIT_SURFACE,A,DX,DY
;+
; NAME:
;	FIT_SURFACE
;
; PURPOSE:
;	Determine polynomial fit to a surface by using linear least squares.
;
; CALLING SEQUENCE:
;	Result = FIT_SURFACE(A,DX,DY)
;
; INPUTS:
;	A = two dimensional array of data to be fit to. It is not modified
;		on output.
;
;	DX & DY = degree of fit in X,Y  directions. If only one is specified,
;		program will assume DX = DY.
;
; OUTPUT:
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
;	The number of data points in A must be greater or equal to
;	(DX+1)*(DY+1).
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
;	Written by Roberto Molowny-Horas, November 1991
;	Use LU decomposition, 1993, RMH
;	Changes to prevent overflow, 1994, RMH
;-
ON_ERROR,2
	IF N_PARAMS(0) LT 3 THEN IF N_PARAMS(0) LT 2 THEN MESSAGE, $
		'Wrong number of arguments' ELSE dy = dx

	s = SIZE(a)
	IF dx GT s(1) OR dy GT s(2) THEN MESSAGE,'Too large degree of fit'
	nx = dx + 1
	ny = dy + 1

	dummy = FINDGEN(s(1))			;Centre of image.
	dummy = dummy/(s(1)-1.)-.5		;Prevent overflows.
	x = FLTARR(s(1),nx,/nozero)
	FOR i = 0,dx DO x(0,i) = dummy^i	;Powers from 0 to dx.
	xx = FLTARR(2*dx+1)
	FOR i = 0,2*dx DO xx(i) = TOTAL(dummy^i);Powers from 0 to 2*dx

	dummy = FINDGEN(s(2))			;Same for y.
	dummy = dummy/(s(2)-1.)-.5		;Prevent overflows.
	y = FLTARR(s(2),ny,/nozero)
	FOR i = 0,dy DO y(0,i) = dummy^i
	yy = FLTARR(2*dy+1)
	FOR i = 0,2*dy DO yy(i) = TOTAL(dummy^i)

	alfa = FLTARR(nx*ny,nx*ny,/nozero)	;Matrices for LU decomposition.
	beta = FLTARR(nx*ny,/nozero)

	inc1 = 0
	FOR i = 0,dx DO FOR j = 0,dy DO BEGIN
		IF j EQ 0 THEN row = x(*,i) # a
		beta(inc1) = TOTAL(row * y(*,j))
		inc2 = 0
		FOR k = 0,dx DO FOR l = 0,dy DO BEGIN
			alfa(inc1,inc2) = xx(i+k)*yy(j+l)	;Matrix to be
			inc2 = inc2 + 1				;LU decomposed.
		ENDFOR
		inc1 = inc1 + 1
	ENDFOR

	LUDCMP,alfa,index,d		;Replaces alfa with its LU decompos.
	LUBKSB,alfa,index,beta		;Solves the set of linear equations.

	inc = 0
	surface = FLTARR(s(1),s(2))
	FOR i = 0,dx DO FOR j = 0,dy DO BEGIN
		xx = beta(inc) * x(*,i)
		surface = surface + xx # y(*,j)	;Evaluation.
		inc = inc + 1
	ENDFOR

	RETURN,surface			;Fitted surface.

END

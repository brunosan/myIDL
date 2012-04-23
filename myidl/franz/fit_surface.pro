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
;	solved by using SVD routines. The new fitted surface is
;	then evaluated. The coordinates are taken to be centered in the
;	image, thus avoiding some floating overflow errors. Also, they
;	are divided by 50, for the same reason.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, November 1991.
;
;-
ON_ERROR,2
	IF N_PARAMS(0) LT 3 THEN IF N_PARAMS(0) LT 2 THEN MESSAGE, $
		'Wrong number of arguments' ELSE dy = dx

	s = SIZE(a)
	IF dx GT s(1) OR dy GT s(2) THEN MESSAGE,'Too large degree of fit'
	nx = dx + 1
	ny = dy + 1

	dummy = DINDGEN(s(1)) - (s(1)-1.)/2.	;Centre of image.
	x = DBLARR(s(1),nx,/nozero)
	FOR i = 0,dx DO x(0,i) = dummy^i	;Powers from 0 to dx.
	xx = DBLARR(2*dx+1)
	FOR i = 0,2*dx DO xx(i) = TOTAL(dummy^i);Powers from 0 to 2*dx

	dummy = DINDGEN(s(2)) - (s(2)-1.)/2.	;Same for y.
	y = DBLARR(s(2),ny,/nozero)
	FOR i = 0,dy DO y(0,i) = dummy^i
	yy = DBLARR(2*dy+1)
	FOR i = 0,2*dy DO yy(i) = TOTAL(dummy^i)

	alfa = DBLARR(nx*ny,nx*ny,/nozero)	;Storage arrays.
	beta = DBLARR(nx*ny,/nozero)

	inc1 = 0
	FOR i = 0,dx DO FOR j = 0,dy DO BEGIN
		IF j EQ 0 THEN row = x(*,i) # a
		beta(inc1) = TOTAL(row * y(*,j))
		inc2 = 0
		FOR k = 0,dx DO FOR l = 0,dy DO BEGIN
			alfa(inc1,inc2) = xx(i+k)*yy(j+l)
			inc2 = inc2 + 1
		ENDFOR
		inc1 = inc1 + 1
	ENDFOR

	beta = SVD_SOLVE(alfa,beta)	;SVD methods.

	inc = 0
	surface = FLTARR(s(1),s(2))
	FOR i = 0,dx DO FOR j = 0,dy DO BEGIN	;Makes the resulting surface.
		xx = beta(inc) * x(*,i)
		surface = surface + xx # y(*,j)	;Evaluation.
		inc = inc + 1
	ENDFOR

	RETURN,surface			;Fitted surface.

END

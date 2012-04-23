FUNCTION shift_SPLINE,A,X,Y
;+
; NAME:
;	GRID_SPLINE
; PURPOSE:
;	Remap 2-D array A on a set of reference points using natural splines.
; CALLING SEQUENCE:
;	Result = GRID_SPLINE(A,X,Y)
; INPUTS:
;	A = Two dimensional array to be remapped.
;	X,Y = set of reference points to determine spline interpolation.
; OUTPUTS:
;	Result = the interpolated array.
; SIDE EFFECTS:
;	None.
; COMMON BLOCKS:
;	None.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	It uses natural splines to interpolate. First, computes the second
;	derivatives in X and Y direction, and the cross second derivative.
;	This is used to build up the spline interpolation.
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, July 1992.
;-
;

	s = SIZE(a)
	u = FLTARR(s(1),s(2),/NOZERO)		;Dumb array.
	dx = lindgen(s(1),s(2))
	y = dx/s(1)-y
	x = (dx mod s(1))-x
	dy = 0 

	dx = FLTARR(s(1),s(2))			;Second deriv. in X direction.
	FOR i = 1,s(1)-2 DO BEGIN		;Tridiagonal alogorithm.
		sigma = .5*dx(i-1,*) + 2.
		dx(i,0) = -.5/sigma
		u(i,0) = a(i+1,*) - 2.*a(i,*) + a(i-1,*)
		u(i,0) = (3.*u(i,*) - .5*u(i-1,*))/sigma
	ENDFOR
	FOR k = s(1)-2,0,-1 DO dx(k,0) = dx(k,*)*dx(k+1,*) + u(k,*)

	dy = FLTARR(s(1),s(2))			;Second deriv. in Y direction.
	FOR i = 1,s(2)-2 DO BEGIN
		sigma = .5*dy(*,i-1) + 2.
		dy(0,i) = -.5/sigma
		u(0,i) = a(*,i+1) - 2.*a(*,i) + a(*,i-1)
		u(0,i) = (3.*u(*,i) - .5*u(*,i-1))/sigma
	ENDFOR
	FOR k = s(2)-2,0,-1 DO dy(0,k) = dy(*,k)*dy(*,k+1) + u(*,k)

	dxy = FLTARR(s(1),s(2))			;Second deriv. of dy in X.
	FOR i = 1,s(1)-2 DO BEGIN
		sigma = .5*dxy(i-1,*) + 2.
		dxy(i,0) = -.5/sigma
		u(i,0) = dy(i+1,*) - 2.*dy(i,*) + dy(i-1,*)
		u(i,0) = (3.*u(i,*) - .5*u(i-1,*))/sigma
	ENDFOR
	FOR k = s(1)-2,0,-1 DO dxy(k,0) = dxy(k,*)*dxy(k+1,*) + u(k,*)

	u = 0					;They've become useless.
	dy = 0

	xx = (x > 0.) < (s(1)-1.)
	yy = (y > 0.) < (s(2)-1.)
	ix = FIX(xx)				;Integer part of the set of
	jy = FIX(yy)				;reference points.

	coef_a = ix + 1. - xx			;Coefficients for the first
	coef_b = 1. - coef_a			;interpolation in rows.
	coef_c = (coef_a^3-coef_a)/6.
	coef_d = (coef_b^3-coef_b)/6.

	aj = coef_a*a(ix,jy) + coef_b*a(ix+1,jy) + coef_c*dx(ix,jy) + $
		coef_d*dx(ix+1,jy)
	aj1 = coef_a*a(ix,jy+1) + coef_b*a(ix+1,jy+1) + coef_c*dx(ix,jy+1) + $
		coef_d*dx(ix+1,jy+1)

	dyj = coef_a*dy(ix,jy) + coef_b*dy(ix+1,jy) + coef_c*dxy(ix,jy) + $
		coef_d*dxy(ix+1,jy)
	dyj1 = coef_a*dy(ix,jy+1) + coef_b*dy(ix+1,jy+1) + $
		coef_c*dxy(ix,jy+1) + coef_d*dxy(ix+1,jy+1)

	ix = 0 & xx = 0 & dx = 0 & dy = 0 & dxy = 0	;Useless.

	coef_a = jy + 1. - yy			;Coefficients for the last
	coef_b = 1. - coef_a			;interpolation, in the columns.
	coef_c = (coef_a^3-coef_a)/6.
	coef_d = (coef_b^3-coef_b)/6.
	jy = 0

	RETURN,coef_a*aj + coef_b*aj1 + coef_c*dyj + coef_d*dyj1

	END













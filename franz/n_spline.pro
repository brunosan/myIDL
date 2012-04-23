FUNCTION N_SPLINE,X,Y,T
;+
; NAME:
;	N_SPLINE
;
; PURPOSE:
;	Cubic Natural-Spline Interpolation.
;
; CALLING SEQUENCE:
;	Result = N_SPLINE(X,Y,T)
;
; INPUTS:
;	X = abcissae vector. MUST be monotonically increasing.
;
;	Y = Array of ordiante values.
;
;	T = vector of abcissae values for which ordinate is desired.
;		Elements of T MUST be monotonically increasing.
;
; OUTPUTS:
;	Result = vector of interpolated ordinates.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	Abcissae values must be monotonically increasing.
;
; PROCEDURE:
;	See:	NUMERICAL RECIPES (Fortran Version)
;			William H. Press et al.
;			Cambridge University Press, 1989
;			Chapter 3, pag. 88.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, October 1991.
;
;-
ON_ERROR,2
	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of parameters'

	n = N_ELEMENTS(x)
	IF N_ELEMENTS(y) NE n THEN MESSAGE,$
		'X and Y must have same number of elements'

	y2 = FLTARR(n,/nozero)		;Second derivative array.
	y2(0) = 0.
	y2(n-1)	= 0.
	u = FLTARR(n,/nozero)		;Dummy array.
	u(0) = 0.
	u(n-1) = 0.

	sig = (x-SHIFT(x,1))/(SHIFT(x,-1)-SHIFT(x,1))
	inx = (SHIFT(y,-1) - y)/(SHIFT(x,-1) - x)
	inx = inx - SHIFT(inx,1)
	inx = 6.*inx/(SHIFT(x,-1)-SHIFT(x,1))
	FOR i = 1,n-2 DO BEGIN		;Decomposition loop for the
		p = sig(i)*y2(i-1)+2.		;tridiagonal algorithm.
		y2(i) = (sig(i)-1.)/p
		u(i) = (inx(i)-sig(i-1)*u(i-1))/p
	ENDFOR
	sig = 0				;Now, the backsubstitution for
	inx = 0				;for the tridiagonal algorithm.
	FOR k = n-2,0,-1 DO y2(k) = y2(k)*y2(k+1)+u(k)
	u = 0

	m = N_ELEMENTS(t)
	inx = REPLICATE(LONG(n-1),m)
	j = 0
	FOR i = 1,n-1 DO BEGIN
		WHILE (t(j) LE x(i)) DO BEGIN	;Find subscript where
			inx(j) = i		;x(inx) > t(j) > x(inx-1)
			j = j+1
			IF j EQ m THEN GOTO,DONE
		ENDWHILE
	ENDFOR
	DONE:

	inx1 = inx-1				;Next it computes the interpo-
	d = x(inx)-x(inx1)		;lated values for every t.
	a = (x(inx)-t)/d
	b = 1.-a
	d = d*d/6.
	c = (a*a*a-a)*d
	d = (b*b*b-b)*d

	RETURN,a*y(inx1) + b*y(inx) + c*y2(inx1) + d*y2(inx)

END
FUNCTION FIT_POLY,X,Y,N
;+
; NAME:
;	FIT_POLY
;
; PURPOSE:
;	Multidimensional linear least square fitting procedure.
;
; CALLING SEQUENCE:
;	Result = FIT_POLY(X,Y,N)
;
; INPUTS:
;	X = abscisae points corresponding to Y values
;
;	Y = array of 1, 2 or 3 dimensions. If Y has 3 dimensions, 
;		the third dimension in every point is fitted to a
;		polynomial. If dimensions are 2, each column is 
;		fitted.
;
;	N = degree of polynomial.
;
; OUTPUTS:
;	COEFF = array of coefficients. Number of dimensions is that of Y.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	No error estimates are calculated.
;
; PROCEDURE:
;	Linear equations are solved at the same time for all points.
;
; EXAMPLES:
;	Let Y be a 3D array, e.g. a set of m images; to fit its third
;	dimension to a polynomial of 2nd degree (i.e. a parabolae to
;	every spatial point in the images) we make:
;
;	IDL> x = FINDGEN(m)
;	IDL> coeff = FIT_POLY(x,y,2)
;
;	and compute the minimum (line centre) position by doing:
;
;	IDL> centre = coeff(*,*,1) / coeff(*,*,2) / 2.
;
; MODIFICATION HISTORY:
;	Written by Roberto Molowny Horas, December 1992.
;
;-
ON_ERROR,2

	IF N_PARAMS(0) LT 2 THEN MESSAGE,'Wrong number of inputs'
	s = SIZE(y)
	npoints = s(s(0))
	IF N_ELEMENTS(x) NE npoints THEN MESSAGE,$
		'Abscisaes do not match ordinates'

	a = DBLARR(n+1,n+1)
	xx = DOUBLE(x)
	FOR i = 0,n DO FOR j = 0,n DO a(i,j) = TOTAL(xx^(i+j))

	a = INVERT(a)		;Inverts matrix of coefficients.

	CASE 1 OF
		s(0) EQ 1: coeff = DBLARR(n+1)
		s(0) EQ 2: coeff = DBLARR(s(1),n+1)
		ELSE: coeff = DBLARR(s(1),s(2),n+1)
	ENDCASE

	FOR i = 0,npoints-1 DO FOR j = 0,n DO BEGIN
		dumb = 0.
		FOR k = 0,n DO dumb = dumb + a(j,k) * xx(i)^k
		CASE 1 OF
			s(0) EQ 1: coeff(j) = coeff(j) + y(i) * dumb
			s(0) EQ 2: coeff(0,j) = coeff(*,j) + $
				y(*,i) * dumb
			ELSE: coeff(0,0,j) = coeff(*,*,j) + $
				y(*,*,i) * dumb
		ENDCASE
	ENDFOR

	RETURN,coeff
END
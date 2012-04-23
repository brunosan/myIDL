FUNCTION DERIVATIVES,A,SECOND_DER,SECOND=second
;+
; NAME:
;	DERIVATIVES
;
; PURPOSE:
;	Compute first and second derivatives of 2-D array A in X direction,
;	using a natural splines algorithm.
;
; CALLING SEQUENCE:
;	Result = DERIVATIVES(A, [ DER , SECOND = ] )
;
; INPUTS:
;	A = Two dimensional array to be remapped.
;
; OUTPUTS:
;	Result = first or second derivative.
;
; OPTIONAL OUTPUT:
;	SECOND_DER = if keyword SECOND is set, Result is the second
;		derivative.
;
; KEYWORD_SET:
;	SECOND = if set, second derivative is stored in Result and
;		first derivative is not computed. If not set, Result
;		is the first derivative, and the optional output
;		SECOND_DER is the second derivative.
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
;	Natural cubic splines are computed in X-direction.
;
; REFERENCES:
;	Numerical Recipes (Fortran version), W. Press et al, 1989
;
; EXAMPLES:
;	Let A be a 2-D array.
;
;	IDL> RESULT = DERIVATIVES(A,DER)
;
;	gives first derivative in RESULT, and second deriv. in DER
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, December 1992.
;
;-
ON_ERROR,2

	s = SIZE(a)
	u = FLTARR(s(1),s(2),/NOZERO)		;Dumb array.

	second_der = FLTARR(s(1),s(2))		;Second deriv. in X direction.
	FOR i = 1,s(1)-2 DO BEGIN		;Tridiagonal algorithm.
		sigma = .5*second_der(i-1,*) + 2.
		second_der(i,0) = -.5/sigma
		u(i,0) = a(i+1,*) - 2.*a(i,*) + a(i-1,*)
		u(i,0) = (3.*u(i,*) - .5*u(i-1,*))/sigma
	ENDFOR
	FOR k = s(1)-2,0,-1 DO second_der(k,0) = second_der(k,*) * $
		second_der(k+1,*) + u(k,*)

	IF KEYWORD_SET(second) THEN RETURN,second_der	;Only second deriv.

	first_der = (SHIFT(a,-1,0)-FLOAT(a)) - $	;Computes first deriv.
		second_der/3. - SHIFT(second_der,-1,0)/6.
	first_der(s(1)-1,0) = FLOAT(a(s(1)-1,*)) - $	;Takes care of border.
		a(s(1)-2,*) - second_der(s(1)-2,*)/6.

	RETURN,first_der

END
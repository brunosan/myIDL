;+
; NAME:
;       RECPOL
; PURPOSE:
;       Convert 2-d rectangular coordinates to polar coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       recpol, x, y, r, a
; INPUTS:
;       x, y = vector in rectangular form.              in 
; KEYWORD PARAMETERS:
;	/DEGREES means angle is in degrees, else radians.
; OUTPUTS:
;       r, a = vector in polar form: radius, angle.     out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Aug, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 13 Feb, 1991 --- added /degrees.
;-
 
	PRO RECPOL, X0, Y0, R, A, help=hlp, degrees=degrees
 
	IF (N_PARAMS(0) LT 4) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert 2-d rectangular coordinates to polar coordinates.
	  PRINT,' recpol, x, y, r, a
	  PRINT,'   x, y = vector in rectangular form.           in'
	  PRINT,'   r, a = vector in polar form: radius, angle.  out'
	  print,' Keywords:'
	  print,'   /DEGREES means angle is in degrees, else radians.'
	  RETURN
	ENDIF
 
	X = X0				; copy args to avoid changing originals
	Y = Y0
 
	FLAG = ISARRAY(X)		; check if args are arrays.
	IF FLAG EQ 0 THEN BEGIN		; force to be arrays.
	  X = ARRAY(X)
	  Y = ARRAY(Y)
	ENDIF
 
	W = array(WHERE( (X EQ 0.0) AND (Y EQ 0.0)))	; avoid the case (0,0).
	IF W(0) NE -1 THEN BEGIN			; change such cases.
	  X(W) = 1
	  Y(W) = 1
	ENDIF
 
	A = ATAN(y, x)			; Find angles.
	WN = array(WHERE(A LT 0))	; find A < 0 and fix.
	IF WN(0) GT -1 THEN BEGIN
	  PI2 = 360./!RADEG		; 2 pi.
	  A(WN) = A(WN) + PI2		; add 2 pi to angles < 0.
	ENDIF
 
	R = SQRT(X^2 + Y^2)		; Find radii.
 
	IF W(0) NE -1 THEN BEGIN	; restore 0 values.
	  A(W) = 0.0
	  R(W) = 0.0
	ENDIF
 
	IF FLAG EQ 0 THEN BEGIN		; if scalars args, return scalars.
	  A = A(0)
	  R = R(0)
	ENDIF
 
	if keyword_set(degrees) then a = a*!radeg

	RETURN
	END

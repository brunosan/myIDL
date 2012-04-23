;+
; NAME:
;       POLREC
; PURPOSE:
;       Convert 2-d polar coordinates to rectangular coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       polrec, r, a, x, y
; INPUTS:
;       r, a = vector in polar form: radius, angle (radians).  in 
; KEYWORD PARAMETERS:
;       /DEGREES means angle is in degrees, else radians.
; OUTPUTS:
;       x, y = vector in rectangular form.                     out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Aug, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 13 Feb, 1991 --- added /degrees.
;-
 
	PRO POLREC, R, A, X, Y, help=hlp, degrees=degrees
 
	IF (N_PARAMS(0) LT 4) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert 2-d polar coordinates to rectangular coordinates.
	  PRINT,' polrec, r, a, x, y
	  PRINT,'   r, a = vector in polar form: radius, angle (radians).  in'
	  PRINT,'   x, y = vector in rectangular form.                     out'
          print,' Keywords:'
          print,'   /DEGREES means angle is in degrees, else radians.'
	  RETURN
	ENDIF
 
	cf = 1.
	if keyword_set(degrees) then cf = !radeg

	X = R*COS(A/cf)
	Y = R*SIN(A/cf)	
	RETURN
	END

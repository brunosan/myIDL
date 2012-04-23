;+
; NAME:
;       RECPOL3D
; PURPOSE:
;       Convert vector(s) from rectangular to spherical polar form.
; CATEGORY:
; CALLING SEQUENCE:
;       recpol3d, x, y, z, r, az, ax
; INPUTS:
;       x = X component.                     in
;       y = Y component.                     in
;       z = Z component.                     in
; KEYWORD PARAMETERS:
;       /DEGREES means angles are in degrees, else radians.
; OUTPUTS:
;       r = Radius.                          out
;       az = angle from Z axis in radians.   out
;       ax = angle from X axis in radians.   out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Aug, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 31 Aug, 1989 --- converted to SUN.
;       RES 13 Feb, 1991 --- added /degrees.
;-
 
	PRO RECPOL3D, X, Y, Z, R, AZ, AX, help=hlp, degrees=degrees
 
	IF (N_PARAMS(0) LT 6) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert vector(s) from rectangular to spherical polar form.
	  PRINT,' recpol3d, x, y, z, r, az, ax
	  PRINT,'   x = X component.                     in
	  PRINT,'   y = Y component.                     in
	  PRINT,'   z = Z component.                     in
	  PRINT,'   r = Radius.                          out
	  PRINT,'   az = angle from Z axis in radians.   out
	  PRINT,'   ax = angle from X axis in radians.   out
          print,' Keywords:'
          print,'   /DEGREES means angles are in degrees, else radians.'
	  RETURN
	ENDIF
 
	RECPOL, X, Y, RXY, AX, degrees=degrees
	RECPOL, Z, RXY, R, AZ, degrees=degrees
	RETURN
	END

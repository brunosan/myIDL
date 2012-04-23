;+
; NAME:
;       POLREC3D
; PURPOSE:
;       Convert vector(s) from spherical polar to rectangular form.
; CATEGORY:
; CALLING SEQUENCE:
;       polrec3d, r, az, ax, x, y, z
; INPUTS:
;       r = Radius.                         in
;       az = angle from Z axis in radians.  in
;       ax = angle from X axis in radians.  in
; KEYWORD PARAMETERS:
;       /DEGREES means angles are in degrees, else radians.
; OUTPUTS:
;       x = x component.                    out
;       y = y component.                    out
;       z = z component.                    out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Aug, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 31 Aug, 1989 --- converted to SUN.
;	RES 13 Feb, 1991 --- added /degrees.
;-
 
	PRO POLREC3D, R, AZ, AX, X, Y, Z, help=hlp, degrees=degrees
 
	IF (N_PARAMS(0) LT 6) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert vector(s) from spherical polar to rectangular form.
	  PRINT,' polrec3d, r, az, ax, x, y, z
	  PRINT,'   r = Radius.                         in
	  PRINT,'   az = angle from Z axis in radians.  in
	  PRINT,'   ax = angle from X axis in radians.  in
	  PRINT,'   x = x component.                    out
	  PRINT,'   y = y component.                    out
	  PRINT,'   z = z component.                    out
          print,' Keywords:'
          print,'   /DEGREES means angles are in degrees, else radians.'
	  RETURN
	ENDIF
 
	POLREC, R, AZ, Z, RXY, degrees=degrees
	POLREC, RXY, AX, X, Y, degrees=degrees
	RETURN
	END

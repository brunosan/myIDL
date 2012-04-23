;+
; NAME:
;       ROT_3D
; PURPOSE:
;       Rotate 3-d coordinate systems.
; CATEGORY:
; CALLING SEQUENCE:
;       rot_3d, axis, x1, y1, z1, ang, x2, y2, z2
; INPUTS:
;       axis = Axis number to rotate about: 1 = X, 2 = Y, 3 = Z.  in 
;       x1, y1, z1 = arrays of original x,y,z vector components.  in 
;       ang = rotation angle in radians.                          in 
; KEYWORD PARAMETERS:
;       /DEGREES means angle is in degrees, else radians.
; OUTPUTS:
;       x2, y2, z2 = arrays of new x,y,z vector components.       out 
; COMMON BLOCKS:
; NOTES:
;       Note: Right-hand rule is used: Point thumb along +axis. 
;         Fingers curl in vector rotation direction (for +ang). 
;	  This is for coordinate system rotation.  To rotate the
;	  vectors in a fixed coordinate system use the left hand rule.
; MODIFICATION HISTORY:
;       R. Sterner.  28 Jan, 1987.
;       6 May, 1988 --- modified to work with any shape arrays.
;	R. Sterner, 6 Nov, 1989 --- converted to SUN.
;       RES 13 Feb, 1991 --- added /degrees.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO ROT_3D, AXIS, X1, Y1, Z1, ANG, X2, Y2, Z2, help=hlp, $
	  degrees=degrees
 
	IF (N_PARAMS(0) NE 8) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Rotate 3-d coordinate system.'
	  PRINT,' rot_3d, axis, x1, y1, z1, ang, x2, y2, z2'
	  PRINT,'   axis=Axis number to rotate about: 1=X, 2=Y, 3=Z.     in'
	  PRINT,'   x1, y1, z1 = arrays of original x,y,z vector comp.   in'
	  PRINT,'   ang = rotation angle in radians.                     in'
	  PRINT,'   x2, y2, z2 = arrays of new x,y,z vector components.  out'
	  print,' Keywords:'
          print,'   /DEGREES means angle is in degrees, else radians.'
	  PRINT,' Note: Right-hand rule is used: Point thumb along +axis.'
	  PRINT,'   Fingers curl in vector rotation direction (for +ang).'
	  print,'   This is for coordinate system rotation.  To rotate the'
	  print,'   vectors in a fixed coord. system use the left hand rule.'
	  RETURN
	ENDIF
 
        if keyword_set(degrees) then begin
          C = COS(ANG/!radeg)
          S = SIN(ANG/!radeg)
        endif else begin
          C = COS(ANG)
          S = SIN(ANG)
        endelse

	CASE AXIS OF			; depending on axis.
1:	BEGIN
	  X2 =  X1
	  Y2 =  C*Y1 + S*Z1
	  Z2 = -S*Y1 + C*Z1
	END
2:	BEGIN
	  X2 = C*X1 - S*Z1
	  Y2 = Y1
	  Z2 = S*X1 + C*Z1
	END
3:	BEGIN
	  X2 =  C*X1 + S*Y1
	  Y2 = -S*X1 + C*Y1
	  Z2 = Z1
	END
ELSE:	  BEGIN
	    PRINT,'Invalid axis number: must be 1 for X, 2 for Y, 3 for Z.'
	    RETURN
	  END
	ENDCASE
 
	RETURN
	END

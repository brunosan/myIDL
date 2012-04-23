;+
; Name: IMGRECPOL.PRO
; Purpose: Re-map an image from rectangular form to polar.
; Category: Array routines.
; Calling sequence: AR = IMGRECPOL(XY,x1,x2,y1,y2,a1,a2,da,r1,r2,dr)
; Inputs:
;   XY = rectangular image.
;   x1, x2 = min and max x coordinates in output rectangular image.
;   y1, y2 = min and max y coordinates in output rectangular image.
;   a1, a2 = min and max angle in ra in degrees.
;   da = step size in angle.
;   r1, r2 = min and max radius in ra.
;   dr = step size in radius.
; Outputs:
;   AR = polar image array with angle in x direction, radius in y.
; Common blocks:
; Side effects:
; Restrictions:
; Routines used: MAKEX, INDEX2D.
; Procedure:
; Modification history: R. Sterner.  11 July, 1986.
;	Johns Hopkins Applied Physics Lab.
;-

	FUNCTION IMGRECPOL, XY, X1, X2, Y1, Y2, A1, A2, DA, $
	  R1, R2, DR, help=hlp

	IF (N_PARAMS(0) LT 11) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Map an X/Y image to an angle/radius image.
	  PRINT,' ar = imgrecpol(xy, x1, x2, y1, y2, a1, a2, da, r1, r2, dr)
	  PRINT,'   xy = X/Y image.					in
	  PRINT,'   x1, x2 = start and end x in xy.			in
	  PRINT,'   y1, y2 = start and end y in xy.			in
	  PRINT,'   a1, a2, da = start ang, end ang, ang step (deg).	in
	  PRINT,'   r1, r2, dr = start radius, end radius, radius step.	in
	  PRINT,'   ar = returned angle/radius image.			out
	  PRINT,'     Angle is in x direction, and radius is in y direction.
	  RETURN, -1
	ENDIF

	S = SIZE(XY)		; error check.
	IF S(0) NE 2 THEN BEGIN
	  PRINT,' Error in imgrecpol: First arg must be a 2-d array.'
	  RETURN, -1
	ENDIF
	NX = S(1)		; size of XY in x.
	NY = S(2)		; size of XY in y.

	A = MAKEX(A1, A2, DA)/!RADEG	; generate angle array.
	NA = N_ELEMENTS(A)
	R = MAKEX(R1, R2, DR)		; generate radius array.
	NR = N_ELEMENTS(R)
	A = CONGRID(FLTARR(NA,2) + [[A],[a]], NA, NR)
	R = CONGRID(FLTARR(1,NR) + R, NA, NR)

	IAR = LINDGEN(NA*NR-1)	; 1-d indices into image AR.

	X = R*COS(A)		; from AR coordinates find X.
	Y = R*SIN(A)		; from AR coordinates find Y.
	IX = FIX(0.5+(X-X1)*(NX-1)/(X2-X1))	; from X find X indices.
	IY = FIX(0.5+(Y-Y1)*(NY-1)/(Y2-Y1))	; from Y find Y indices.

	W = WHERE((IX GE 0) AND (IX LT NX) AND (IY GE 0) AND (IY LT NY))
	IX = IX(W)		; select out valid values.
	IY = IY(W)
	IAR = IAR(W)
	two2one, IX, IY, XY, ixy    ; convert 2-d indices to 1-d indices.

	AR = FLTARR(NA,NR)	    ; Make an array of 0s.
	AR(IAR) = XY(IXY)	    ; Move values to it.

	RETURN, AR

	END

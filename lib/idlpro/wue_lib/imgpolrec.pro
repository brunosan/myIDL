;+
; Name: IMGPOLREC.PRO
; Purpose: Re-map an image from polar form to rectangular.
; Category: Array routines.
; Calling sequence: XY = IMGPOLREC(AR,a1,a2,r1,r2,x1,x2,dx,y1,y2,dy)
; Inputs:
;   AR = polar image array with angle in x direction, radius in y.
;   a1, a2 = min and max angle in AR in degrees.
;   r1, r2 = min and max radius in AR.
;   x1, x2 = min and max x coordinates in output rectangular image.
;   dx = step size in x.
;   y1, y2 = min and max y coordinates in output rectangular image.
;   dy = step size in y.
; Outputs: XY = resulting rectangular image.
; Common blocks:
; Side effects:
; Restrictions:
; Routines used: MAKEX, INDEX2D.
; Procedure:
; Modification history: R. Sterner.  12 May, 1986.
;	Johns Hopkins Applied Physics Lab.
;-

	FUNCTION IMGPOLREC, AR, A1, A2, R1, R2, X1, X2, DX, Y1, Y2, DY

	IF N_PARAMS(0) LT 11 THEN BEGIN
	  PRINT,'Map an angle/radius image to an X/Y image.
	  PRINT,'xy = IMGPOLREC(ar, a1, a2, r1, r2, x1, x2, dx, y1, y2, dy)
	  PRINT,'  ar = angle/radius image.				in
	  PRINT,'     Angle is in x direction, and radius is in y direction
	  PRINT,'  a1, a2 = start and end angles in ar (degrees)	in
	  PRINT,'  r1, r2 = start and end radius in ar.			in
	  PRINT,'  x1, x2, dx = desired start x, end x, x step.		in
	  PRINT,'  y1, y2, dy = desired start y, end y, y step.		in
	  PRINT,'  xy = returned X/Y image.				out
	  RETURN, 0
	ENDIF

	S = SIZE(AR)		; error check.
	IF S(0) NE 2 THEN BEGIN
	  PRINT,'Error in REMAP: First arg must be a 2-d array.'
	  RETURN, -1
	ENDIF
	NA = S(1)		; size of AR in a.
	NR = S(2)		; size of AR in r.

	X = MAKEX(X1, X2, DX)	; generate X array.
	NX = N_ELEMENTS(X)
	Y = MAKEX(Y1, Y2, DY)	; generate Y array.
	NY = N_ELEMENTS(Y)
	X = CONGRID(FLTARR(NX,2) + [[X],[x]], NX, NY)
	Y = CONGRID(FLTARR(1,NY) + Y, NX, NY)

	IXY = INDGEN(NX*NY-1)	; 1-d indices into image XY.

	R = SQRT(X^2 + Y^2)	; from XY coordinates find R.
	W = WHERE(R EQ 0.0)	; don't allow atan(0,0)
	if w eq -1 then goto, skp
	X(W) = 1.0E-25
	Y(W) = 1.0E-25
skp:
	A = !RADEG*ATAN(Y, X)		; from XY coordinates find A.
	IF A1 GT 0 THEN BEGIN
	  W=WHERE(A LT 0.)		; principal value 0 to 360
	  A(W)=A(W)+360.
	ENDIF
	IA = FIX(0.5+(A-A1)*(NA-1)/(A2-A1))	; from A find A indices.
	IR = FIX(0.5+(R-R1)*(NR-1)/(R2-R1))	; from R find R indices.

	W = WHERE((IR GE 0) AND (IR LT NR) AND (IA GE 0) AND (IA LT NA))
	IA = IA(W)
	IR = IR(W)		; select out valid values.
	IXY = IXY(W)

	two2one, Ia, Ir, ar, iar    ; convert 2-d indices to 1-d indices.

	XY = FLTARR(NX,NY)	    ; Make an array of 0s.
	XY(IXY) = AR(IAR)	    ; Move values to it.

	RETURN, XY

	END

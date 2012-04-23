;+
; NAME:
;       TVPOS
; PURPOSE:
;       Gives screen position used by TV, TVSCL.
; CATEGORY:
; CALLING SEQUENCE:
;       tvpos, img, n, x0, y0
; INPUTS:
;       img = Image of desired size (for size only).    in.
;       n = Position number.                            in.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x0, y0 = screen coordinates of lower left       out.
;          corner of TV position. 
; COMMON BLOCKS:
; NOTES:
;       Note: On error x0 and y0 are -1.
; MODIFICATION HISTORY:
;       R. Sterner.  15 July, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       R. Sterner, 11 Dec, 1989 --- converted to SUN.
;-
 
	PRO TVPOS, IMG, POS, X0, Y0, help=hlp
 
	IF (N_PARAMS(0) LT 4) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Gives screen position used by TV, TVSCL.'
	  PRINT,' tvpos, img, n, x0, y0
	  PRINT,'   img = Image of desired size (for size only).    in.
	  PRINT,'   n = Position number.                            in.
	  PRINT,'   x0, y0 = screen coordinates of lower left       out.
	  PRINT,'      corner of TV position.'
	  PRINT,' Note: On error x0 and y0 are -1.
	  RETURN
	ENDIF
 
	S = SIZE(IMG)
	IF S(0) NE 2 THEN BEGIN
	  PRINT,' Error in TVPOS: first arg must be a 2-d array.'
	  X0 = -1
	  Y0 = -1
	  RETURN
	ENDIF
	SX = S(1)		; size of array in X.
	SY = S(2)		; size of array in Y.
;	TVRES, XRES, YRES	; display resolution.
	xres = !d.x_size
	yres = !d.y_size
	XORIG = 0		; POS number 0 coordinates.
	YORIG = YRES - 1 - SY
 
	NX = FIX(XRES/SX)	; Number of positions in X.
	NY = FIX(YRES/SY)	; number of positions in Y.
	IF (POS LT 0) OR (POS GE NX*NY) THEN BEGIN
	  PRINT,' Error in TVPOS: Position number out of range.'
	  PRINT,' Must be in range: 0 <= POS < '+STRTRIM(NX*NY,2)
	  X0 = -1
	  Y0 = -1
	  RETURN
	ENDIF
 
	IY = FIX(POS/NX)	; 2-d position indices.
	IX = POS - IY*NX
 
	X0 = XORIG + IX*SX	; corner coordinates.
	Y0 = YORIG - IY*SY
 
	RETURN
	END

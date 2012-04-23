;+
; NAME:
;       MAKEXY
; PURPOSE:
;       Make 2-d X and Y coordinate arrays, useful for functions of x,y.
; CATEGORY:
; CALLING SEQUENCE:
;       MAKEXY, x1, x2, dx, y1, y2, dy, xarray, yarray
; INPUTS:
;       x1 = min x coordinate in output rectangular array.  in 
;       x2 = max x coordinate in output rectangular array.  in 
;       dx = step size in x.                                in 
;       y1 = min y coordinate in output rectangular array.  in 
;       y2 = max y coordinate in output rectangular array.  in 
;       dy = step size in y.                                in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       xarray, yarray = resulting rectangular arrays.      out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  15 May, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 30 Aug 89 --- converted to SUN.
;-
 
	PRO MAKEXY, X1, X2, DX, Y1, Y2, DY, XA, YA, help=hlp
 
	IF (N_PARAMS(0) lt 8) or keyword_set(hlp) THEN BEGIN
	  print,' Make 2-d X & Y coord. arrays, useful for functions of x,y.'
	  PRINT,' MAKEXY, x1, x2, dx, y1, y2, dy, xarray, yarray
	  PRINT,'   x1 = min x coordinate in output rectangular array.  in'
	  PRINT,'   x2 = max x coordinate in output rectangular array.  in'
	  PRINT,'   dx = step size in x.                                in'
	  PRINT,'   y1 = min y coordinate in output rectangular array.  in'
	  PRINT,'   y2 = max y coordinate in output rectangular array.  in'
	  PRINT,'   dy = step size in y.                                in'
	  PRINT,'   xarray, yarray = resulting rectangular arrays.      out'
	  RETURN
	ENDIF
 
	X = MAKEX(X1, X2, DX)			; generate X array.
	NX = N_ELEMENTS(X)
	Y = transpose(MAKEX(Y1, Y2, DY))	; generate Y array.
	NY = N_ELEMENTS(Y)
	XA = CONGRID(FLTARR(NX,2) + [x,X], NX, NY)
	YA = CONGRID(FLTARR(2,NY) + [y,Y], NX, NY)
 
	RETURN
 
	END

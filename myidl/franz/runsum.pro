FUNCTION RUNSUM,X
;+
; NAME:
;	RUNSUM
;
; PURPOSE:
;	Return the running sum of X.
;
; CALLING SEQUENCE:
;	Result = RUNSUM(X)
;
; INPUT:
;	X = array of any size and type.
;
; OUTPUT:
;	Result = the running sum of X. Same size as X, but float. point.
;
; COMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Straightforward.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, July 1992.
;
;-
ON_ERROR,2

	n = N_ELEMENTS(x)
	y = FLTARR(n,/NOZERO)
	y(0) = x(0)				;Initializes first point.
	FOR i = 1,n-1 DO y(i) = y(i-1) + x(i)	;Simplest way.
	RETURN,y
END
FUNCTION RFIX,X,LONG=long
;+
; NAME:
;	RFIX
;
; PURPOSE:
;	Round X to its nearest integer.
;
; CALLING SEQUENCE:
;	Result = RFIX(X)
;
; INPUT:
;	X = number, vector or array to be rounded.
;
; KEYWORDS:
;	LONG = if set, it will round to a longword integer.
;
; OUTPUT:
;	Result = nearest integer rounded version of X.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Straightforward. Algorithm is faster than ASTROLIB NINT function.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, November 1991.
;
;-
ON_ERROR,2

	IF KEYWORD_SET(long) THEN RETURN,LONG(x*2.) - LONG(x) ELSE $
		RETURN,FIX(x*2.) - FIX(x)	;Fastest algorithm.
	END
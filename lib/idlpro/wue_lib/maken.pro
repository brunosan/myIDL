;+
; NAME:
;       MAKEN
; PURPOSE:
;       Make an array of N values, linear between two given limits.
; CATEGORY:
; CALLING SEQUENCE:
;       x = makex( first, last, num)
; INPUTS:
;       first, last = array start and end values.          in 
;       num = number of values from first to last.         in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x = array of values.                               out  
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,  26 Sep, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION MAKEN,XLO,XHI,N, help = h
 
	if (n_params(0) lt 3) or keyword_set(h) then begin
	  print,' Make an array of N values, linear between two given limits.'
	  print,'  x = makex( first, last, num)
	  print,'    first, last = array start and end values.          in'
	  print,'    num = number of values from first to last.         in'
	  print,'    x = array of values.                               out' 
	  return, -1
	endif
 
	IF N LE 1 THEN RETURN, FLTARR(1) + XLO	; spec. case.
	XST = (XHI-XLO)/FLOAT(N-1)	; step size.
	RETURN,XLO+XST*FINDGEN(N)
	END

;+
; NAME:
;       VARF
; PURPOSE:
;       Computes variance inside a moving window.
; CATEGORY:
; CALLING SEQUENCE:
;       v = varf(x,w)
; INPUTS:
;       x = array of input values.      in 
;       w = width of window.            in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       v = resulting variance array.   out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 3 Jan, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION VARF,X,W, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Computes variance inside a moving window.'
	  print,' v = varf(x,w)'
	  print,'   x = array of input values.      in'
	  print,'   w = width of window.            in'
	  print,'   v = resulting variance array.   out'
	  return, -1
	endif
 
	RETURN, SMOOTH(X^2,W) - SMOOTH(X,W)^2
	END

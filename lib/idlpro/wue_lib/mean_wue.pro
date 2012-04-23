;-------------------------------------------------------------
;+
; NAME:
;       MEAN
; PURPOSE:
;       Returns the mean of an array.
; CATEGORY:
; CALLING SEQUENCE:
;       m = mean(a)
; INPUTS:
;       a = input array.     in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       m = array mean.      out  
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,  11 Dec, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;-
;-------------------------------------------------------------
 
	FUNCTION MEAN,X, help = h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Returns the mean of an array.' 
	  print,' m = mean(a)' 
	  print,'   a = input array.     in'
	  print,'   m = array mean.      out' 
	  return, -1
	endif
 
	RETURN, TOTAL(X)/N_ELEMENTS(X)
	END

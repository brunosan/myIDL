;+
; NAME:
;       CEIL
; PURPOSE:
;       Return the ceiling of the argument.
; CATEGORY:
; CALLING SEQUENCE:
;       b = ceil(a)
; INPUTS:
;       a = input value.     in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = ceiling of a.    out 
; COMMON BLOCKS:
; NOTES:
;       Note: ceiling is the integer greater than or 
;         equal to argument. 
; MODIFICATION HISTORY:
;       R. Sterner.  13 May, 1986.
;-
 
	FUNCTION CEIL, A, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return the ceiling of the argument.'
	  print,' b = ceil(a)'
	  print,'   a = input value.     in'
	  print,'   b = ceiling of a.    out'
	  print,' Note: ceiling is the integer greater than or'
	  print,'   equal to argument.'
	  return, -1
	endif
 
	FLAG = ISARRAY(A)
	A2 = ARRAY(A)
 
	B = LONG( A2)
	W = WHERE( B LT A2, count)
	if count gt 0 then B(W) = B(W) + 1
 
	IF FLAG EQ 0 THEN B = B(0)
 
	RETURN, B
 
	END

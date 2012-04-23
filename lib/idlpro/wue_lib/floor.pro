;+
; NAME:
;       FLOOR
; PURPOSE:
;       Return the floor of the argument.
; CATEGORY:
; CALLING SEQUENCE:
;       b = floor(a)
; INPUTS:
;       a = input value.     in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = floor of a.      out 
; COMMON BLOCKS:
; NOTES:
;       Note: floor is the integer less than or 
;         equal to argument. 
; MODIFICATION HISTORY:
;       R. Sterner.  13 May, 1986.
;-
 
	FUNCTION floor, A, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return the floor of the argument.'
	  print,' b = floor(a)'
	  print,'   a = input value.     in'
	  print,'   b = floor of a.      out'
	  print,' Note: floor is the integer less than or'
	  print,'   equal to argument.'
	  return, -1
	endif
 
	FLAG = ISARRAY(A)
	A2 = ARRAY(A)
 
	B = LONG( A2)
	W = WHERE( B GT A2, count)
	if count gt 0 then B(W) = B(W) - 1
 
	IF FLAG EQ 0 THEN B = B(0)
 
	RETURN, B
 
	END

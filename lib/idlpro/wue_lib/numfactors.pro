;+
; NAME:
;       NUMFACTORS
; PURPOSE:
;       Gives the number of factors of a number.
; CATEGORY:
; CALLING SEQUENCE:
;       nf = numfactors(x)
; INPUTS:
;       x = number to factor.         in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       nf = number of factors of x.  out 
;         Does not include 1 and x. 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 25 Oct, 1990
;	R. Sterner, 26 Feb, 1991 --- Renamed from num_factors.pro
;-
 
	function numfactors, x, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Gives the number of factors of a number.'
	  print,' nf = numfactors(x)'
	  print,'   x = number to factor.         in'
	  print,'   nf = number of factors of x.  out'
	  print,'     Does not include 1 and x.'
	  return, -1
	endif
 
	factor, x, p, n
 
	t = 1L
 
	;  Note: Prime factor n(i) can occur from 0 to n(i) times (= n(i)+1 )
	;    in any given factor of x.  Ex: let n = [3,1,1] then
	;    number of factors = 4*2*2.  To exclude 1 and x subtract 2.
	;    Bob Jensen was a consultant on this.
 
	for i = 0, n_elements(n)-1 do t = t*(n(i)+1)
 
	return, t-2
 
	end

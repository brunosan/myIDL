;+
; NAME:
;       EXRANGE
; PURPOSE:
;	Return a range array with range expanded by given fraction.
; CATEGORY:
; CALLING SEQUENCE:
;       b = exrange(a, f)
; INPUTS:
;       a = array.                in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = [mn-, mx+]            out 
;       where mn- = min(a) - f*d 
;             mx+ = max(a) + f*d  
;             d = max(a) - min(a) 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 7 Sep, 1989.
;-
 
	function exrange, x, f, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return a range array with range expanded by given fraction.'
	  print,' b = exrange(a, f)'
	  print,'  a = array.                in'
	  print,'  b = [mn-, mx+]            out'
	  print,'  where mn- = min(a) - f*d'
	  print,'        mx+ = max(a) + f*d' 
	  print,'        d = max(a) - min(a)'
	  return, -1
	end
 
	d = max(x) - min(x)
	return, [min(x)-f*d, max(x)+f*d]
 
	end

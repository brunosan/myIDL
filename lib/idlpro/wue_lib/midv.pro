;+
; NAME:
;       MIDV
; PURPOSE:
;       Return value midway between array extremes.
; CATEGORY:
; CALLING SEQUENCE:
;       vmd = midv(a)
; INPUTS:
;       a = array.                      in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       vmd = (min(a)+max(a))/2.        out 
;       
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;-
 
	function midv, x, help = h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Return value midway between array extremes.'
	  print,' vmd = midv(a)' 
	  print,'  a = array.                      in'
	  print,'  vmd = (min(a)+max(a))/2.        out'
	  print,' '
	  return, -1
	end
 
	return, .5*(min(x) + max(x))
	end

;+
; NAME:
;       FITSTXTI
; PURPOSE:
;       Make a FITS header integer numeric string.
; CATEGORY:
; CALLING SEQUENCE:
;       txt = fitstxti(key,val, [comm])
; INPUTS:
;       key = FITS keyword.               in 
;       val = Keyword value.              in 
;       comm = optional comment.          in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       txt = result header text string.  out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 9 Mar, 1990
;-
 
	function fitstxti, key, val, comm, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make a FITS header integer numeric string.'
	  print,' txt = fitstxti(key,val, [comm])'
	  print,'   key = FITS keyword.               in'
	  print,'   val = Keyword value.              in'
	  print,'   comm = optional comment.          in'
	  print,'   txt = result header text string.  out'
	  return, -1
	endif
 
	t = string(bytarr(80)+32b)
	k = strupcase(key)
	strput, t, strmid(k,0,8), 0
	strput, t, '=', 8
	x = strtrim(long(val),2)
	strput, t, x, 30-strlen(x)
	strput, t, '/', 31
	if n_params(0) gt 2 then strput, t, comm, 33
 
	return, t
	end

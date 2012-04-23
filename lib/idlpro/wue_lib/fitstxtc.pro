;+
; NAME:
;       FITSTXTC
; PURPOSE:
;       Make a FITS header character string.
; CATEGORY:
; CALLING SEQUENCE:
;       txt = fitstxtc(key,val,[comm])
; INPUTS:
;       key = FITS keyword.               in 
;       val = Keyword value string.       in 
;       comm = optional comment.          in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       txt = result header character string.  out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 9 Mar, 1990
;-
 
	function fitstxtc, key, val, comm, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make a FITS header character string.'
	  print,' txt = fitstxtc(key,val,[comm])'
	  print,'   key = FITS keyword.                    in'
	  print,'   val = Keyword value string.            in'
	  print,'   comm = optional comment.               in'
	  print,'   txt = result header character string.  out'
	  return, -1
	endif
 
	t = string(bytarr(80)+32b)
	k = strupcase(key)
	strput, t, strmid(k,0,8), 0
	strput, t, '=', 8
	x = strmid(val,0,67)
	if strlen(x) gt 8 then x = x + "'"
	strput, t, "'", 19
	strput, t, "'"+x, 10
	strput, t, '/', (11 + strlen(x) + 1)>31
	if n_params(0) gt 2 then strput, t, comm, (11 + strlen(x) + 3)>33
 
	return, t
	end

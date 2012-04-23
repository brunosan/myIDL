;+
; NAME:
;       FITSTXTHIS
; PURPOSE:
;       Make a FITS header history.
; CATEGORY:
; CALLING SEQUENCE:
;       txt = fitstxthis(hist)
; INPUTS:
;       hist = history.               in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       txt = result header history.  out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 9 Mar, 1990
;	R. Sterner, 26 Feb, 1991 --- Renamed from fitstxthist.pro
;-
 
	function fitstxthis, hist, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Make a FITS header history.'
	  print,' txt = fitstxthis(hist)'
	  print,'   hist = history.               in'
	  print,'   txt = result header history.  out'
	  return, -1
	endif
 
	t = string(bytarr(80)+32b)
	strput, t, 'HISTORY', 0
	strput, t, hist, 8
	return, t
	end

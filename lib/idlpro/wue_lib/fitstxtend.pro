;+
; NAME:
;       FITSTXTEND
; PURPOSE:
;       Make an END on a  FITS header
; CATEGORY:
; CALLING SEQUENCE:
;       txt = fitstxtend
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       txt = result header comment.  out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       T. Leighton, 2 Oct, 1990
;-
 
	function fitstxtend, help=hlp
 
	if  keyword_set(hlp) then begin
	  print,' Make a FITS header END.'
	  print,' txt = fitstxtend'
	  print,'   txt = result header comment.  out'
	  return, -1
	endif
 
	t = string(bytarr(80,/nozero)+32b)
	zz = '                                                                             '
	strput, t, 'END', 0
	strput, t, zz, 3
	return, t
	end

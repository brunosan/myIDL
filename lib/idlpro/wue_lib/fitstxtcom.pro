;+
; NAME:
;       FITSTXTCOM
; PURPOSE:
;       Make a FITS header comment.
; CATEGORY:
; CALLING SEQUENCE:
;       txt = fitstxtcom(comm)
; INPUTS:
;       comm = comment.               in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       txt = result header comment.  out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 9 Mar, 1990
;	R. Sterner, 26 Feb, 1991 --- Renamed from fitstxtcomm.pro
;-
 
	function fitstxtcom, comm, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Make a FITS header comment.'
	  print,' txt = fitstxtcom(comm)'
	  print,'   comm = comment.               in'
	  print,'   txt = result header comment.  out'
	  return, -1
	endif
 
	t = string(bytarr(80)+32b)
	strput, t, 'COMMENT', 0
	strput, t, comm, 8
	return, t
	end

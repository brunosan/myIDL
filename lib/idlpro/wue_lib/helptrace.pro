;+
; NAME:
;       HELPTRACE
; PURPOSE:
;       Do a help,/trace when !quiet=1
; CATEGORY:
; CALLING SEQUENCE:
;       helptrace
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: Ignore the HELPTRACE message. 
; MODIFICATION HISTORY:
;       R. Sterner, 3 Jan 1990
;-
 
	pro helptrace, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Do a help,/trace when !quiet=1'
	  print,' helptrace
	  print,' Notes: Ignore the HELPTRACE message.'
	  return
	endif
 
	!quiet = 0
	help, /trace
	!quiet = 1
	return
	end

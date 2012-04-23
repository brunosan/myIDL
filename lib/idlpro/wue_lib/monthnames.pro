;+
; NAME:
;       MONTHNAMES
; PURPOSE:
;       Returns a string array of month names.
; CATEGORY:
; CALLING SEQUENCE:
;       mnam = monthnames()
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       mnam = string array of 13 items:     out 
;         ['Error','January',...'December'] 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Sep, 1989
;-
 
	function monthnames, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Returns a string array of month names.'
	  print,' mnam = monthnames()'
	  print,'   mnam = string array of 13 items:     out'
	  print,"     ['Error','January',...'December']"
	  return, -1
	endif
 
	mn = ['Error','January','February','March','April','May',$
	      'June','July','August','September','October',$
	      'November','December']
 
	return, mn
	end

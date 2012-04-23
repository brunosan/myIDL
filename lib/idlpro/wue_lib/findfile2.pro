;+
; NAME:
;       FINDFILE2
; PURPOSE:
;       Find files and sort them.
; CATEGORY:
; CALLING SEQUENCE:
;       f = findfile2(pat)
; INPUTS:
;       pat = filename or wildcard pattern.   in 
; KEYWORD PARAMETERS:
;       Keywords: 	
;         /SORT means sort file names numerically. 
; OUTPUTS:
;       f = sorted array of found file names. out 
; COMMON BLOCKS:
; NOTES:
;       Notes: Test if f(0) eq '' to determine if any files found. 
; MODIFICATION HISTORY:
;       R. Sterner, 18 Mar, 1990
;-
 
	function findfile2, pat, help=hlp, sort=srt
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find files and sort them.'
	  print,' f = findfile2(pat)'
	  print,'   pat = filename or wildcard pattern.   in'
	  print,'   f = sorted array of found file names. out'
	  print,' Keywords:'	
	  print,'   /SORT means sort file names numerically.'
	  print," Notes: Test if f(0) eq '' to determine if any files found."
	  return, -1
	endif
 
	f = findfile(pat)			; Find files.
	f = array(f)				; Force list to be an array.
	if f(0) eq '' then begin		; Any found?
	  print,' No files found.'		; No.
	  return, f				; Return null array.
	endif
 
	if keyword_set(srt) then begin		; Sort?
	  n = n_elements(f)			; Number to sort.
	  ff = strarr(n)			; New file names.
	  for l = 0, n_elements(f)-1 do begin	; Generate new file names.
	    namenum, f(l), pat, i, j, k		;   Find file name pattern.
	    ff(l) = numname(pat, i, j, k, digits=5) ;   name with 5 digit #s.
 	  endfor
	  is = sort(ff)				; Sort extracted numbers.
	  f = f(is)				; Sort files the same.
	endif
 
	return, f				; Return files.
	end
	  

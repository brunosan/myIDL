;+
; NAME:
;       FITSPUTLINE
; PURPOSE:
;       Put a fitsline (string) into a FITS header.
; CATEGORY:
; CALLING SEQUENCE:
;       fitsputline, hdr,line
; INPUTS:
;       line = FITS line .                             in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         ERROR=err.  Error flag: 0=ok, 1=invalid FITS header 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 12 Mar, 1990
;-
 
	pro fitsputline, hdr, line,  error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
          print,' Put a fitsline (string) into a FITS header.'
	  print,' fitsputline, hdr, line
	  print,'   hdr = an existing FITS hdr as a string array.  in,out'
	  print,'   line = FITS line (string).                     in'
	  print,' Keywords:'
	  print,'   ERROR=err.  Error flag: 0=ok, 1=invalid FITS header,'
	  return
	endif
 
 
	;-------  header check ------------
	lh = n_elements(hdr) - 1
	for i = 0, lh do begin
	  if strtrim(hdr(i),2) eq 'END' then goto, next
	endfor
 
	;------  Not FITS header  ---------
	print,' Error in fitsputline: invalid FITS header.'
	err = 1
	return
 
next:
 
	;-----  insert new line  -----------
	if i eq 0 then begin
	  hdr = [line, 'END']
	endif else begin
	  hdr = [hdr(0:i-1),line,'END']
	endelse
 
	;--------  no error  -----------
	err = 0
	return
	end

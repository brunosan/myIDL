;+
; NAME:
;       FITSSAVE
; PURPOSE:
;       Save an array in FITS format.
; CATEGORY:
; CALLING SEQUENCE:
;       fitssave, file, data
; INPUTS:
;       file = FITS file name.     in 
;       data = data array.         in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         TITLE_STRING=s  string to place after the 
;           minimum header as a fits comment. 
;         APPEND_FILE=f  name of file to append to 
;           fits header (after TITLE_STRING).  This 
;           file must contain valid fits header entries. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 12 Mar, 1990
;-
 
	pro fitssave, file, d, help=hlp, title_string=tts, $
	  append_file=afile
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Save an array in FITS format.'
	  print,' fitssave, file, data'
	  print,'   file = FITS file name.     in'
	  print,'   data = data array.         in'
	  print,' Keywords:'
	  print,'   TITLE_STRING=s  string to place after the'
	  print,'     minimum header as a fits comment.'
	  print,'   APPEND_FILE=f  name of file to append to'
	  print,'     fits header (after TITLE_STRING).  This'
	  print,'     file must contain valid fits header entries.'
	  return
	endif
 
	d2 = array(d)				; Force to be an array.
	h = fitsminhdr(d2, /quiet)
	if keyword_set(tts) then begin		; If title string given then
	  fitsputcom, h, tts			; insert after minimum header.
	endif
	if keyword_set(afile) then begin	; If append file given then
	  l = n_elements(h) - 2			; find last min header value
	  h = [h(0:l), getfile(afile), 'END']	; and put append file in
	endif 					; header, add END.
	fitswrite2, file, h, d2
	return
	end

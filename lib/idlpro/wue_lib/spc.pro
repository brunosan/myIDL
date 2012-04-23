;+
; NAME:
;       SPC
; PURPOSE:
;       Return a string with the specified number of spaces.
; CATEGORY:
; CALLING SEQUENCE:
;       s = spc(n,[text])
; INPUTS:
;       n = number of spaces (= string length).   in 
;	text = optional text string.              in
;         # spaces returned is n-strlen(strtrim(text,2))
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = resulting string.                     out  
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 16 Dec, 1984.
;       RES --- rewritten 14 Jan, 1986.
;	R. Sterner, 27 Jun, 1990 --- added text.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION SPC,N, text, help = h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Return a string with the specified number of spaces. 
	  print,' s = spc(n, [text])' 
	  print, '  n = number of spaces (= string length).   in '
	  print,'   text = optional text string.              in'
	  print,'     # spaces returned is n-strlen(strtrim(text,2))'
	  print,'   s = resulting string.                     out' 
	  print,' Note: Number of requested spaces is reduced by the'
	  print,'   length of given string.  Useful for text formatting.'
	  return, -1
	endif
 

	if n_params(0) eq 1 then begin
	  n2 = n
	endif else begin
	  n2 = n - strlen(strtrim(text,2))
	endelse
 
	IF N2 LE 0 THEN RETURN, ''
	RETURN, STRING(BYTARR(N2)+32B)
	END

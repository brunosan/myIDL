;+
; NAME:
;       STRSUB
; PURPOSE:
;       Extract a substring by start and end positions.
; CATEGORY:
; CALLING SEQUENCE:
;       ss = strsub(s, p1, p2)
; INPUTS:
;       s = string to extract from.                    in 
;       p1 = position of first character to extract.   in 
;       p2 = position of last character to extract.    in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ss = extracted substring.                      out 
; COMMON BLOCKS:
; NOTES:
;       Notes: position of first character in s is 0.  If p1 and 
;         p2 are out of range they set to be in range. 
; MODIFICATION HISTORY:
;       Written by R. Sterner, 6 Jan, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION STRSUB,STRNG,P1,P2, help = h
 
	if (n_params(0) lt 3) or keyword_set(h) then begin
	  print,' Extract a substring by start and end positions.'
	  print,' ss = strsub(s, p1, p2)'
	  print,'   s = string to extract from.                    in'
	  print,'   p1 = position of first character to extract.   in'
	  print,'   p2 = position of last character to extract.    in'
	  print,'   ss = extracted substring.                      out'
	  print,' Notes: position of first character in s is 0.  If p1 and'
	  print,'   p2 are out of range they set to be in range.'
	  return, -1
	endif
 
	L1 = P1 > 0
	L2 = P2 < STRLEN(STRNG)
	RETURN, STRMID(STRNG,L1,L2-L1+1)
	END

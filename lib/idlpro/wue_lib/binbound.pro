;+
; NAME:
;       BINBOUND
; PURPOSE:
;       For a binary image return an array with boundary points set to 1.
; CATEGORY:
; CALLING SEQUENCE:
;       b = binbound(bin_image)
; INPUTS:
;       bin_image = binary image (only 0 or 1).   in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = array with boundary points set to 1.  out 
; COMMON BLOCKS:
; NOTES:
;       Notes: The boundary of a binary image is the set of points 
;         in the image that are 1 and also touch a 0. 
;         A binary image may be made using logical operators. 
;         For example, if an image has both positive and negative values 
;         the boundary between them may be found as b = binbound(img gt 0). 
;         To put this boundary into another image, A, do: 
;         w = where(b eq 1) & a(w) = 255. 
; MODIFICATION HISTORY:
;       R. Sterner.  24 June, 1987.
;	R. Sterner, 4 Dec, 1989 --- Converted to Sun.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION BINBOUND, B, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' For binary image return array with boundary points set to 1.'
	  print,' b = binbound(bin_image)'
	  print,'   bin_image = binary image (only 0 or 1).   in'
	  print,'   b = array with boundary points set to 1.  out'
	  print,' Notes: The boundary of a binary image is the set of points'
	  print,'   in the image that are 1 and also touch a 0.'
	  print,'   A binary image may be made using logical operators.'
	  print,'   For example, if an image has both positive and negative'
	  print,'   values the boundary between them may be found as'
	  print,'   b = binbound(img gt 0). To put this boundary into'
	  print,'   another image, A, do:'
	  print,'   w = where(b eq 1) & a(w) = 255.'
	  return, -1
	endif
 
	RETURN, (SMOOTH(B,3) LT 1)*B
 
	END

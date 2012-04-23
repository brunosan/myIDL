;+
; NAME:
;       RADIAL_IMG
; PURPOSE:
;       Make an image array with a radial brightness distribution.
; CATEGORY:
; CALLING SEQUENCE:
;       out = radial_img(x,y,n)
; INPUTS:
;       x,y = coordinates of brightness distribution curve.   in 
;       n = side length of square output array.               in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = resulting image array.                          out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 6 Jul, 1990
;-
 
	function radial_img, x,y,n, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make an image array with a radial brightness distribution.'
	  print,' out = radial_image(x,y,n)'
	  print,'   x,y = coordinates of brightness distribution curve.   in'
	  print,'   n = side length of square output array.               in'
	  print,'   out = resulting image array.                          out'
	  return, -1
	endif
 
	diag = sqrt(2.*n^2)
	mxx = max(x)
	if mxx lt diag then begin
	  print,' Error in radial_img: given X coordinate must'
	  print,'   extend at least to ',diag
	  return, -1
	endif
 
	d = shift(dist(n),n/2,n/2)
	t = makex(0.,diag,1.)
 
	yy = interpol(y,x,t)
	return, yy(d)
 
	end

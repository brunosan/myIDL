;+
; NAME:
;       BILINEAR2
; PURPOSE:
;       Do bilinear interpolation into a 2-d array.
; CATEGORY:
; CALLING SEQUENCE:
;       zout = bilinear2(zz, x, y)
; INPUTS:
;       zz = 2-d array to interpolate.            in 
;       x,y = x,y coordinates of desired points.  in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       zout = resulting interpolated values.     out 
; COMMON BLOCKS:
; NOTES:
;       Notes: x and y may be any shape. 
; MODIFICATION HISTORY:
;       R. Sterner, 16 Oct, 1990
;        G. Jung, 19 Jan, 1993 renamed from bilinear.pro
;-
 
	function bilinear2, zz, x, y, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Do bilinear interpolation into a 2-d array.'
	  print,' zout = bilinear2(zz, x, y)'
	  print,'   zz = 2-d array to interpolate.            in'
	  print,'   x,y = x,y coordinates of desired points.  in'
	  print,'   zout = resulting interpolated values.     out'
	  print,' Notes: x and y may be any shape.'
	  return, -1
	endif
 
	x1 = floor(x)		; Get four pixels around desired pt.
	x2 = x1 + 1
	ya = floor(y)
	yb = ya + 1
	fx = (x-x1)/(x2-x1)	; Fractional position inside 4 pts.
	fy = (y-ya)/(yb-ya)
	za = fx*zz(x2,ya) + zz(x1,ya)*(1-fx)	; Interpolate in X.
	zb = fx*zz(x2,yb) + zz(x1,yb)*(1-fx)
	z = fy*zb + za*(1-fy)			; Interpolate in Y.
	return, z
	end

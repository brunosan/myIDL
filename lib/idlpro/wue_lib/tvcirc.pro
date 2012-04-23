;+
; NAME:
;       TVCIRC
; PURPOSE:
;       Draw a circle on the display.
; CATEGORY:
; CALLING SEQUENCE:
;       tvcirc, x, y, r
; INPUTS:
;       x,y = center of circle in device units.    in 
;       r = Radius of circle in device units.      in 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, Aug 1989
;-
 
	pro tvcirc, x, y, r, help = h
 
	if (n_params(0) lt 3) or keyword_set(h) then begin
	  print,' Draw a circle on the display.'
	  print,' tvcirc, x, y, r'
	  print,'   x,y = center of circle in device units.    in'
	  print,'   r = Radius of circle in device units.      in'
	  return
	endif
 
	a = makex(0, 360, 2)/!radeg
	xx = x + r*cos(a)
	yy = y + r*sin(a)
	plot,xx,yy,/device
	return
	end
	 

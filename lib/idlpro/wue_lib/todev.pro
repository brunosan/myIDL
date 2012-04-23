;+
; NAME:
;       TODEV
; PURPOSE:
;       Convert from data or normalized to device coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       todev,x1,y1,x2,y2
; INPUTS:
;       x1,y1 = input coordinates.                in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /DATA if x1,y1 are data coordinates (default). 
;         /NORM if x1,y1 are normalized coordinates. 
; OUTPUTS:
;       x2,y2 = device coordinates.               out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 21 June 1990
;-
 
	pro todev, x1, y1, x2, y2, data=dt, normalized=nrm, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Convert from data or normalized to device coordinates.'
	  print,' todev,x1,y1,x2,y2'
	  print,'   x1,y1 = input coordinates.                in'
	  print,'   x2,y2 = device coordinates.               out'
	  print,' Keywords:'
	  print,'   /DATA if x1,y1 are data coordinates (default).'
	  print,'   /NORM if x1,y1 are normalized coordinates.'
	  return
	endif
 
 
	if keyword_set(nrm) then begin
	  x2 = x1*!d.x_size
	  y2 = y1*!d.y_size
	  return
	endif
 
	x2 = !d.x_size*(!x.s(0) + !x.s(1)*x1)
	y2 = !d.y_size*(!y.s(0) + !y.s(1)*y1)
	return
 
	end

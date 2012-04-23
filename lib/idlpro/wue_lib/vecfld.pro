;+
; NAME:
;       VECFLD
; PURPOSE:
;       Plot a 2-d vector field.
; CATEGORY:
; CALLING SEQUENCE:
;       vecfld, u, v, [l]
; INPUTS:
;       u = 2-d array of vector x components.   in 
;       v = 2-d array of vector y components.   in 
;       l = Optional max length of vectors.     in 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 8 Sep, 1989.
;-
 
	pro vecfld, u, v, l, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot a 2-d vector field.'
	  print,' vecfld, u, v, [l]'
	  print,'   u = 2-d array of vector x components.   in'
	  print,'   v = 2-d array of vector y components.   in'
	  print,'   l = Optional max length of vectors.     in'
	  return
	endif
 
	if n_params(0) lt 3 then l = 1.
	mag = sqrt(u^2 + v^2)
	w = array(where(mag eq 0))
	if w(0) ne -1 then mag(w) = 1.
	x = l*u/mag
	y = l*v/mag
 
	sz = size(u)
	lx = sz(1) - 1
	ly = sz(2) - 1
 
	plot, [0, lx], [0, ly], /nodata
 
	for iy = 0, ly do begin
	  for ix = 0, lx do begin
	    dx = x(ix,iy)/2.
	    dy = y(ix,iy)/2.
	    plots, [ix-dx,ix+dx]+.5, [iy-dy,iy+dy]+.5
	  endfor
	endfor
 
	return
	end

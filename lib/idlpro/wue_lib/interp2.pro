;+
; NAME:
;       INTERP2
; PURPOSE:
;       Interpolate a 2-d array to another size.
; CATEGORY:
; CALLING SEQUENCE:
;       b = interp2(a, nx, ny, [flag])
; INPUTS:
;       a = input array.                        in 
;       nx, ny = desired new dimensions.        in 
;       flag = interp flag: 0=NN (def), 1=BL.   in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /AGAIN uses same set of interpolation arrays 
;           as last time.  Faster. 
; OUTPUTS:
;       b = output array.                       out 
; COMMON BLOCKS:
;       interp2_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 5 Dec, 1989
;       From a routine by Phil Wiborg.
;-
 
	function interp2, s, nx, ny, flag, help=hlp, again=rpt
 
	common interp2_com, x, y, x0, x1, y0, y1, fx, fy
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Interpolate a 2-d array to another size.'
	  print,' b = interp2(a, nx, ny, [flag])'
	  print,'   a = input array.                        in'
	  print,'   nx, ny = desired new dimensions.        in'
	  print,'   flag = interp flag: 0=NN (def), 1=BL.   in'
	  print,'   b = output array.                       out'
	  print,' Keywords:'
	  print,'   /AGAIN uses same set of interpolation arrays'
	  print,'     as last time.  Faster.'
	  return, -1
	endif
 
	;-----  First make indexing arrays  ------
	sz = size(s)		; Original array size.
	nx1 = sz(1)
	ny1 = sz(2)
 
	if n_params(0) lt 4 then flag = 0
 
	;----- Nearest Neighbor interpolation  -------
	;---  x,y = pixel coordinates of each point in output array.  -------
	if not keyword_set(rpt) then begin
	makexy, 0.,nx1,float(nx1)/(nx-1.),0.,ny1,float(ny1)/(ny-1.),x,y
	endif
	if flag eq 0 then return, s(x,y)
 
	;-----  Bilinear inpterpolation  ---------
	;---  x,y = pixel coordinates of each point in output array.  -------
	if not keyword_set(rpt) then begin
	  makexy, 0.,nx1-1.,float(nx1-1.)/(nx-1.),0.,ny1-1.,$
	    float(ny1-1.)/(ny-1.), x, y
	  x0 = fix(x)
	  x1 = fix(x+1)
	  y0 = fix(y)
	  y1 = fix(y+1)
 
	  fx = x mod 1.
	  fy = y mod 1.
	endif
 
	ss = float(s)
 
	ssfx =	(ss(x1,y0)-ss(x0,y0))*fx
	ans =	ssfx + $
		(ss(x0,y1)-ss(x0,y0))*fy + $
		((ss(x1,y1)-ss(x0,y1))*fx - ssfx)*fy + $
		ss(x0,y0)
 
	return, ans
	end

;+
; NAME:
;       POLYSTAT
; PURPOSE:
;       Compute polygon statistics (# vertices, area, perimeter).
; CATEGORY:
; CALLING SEQUENCE:
;       polystat, x, y, s
; INPUTS:
;       x,y = polygon vertices.   in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = statistics.           out 
;         s = [n_vertices, area, perimeter]. 
; COMMON BLOCKS:
; NOTES:
;       Notes: See also convexhull. 
; MODIFICATION HISTORY:
;       R. Sterner, 30 Oct, 1990
;-
 
	pro polystat, x, y, stats, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Compute polygon statistics (# vertices, area, perimeter).'
	  print,' polystat, x, y, s'
	  print,'   x,y = polygon vertices.   in'
	  print,'   s = statistics.           out'
	  print,'     s = [n_vertices, area, perimeter].'
	  print,' Notes: See also convexhull.'
	  return
	endif
 
	n = n_elements(x)
	if n ne n_elements(y) then begin
	  print,' Error in polystat: vertex arrays must have same size.'
	  return
	endif
	if n lt 2 then begin
	  print,' Error in polystat: polygon has only 1 point.'
	  return
	endif
 
	a = 0.
	p = 0.
 
	for i1 = 0, n-1 do begin
	  i2 = (i1 + 1) mod n
	  a = a + (x(i2) - x(i1))*(y(i2) + y(i1))/2.
	  p = p + sqrt((x(i2)-x(i1))^2 + (y(i2)-y(i1))^2)
	endfor
 
	a = abs(a)
 
	stats = [n,a,p]
	return
 
	end

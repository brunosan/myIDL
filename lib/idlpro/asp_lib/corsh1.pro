function corsh1, line
;+
;
;	function:  corsh1
;
;	purpose:  find the shift of line by finding the minimum intensity to
;		  sub-pixel accuracy with polynomial interpolation
;
;==============================================================================

if n_params() ne 1 then begin
	print
	print, "usage:  ret = corsh1(line)"
	print
	print, "	Find the shift of line by finding the minimum"
	print, "	intensity to sub-pixel accuracy with polynomial"
	print, "	interpolation."
	print
	return, 0
endif
;-

nx = sizeof(line, 1)
amin = min(line, imin)

; ensure imin stays within acceptable limits
imin = imin < (nx-2)
imin = imin > 1

;  fit parabola about this point
xx = indgen(nx)
coeff = poly_fit(xx(imin-1:imin+1), line(imin-1:imin+1), 2)

return, -coeff(1)/2.0/coeff(2)-4.0
end

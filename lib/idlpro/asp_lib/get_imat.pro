function get_imat, dim
;+
;
;	function:  get_imat
;
;	purpose:  return a floating point identity matrix
;
;	author:  rob@ncar, 10/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  I = get_imat(dim)"
	print
	print, "	Return a floating point identity matrix."
	print
	print, "	Arguments"
	print, "		dim	- dimension of matrix (dim x dim)"
	print
	print
	print, "   ex:  I = get_imat(4)"
	print
	return, 0
endif
;-
;
;	Return I.
;
i = fltarr(dim, dim)
i(indgen(dim) * (dim+1)) = 1.0
return, i
end

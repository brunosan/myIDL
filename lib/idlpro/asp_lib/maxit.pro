pro maxit, array, maxval
;+
;
;	procedure:  maxit
;
;	purpose:  truncate an array to the maximum value specified
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  maxit, array, maxval"
	print
	print, "	Truncate an array to the maximum value specified."
	print
	print, "	Arguments"
	print, "		array	- input array"
	print, "		maxval	- maximum value"
	print
	return
endif
;-

array = array < maxval

end

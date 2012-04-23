pro minit, array, minval
;+
;
;	procedure:  minit
;
;	purpose:  truncate an array to the minimum value specified
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  minit, array, minval"
	print
	print, "	Truncate an array to the minimum value specified."
	print
	print, "	Arguments"
	print, "		array	- input array"
	print, "		minval	- minimum value"
	print
	return
endif
;-

array = array > minval

end

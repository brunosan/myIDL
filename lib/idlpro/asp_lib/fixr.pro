function fixr, value
;+
;
;	function:  fixr
;
;	purpose:  fix a scalar or array, rounding to nearest integer
;
;	author:  rob@ncar, 6/92
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ret = fixr(value)"
	print
	print, "	Fix a scalar or array, rounding to nearest integer."
	print
	return, 1
endif
;-
;
;	Round, fix and return.
;
return, fix(round(value))
end

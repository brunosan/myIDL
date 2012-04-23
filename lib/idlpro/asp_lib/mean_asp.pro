function mean, array
;+
;
;	function:  mean
;
;	purpose:  calculate mean (float) value of an array
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  m = mean(array)"
	print
	print, "	Calculate mean (float) value of an array."
	print
	return, 0
endif
;-
;
return, total( float(array)) / float(n_elements(array) )
end

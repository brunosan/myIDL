function calc_rms, array, value=value
;+
;
;	function:  calc_rms
;
;	purpose:  calculate RMS for an array
;
;	author:  rob@ncar, 9/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  rms = calc_rms(array)"
	print
	print, "	Calculate RMS for an array."
	print
	print, "	Arguments"
	print, "		array	 - input array"
	print
	print, "	Keywords"
	print, "		value	 - value about which to calculate RMS"
	print, "			   (def = use mean of array)"
	print
	return, 0
endif
;-
;
;	Check number of points.
;
on_error,2              		;return to caller if error
n = n_elements(array)
if n le 1 then message, 'Number of data points must be > 1'
;
;	Get value about which to calculate RMS.
;
if n_elements(value) eq 0 then value = mean(array)
;
;	Calculate and return the RMS.
;
return, sqrt( total((array - value)^2) / (n - 1) )
end

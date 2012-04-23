function truncit, value, ndigits
;+
;
;	function:  truncit
;
;	purpose:  truncate a floating point value to a number of digits
;
;	author:  rob@ncar, 10/94
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = truncit(value, ndigits)"
	print
	print, "	Truncate a floating point value [scalar|array]"
	print, "	to a specified # of digits."
	print
	print, "	(ndigits ge 0) --> round after  the decimal point"
	print, "	(ndigits lt 0) --> round before the decimal point"
	print
	return, 0.0
endif
;-
;
;	Return truncated number.
;
factor = 10.0 ^ abs(ndigits)
if ndigits ge 0 then return, floor(value * factor) / factor  $
		else return, floor(value / factor) * factor
;
end

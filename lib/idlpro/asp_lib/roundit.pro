function roundit, value, ndigits
;+
;
;	function:  roundit
;
;	purpose:  round a floating point number to a number of digits
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = roundit(value, ndigits)"
	print
	print, "	Round a floating point value [scalar|array]"
	print, "	to a specified # of digits."
	print
	print, "	(ndigits ge 0) --> round after  the decimal point"
	print, "	(ndigits lt 0) --> round before the decimal point"
	print
	return, 0.0
endif
;-
;
;	Return rounded number.
;
factor = 10.0 ^ abs(ndigits)
if ndigits ge 0 then return, round(value * factor) / factor  $
		else return, round(value / factor) * factor
;
end

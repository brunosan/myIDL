function float_str, value, ndigits
;+
;
;	function:  float_str
;
;	purpose:  convert a floating point number to a string
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = float_str(value, ndigits)"
	print
	print, "	Convert a floating point number to a string."
	print
	print, "	Arguments"
	print, "	   value   - floating point number"
	print, "	   ndigits - number of digits (rounded)"
	print, "		      (ge 0) --> # to keep after the dec. pt."
	print, "		      (lt 0) --> # to remove  b4 the dec. pt."
	print
	return, ''
endif
;-
;
;	Round it; "string it"; and truncate zeros and/or blanks.
;
str = stringit(roundit(value, ndigits))

dot_index = strpos(str, '.')
if dot_index eq -1 then message, 'error finding decimal point'

if ndigits gt 0 then begin
	return, strmid(str, 0, dot_index + ndigits + 1)
endif else begin
	return, strmid(str, 0, dot_index)
endelse
;
end

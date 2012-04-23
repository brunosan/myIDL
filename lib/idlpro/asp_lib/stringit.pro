function stringit, value
;+
;
;	function:  stringit
;
;	purpose:  return the value as a string with whitespace compressed
;
;	example:  print, 'The number is ' + stringit(num) + '.'
;
;	author:  rob@ncar, 3/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  str = stringit(num)"
	print
	print, "	Return 'num' as a string with whitespace compressed."
	print
	return, ''
endif
;-
;
;	Return compressed string.
;
;;return, strcompress(string(value), /remove_all)
return, strtrim(strcompress(string(value)), 2)
end

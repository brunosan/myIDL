function str2int, string, num
;+
;
;	function:  str2int
;
;	purpose:  return an array of integers given a sting of integers
;
;	author:  rob@ncar, 11/92
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() lt 1) or (n_params() gt 2) then begin
	print
	print, "usage:  iarr = str2int(string [, num])"
	print
	print, "	Return an array of integers given a sting of integers."
	print
	print, "	Arguments"
	print, "		string	 - input string"
	print, "		num	 - returned number of integers found"
	print
	return, 0
endif
;-
;
;	Create array of integers (assume string contains integers).
;
iarr = fix(get_words(string))
;
;	Optionally return number of integers.
;
if n_params() eq 2 then num = n_elements(iarr)
;
;	Return integer array.
;
return, iarr
end

function in_set, vector, scalar, indexes=indexes, count=count
;+
;
;	function:  in_set
;
;	purpose:  return 1 if scalar is in vector, else return 0
;
;	author:  rob@ncar, 5/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = in_set(vector, scalar)"
	print
	print, "	Return 1 if scalar is in vector, else return 0."
	print
	print, "	Arguments"
	print, "		vector	- input vector (1D array) to search in"
	print, "		scalar	- input scalar to search for"
	print
	print, "	Keywords"
	print, "		indexes	- optional returned indexes 'WHERE'"
	print, "			  matches are found (long array if"
	print, "			  found; long scalar -1 if not)"
	print, "		count	- optional returned # of matches"
	print
	print
	print, "   ex:  print, in_set([1, 3, 5], 3)"
	print, "		1"
	print
	return, -1
endif
;-
;
;	Set to stop at statement that caused the error.
;
on_error, 0
;
;	Check inputs.
;
if (size(vector))(0)  ne 1 then message, "'vector' must be 1D"
if (size(scalar))(0)  ne 0 then message, "'scalar' must be 0D"
if n_elements(vector) lt 1 then message, "'vector' is empty"
;
;	Return 1 if found.
;
indexes = where(vector eq scalar, count)
if count gt 0 then return, 1
;
;	Return 0 since not found.
;
return, 0
end

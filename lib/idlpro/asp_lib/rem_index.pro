function rem_index, vector, index
;+
;
;	function:  rem_index
;
;	purpose:  remove a value from a vector
;
;	author:  rob@ncar, 2/94
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  vec = rem_index(vector, index)"
	print
	print, "	Remove a value from a vector."
	print
	print, "	Arguments"
	print, "		vector	- input vector (1D array)"
	print, "		index	- index of entry to remove (int/long)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  print, rem_index([1, 3, 5], 1)"
	print, "		1  5"
	print
	return, -1
endif
;-
;
;	Stop if error.
;
on_error, 0
;
;	Check inputs.
;
if sizeof(vector, 0) ne 1 then  message, "'vector' must be 1D"
nv = sizeof(vector, 1)
if nv lt 2 then                 message, "'vector' only has one value"
nv1 = nv - 1
;
if sizeof(index,  0) ne 0 then  message, "'index' must be scalar"
;
;	Return a vector with one element removed.
;
if index eq 0 then begin
	return, vector(1:nv1)
endif else if index eq nv1 then begin
	return, vector(0:nv1-1)
endif else begin
	return, [vector(0:index-1), vector(index+1:nv1)]
endelse
;
end

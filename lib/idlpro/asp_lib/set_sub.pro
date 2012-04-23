function set_sub, v1, v2
;+
;
;	function:  set_sub
;
;	purpose:  return the result of one set minus another set
;
;	author:  rob@ncar, 2/94
;
;	notes:  - see set_sub2 for a version that may be faster (depends on
;		  the data); however, probably best to use a different
;		  approach (with WHEREs) for big sets
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  v3 = set_sub(v1, v2)"
	print
	print, "	Return the result of one set minus another set."
	print
	print, "	Arguments"
	print, "		v1	- set to subtract from (1D array)"
	print, "		v2	- set to subtract (scalar or 1D array)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  print, set_sub([1, 3, 5, 7], 5)"
	print, "		1  3  7"
	print, "        print, set_sub([1, 3, 5, 7], [3, 7, 8])"
	print, "		1  5"
	print
	return, -1
endif
;-
print, timer(/init)
;
;	Stop if error.
;
on_error, 0
;
;	Check inputs and set some parameters.
;
if sizeof(v1, 0) ne 1 then  message, "'v1' must be 1D array"
num = n_elements(v2)
v3 = v1
;
;	Remove matching elements.
;
for i = 0, num-1 do $
	if in_set(v3, v2(i), indexes=indexes) then $
		v3 = rem_index(v3, indexes(0))
;
;	Return new vector.
;
print, timer()
return, v3
end

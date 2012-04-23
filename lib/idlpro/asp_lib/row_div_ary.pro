function row_div_ary, row, array
;+
;
;	function:  row_div_ary
;
;	purpose:  divide a 1-D array (row) by a 2-D array
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = row_div_ary(row, array)"
	print
	print, "	Divide a 1-D array (row) by a 2-D array."
	print
	print, "	Arguments"
	print, "		row	  - input 1-D array"
	print, "		array	  - input 2-D array"
	print
	return, 0
endif
;-
;
;	Allocate the resulting 2-D array.
;
result = array			; result will be same type as input array
nx = sizeof(row) 
;
;	Divide the row by the array.
;	(For each column of the input 2-D array, divide it by the respective
;	 entry in the row.)
;
for i = 0, nx - 1 do begin
	result(i, *) = row(i) / array(i, *)
endfor
;
;	Return the result.
;
return, result
end

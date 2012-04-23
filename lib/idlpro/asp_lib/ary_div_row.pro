function ary_div_row, array, row
;+
;
;	function:  ary_div_row
;
;	purpose:  divide a 2-D array by a 1-D array (row)
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = ary_div_row(array, row)"
	print
	print, "	Divide a 2-D array by a 1-D array (row)."
	print
	print, "	Arguments"
	print, "		array	  - input 2-D array"
	print, "		row	  - input 1-D array"
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
;	Divide the array by the row.
;	(For each column, divide it by the respective entry in the row.)
;
for i = 0, nx - 1 do begin
	result(i, *) = array(i, *) / row(i)
endfor
;
;	Return the result.
;
return, result
end

function avg_row, array, xmin, xmax, ymin, ymax
;+
;
;	function:  avg_row
;
;	purpose:  average some "rows" (y = const.) in a 2-D array
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() ne 1) and (n_params() ne 5) then begin
	print
	print, "usage:  a = avg_row(array [, xmin, xmax, ymin, ymax])"
	print
	print, "	Average some 'rows' (y = const.) in a 2-D array."
	print
	return, 0
endif
;-
;
;	Set variables.
;
;
;	Set variables.
;
if n_params() eq 1 then begin
	xmin = 0
	ymin = 0
	xmax = sizeof(array, 1) - 1
	ymax = sizeof(array, 2) - 1
endif
xlen = xmax - xmin + 1
;
;	Allocate and zero sum array.
;
sum = dblarr(xlen)
;
;	Sum rows of values.
;
for y = ymin, ymax do begin
	sum = sum + array(xmin:xmax, y)
endfor
;
;	Return average row.
;
return, sum / (ymax - ymin + 1)
end

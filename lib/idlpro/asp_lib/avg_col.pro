function avg_col, array, xmin, xmax, ymin, ymax
;+
;
;	function:  avg_col
;
;	purpose:  average some "cols" (x = const.) in a 2-D array
;
;	author:  rob@ncar, 4/92
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() ne 1) and (n_params() ne 5) then begin
	print
	print, "usage:  a = avg_col(array [, xmin, xmax, ymin, ymax])"
	print
	print, "	Average some 'cols' (x = const.) in a 2-D array."
	print
	return, 0
endif
;-
;
;	Set variables.
;
if n_params() eq 1 then begin
	xmin = 0
	ymin = 0
	xmax = sizeof(array, 1) - 1
	ymax = sizeof(array, 2) - 1
endif
ylen = ymax - ymin + 1
;
;	Allocate and zero sum array.
;
sum = dblarr(ylen)
;
;	Sum cols of values.
;
for x = xmin, xmax do begin
	sum = sum + array(x, ymin:ymax)
endfor
;
;	Return average col.
;
return, sum / (xmax - xmin + 1)
end

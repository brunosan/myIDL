function mean_col, array
;+
;
;	function:  mean_col
;
;	purpose:  calculate mean values of the columns in an array
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ret = mean_col(array)"
	print
	print, "	Calculate mean values of the columns in an array."
	print
	return, 0
endif
;-
;
;	Return means of columns.
;
nx = sizeof(array)
means = fltarr(nx, /nozero)

for i = 0, nx - 1 do begin
	means(i) = mean(array(i, *))
endfor

return, means
end

pro flipx, array
;+
;
;	procedure:  flipx
;
;	purpose:  flip the order of the X-coords in a 2-D array
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  flipx, array"
	print
	print, "	Flip the order of the X-coords in a 2-D array."
	print
	return
endif
;-

nx = sizeof(array, 1)
if nx le 1 then return

nx2 = (nx / 2) - 1
right = nx - 1

for left = 0, nx2 do begin
	left_col = array(left, *)
	array(left, *) = array(right, *)
	array(right, *) = left_col
	right = right - 1
endfor

end

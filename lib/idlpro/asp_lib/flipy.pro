pro flipy, array
;+
;
;	procedure:  flipy
;
;	purpose:  flip the order of the Y-coords in a 2-D array
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  flipy, array"
	print
	print, "	Flip the order of the Y-coords in a 2-D array."
	print
	return
endif
;-

ny = sizeof(array, 2)
if ny le 1 then return

ny2 = (ny / 2) - 1
top = ny - 1

for bottom = 0, ny2 do begin
	bottom_row = array(*, bottom)
	array(*, bottom) = array(*, top)
	array(*, top) = bottom_row
	top = top - 1
endfor

end

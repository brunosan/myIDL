pro gain_check, gain, out
;+
;
;	procedure:  gain_check
;
;	purpose:  check gaintable from buildgn.pro for all zeros in
;		  independent (monotonic) values  [that should not happen]
;
;	author:  rob@ncar, 10/92
;
;	inputs:		gain	- gaintable from buildgn.pro
;
;	outputs:	out	- image showing anomolies, if present
;
;	notes:  1) Use something like 'tvwin' or 'mm' on the region of 'out'
;		   that should be correct to see if it really is correct.
;
;			With tvwin, bad spots appear as white dots.
;
;			With mm, if max=1.0 then you have bad spots.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  gain_check, gain, out"
	print
	print, "	Check gaintable from buildgn.pro for all zeros in"
	print, "	independent (monotonic) values [that should not"
	print, "	happen]."
	print
	print, "	Arguments"
	print, "		gain	- gaintable from buildgn.pro"
	print, "		out	- image showing anomolies, if present"
	print
	print, "	Use something like 'tvwin' or 'mm' on the region of"
	print, "	'out' that should be correct to see if it really is"
	print, "	correct."
	print, "		With tvwin, bad spots appear as white dots."
	print, "		With mm, if max=1.0 then you have bad spots."
	print
	return
endif
;-

;
;	set general parameters
;
true = 1
false = 0
;
;	get dimensions
;
ng = sizeof(gain, 1)
nx = sizeof(gain, 3)
ny = sizeof(gain, 4)
ng1 = ng - 1
nx1 = nx - 1
ny1 = ny - 1
;
;	create and zero output image
;
out = fltarr(nx, ny)
;
;	Check each point of image for zero-sets.
;
for i = 0, nx1 do for j = 0, ny1 do begin

	ok = false

	for k = 0, ng1 do  if gain(k, 0, i, j) ne 0.0 then ok = true

	if not ok then out(i, j) = 1.0

endfor

end

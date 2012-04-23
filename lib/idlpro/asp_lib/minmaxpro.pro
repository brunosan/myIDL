pro minmaxpro, input
;+
;
;	procedure:  minmax
;
;	purpose:  Print min and max values of input.
;
;	author:  rob@ncar, 2/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  minmaxpro, input"
	print
	print, "	Print min and max values of input."
	print
	return
endif
;-
;
;	Print range.
;
minval = min(input, max=maxval)
print
print, '  min:  ' + stringit(minval) + ',  max:  ' + stringit(maxval)
print
end

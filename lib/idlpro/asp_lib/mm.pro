pro mm, input
;+
;
;	procedure:  mm
;
;	purpose:  print min and max values of input (same as 'minmax')
;
;	author:  rob@ncar, 10/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  mm, input"
	print
	print, "	Print min and max values of input."
	print
	return
endif
;-
;
minmaxpro, input
end

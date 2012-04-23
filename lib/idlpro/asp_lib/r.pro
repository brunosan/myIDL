pro r, dummy
;+
;
;	procedure:  r
;
;	purpose:  do a retall (faster to type)
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  r"
	print
	print, "	Does a RETALL."
	print
	return
endif
;-

retall
end

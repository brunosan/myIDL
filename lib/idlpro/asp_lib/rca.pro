pro rca, dummy
;+
;
;	procedure:  rca
;
;	purpose:  do a 'RETALL' and a 'CLOSE, /ALL' (faster to type)
;
;	author:  rob@ncar, 10/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  rca"
	print
	print, "	Do a 'RETALL' and a 'CLOSE, /ALL' (faster to type)."
	print
	return
endif
;-

close, /all	; must do close first
retall
end

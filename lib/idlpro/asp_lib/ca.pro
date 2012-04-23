pro ca, dummy
;+
;
;	procedure:  ca
;
;	purpose:  do a CLOSE, /ALL (faster to type)
;
;	author:  rob@ncar, 10/93
;
;==============================================================================

if n_params() ne 0 then begin
	print
	print, "usage:  ca"
	print
	print, "	Does a CLOSE, /ALL."
	print
	return
endif
;-

close, /all
end

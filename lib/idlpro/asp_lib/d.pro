pro d, dummy
;+
;
;	procedure:  d
;
;	purpose:  delete all windows (calls delwin.pro)
;
;	author:  rob@ncar, 6/92
;
;==============================================================================

if n_params() ne 0 then begin
	print
	print, "usage:  d"
	print
	print, "	Deletes all windows (calls delwin.pro)."
	print
	return
endif
;-

delwin
end

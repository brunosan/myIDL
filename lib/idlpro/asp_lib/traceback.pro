pro traceback, dummy
;+
;
;	procedure:  traceback
;
;	purpose:  print traceback information
;
;	author:  rob@ncar, 8/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
usage:
	print
	print, "usage:  traceback"
	print
	print, "	Print traceback information."
	print
	print, "	Arguments"
	print, "	    (none)"
	print
	print, "	Keywords"
	print, "	    (none)"
	print
	return
endif
;-
;
message, /informational, /traceback, /continue, ''
end

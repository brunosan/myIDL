pro ls, dummy
;+
;
;	procedure:  ls
;
;	purpose:  spawn an ls (simpler than $ls)
;
;	author:  rob@ncar, 2/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  ls"
	print
	print, "	Does '$ls'."
	print
	return
endif
;-

spawn, 'ls'
end

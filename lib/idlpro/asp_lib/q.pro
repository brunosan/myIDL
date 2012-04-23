pro q, dummy
;+
;
;	procedure:  q
;
;	purpose:  exit idl (faster to type)
;
;	author:  rob@ncar
;
;==============================================================================

if n_params() ne 0 then begin
	print
	print, "usage:  q"
	print
	print, "	Exits IDL."
	print
	return
endif
;-

print, format='(/"Exiting IDL ..."/)'
exit
end

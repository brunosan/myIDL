pro path, dummy
;+
;
;	procedure:  path
;
;	purpose:  print !PATH in readable format
;
;	author:  rob@ncar, 11/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  path"
	print
	print, "	Print !PATH in readable format."
	print
	return
endif
;-
;
;	Print each part of !PATH on a separate line.
;
p = !path
f = '(15X, A)'
;
while strlen(p) ne 0 do begin
	colon = strpos(p, ':')
	if colon lt 0 then begin
		print, p, format=f
		p = ''
	endif else begin
		print, strmid(p, 0, colon), format=f
		p = strmid(p, colon+1, strlen(p)-colon-1)
	endelse
endwhile
;
end

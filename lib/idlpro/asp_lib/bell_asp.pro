pro bell, num, dummy
;+
;
;	procedure:  bell
;
;	purpose:  ring the bell
;
;==============================================================================

if n_params() gt 1 then begin
	print
	print, "usage:  bell [, num]"
	print
	print, "	Ring the bell a number of times [default = 1]."
	print
	return
endif
;-

if n_params() eq 0 then num = 1
for i = 1, num do begin
	print, string(7b), format='($, A)'
	wait, 0.25
endfor

end

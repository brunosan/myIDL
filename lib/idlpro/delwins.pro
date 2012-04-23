pro delwins, dummy
;+
;
;	function:  delwins
;
;	purpose:  delete all windows
;
;	author:  rob@ncar, 1/92
;
;	note:  "window, /free" uses the highest unused index, starting with
;		127 ... but sometimes starting with 32 and going upward.
;
;==============================================================================

if n_params() ne 0 then begin
	print
	print, "usage:  delwin"
	print
	print, "	Deletes all windows."
	print
	return
endif
;-

while(!d.window ne -1) do wdelete,!d.window

end

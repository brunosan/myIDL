function get_ncolor, dummy
;+
;
;	function:  get_ncolor
;
;	purpose:  return the number of available colors
;
;	author:  rob@ncar, 4/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  nc = get_ncolor()"
	print
	print, "	Return the number of available colors."
	print
	print, "	Arguments"
	print, "		(none)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return, 0
endif
;-
;
;	Get number of available colors.
;	(Must open X window so that !d.n_colors is set properly.)
;	[This part is set up to handle doing PostScript output.]
;
old_device = !d.name			; save old device type
set_plot, 'x'				; change to X windows
window, /free, /pixmap, xs=1, ys=1	; open X pixmap
wdelete, !d.window			; remove the pixmap
num_total = !d.n_colors			; get number of available colors
set_plot, old_device			; return to old device type
;
return, num_total
end

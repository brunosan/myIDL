pro colorw, dummy
;+
;
;	procedure:  colorw
;
;	purpose:  load grayscale color table plus one special color
;
;	author:  rob@ncar, 4/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  colorw"
	print
	print, "	Load grayscale color table plus one special color."
	print, "	(See 'scalew.pro')"
	print
	print, "	Arguments"
	print, "		(none)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
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
;	Create and zero R,G,B arrays.
;
r = bytarr(num_total)
g = bytarr(num_total)
b = bytarr(num_total)
;
;	Set up colormap indices.
;
ix_nofit = 0
ix_gray = 1
num_special = 1
num_gray = num_total - num_special
;
;	Fill special entries.
;
r(0) = 151				; background
g(0) = 201
b(0) = 202
;
;	Fill grayscale.
;
ramp = bytscl( findgen(num_gray) )
ix = ix_gray + num_gray - 1
r(ix_gray:ix) = ramp
g(ix_gray:ix) = ramp
b(ix_gray:ix) = ramp
;
;	Install color table.
;
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
r_curr = r
g_curr = g		; set for IDL library color routines
b_curr = b
tvlct, r, g, b
;
;	Done.
;
end

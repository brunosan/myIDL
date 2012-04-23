pro az_view, image, big=big
;+
;
;	procedure:  az_view
;
;	purpose:  azimuth viewer (prototype)
;
;	author:  rob@ncar, 2/93
;
;	usage:  restore, '~rob/test/azm.save'
;		az_widget, a
;		az_widget, a, /big
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  az_view, image"
	print
	print, "	Azimuth viewer (prototype)."
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Set common blocks.
;
common az_comm, base, max, index_im
;
;	Set general parameters.
;
n_colors = !d.n_colors
n_special = 3
n_gray = n_colors - n_special
max = 360.0 * (n_gray - 1) / n_gray
max = fixr(max)
title = '                         Grayscale Start   (degrees; black end)'
xsize_cb = n_gray * 2
ysize_cb = 30
;
;	Initialize color table.
;
az_gray, 0.0
;
;	Set parent base.
;
base = widget_base(TITLE= "ASP Azimuth Viewer", /COLUMN)
;
;	Set child bases.
;
top = widget_base(base, /COLUMN)
upper = widget_base(base, /COLUMN)
lower = widget_base(base, /COLUMN)
bottom = widget_base(base, /COLUMN)
;
;-----------------------------
;
;	Set draw widget for image.
;
xsize_im = sizeof(image, 1)
ysize_im = sizeof(image, 2)
if keyword_set(big) then begin
	xsize_im = xsize_im * 2
	ysize_im = ysize_im * 2
endif
draw_im = widget_draw(top, xsize=xsize_im, ysize=ysize_im)
;
;	Set slider widget.
;
slide = widget_slider(upper, title=title, xsize=xsize_cb, maximum=max)
;
;	Set draw widget for colorbar.
;
draw_cb = widget_draw(lower, xsize=xsize_cb, ysize=ysize_cb)
;
;	Set menu widget.
;
menu = ['zoom', 'quit']
xmenu, menu, bottom, /row, xpad=100, space=150
;
;-----------------------------
;
;	Realize the widgets.
;
widget_control, /REALIZE, base
;
;	Draw the colorbar.
;
orig_w = !d.window		; save original window index
;
widget_control, get_value=index_cb, draw_cb
wset, index_cb
a = bytarr(xsize_cb, ysize_cb, /nozero)
row = bytscl(findgen(xsize_cb), top=n_gray) + n_special
for i = 0, ysize_cb-1 do a(*, i) = row
tv, a
;
;	Draw the image.
;
widget_control, get_value=index_im, draw_im
wset, index_im
if keyword_set(big) then begin
	tv, rebin(image, xsize_im, ysize_im, sample=1)
endif else begin
	tv, image
endelse
;
wset, orig_w			; restore original window index
;
;	Start the X manager.
;
xmanager, "az", base 
;
end

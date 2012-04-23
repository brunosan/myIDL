pro az_gray, cent
;+
;
;	procedure:  az_gray
;
;	purpose:  install colormap (grayscale + special values) for az_view.pro
;
;	author:  rob@ncar, 2/93
;
;	notes:  - have to scale image before hand based on *correct*
;		  # of avail colors
;
;		     assuming in X and a window has already been opened...
;		     using output from getiiii...
;			x = where(azm ge 0.)
;			y = where(azm lt 0.)
;			a = azm
;			a(x) = bytscl(a(x), top=!d.n_colors-3) + 3
;			a(y) = a(y) + 3
;			b = rebin(a, sizeof(a,1)*2, sizeof(a,2)*2, sample=1) 
;			[3 special indices in data already for contours
;			 and no-data regions]
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  az_gray, cent"
	print
	print, "	Install colormap for az_view.pro."
	print
	print, "		cent = 0.0 means black starts at 1st entry"
	print, "		cent = 1.0 means black starts at last entry"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Check parameter ranges.
;
if (cent lt 0.0) or (cent gt 1.0) then $
	message, 'cent must be between 0.0 and 1.0'
;
;	Get number of available colors.
;	(Must open X window so that !d.n_colors is set properly.)
;
old_device = !d.name			; save old device type
set_plot, 'x'				; change to X windows
window, /free, /pixmap, xs=1, ys=1	; open X pixmap
wdelete, !d.window			; remove the pixmap
n_colors = !d.n_colors			; get number of available colors
set_plot, old_device			; return to old device type
;
;	Allocate R,G,B arrays.
;	(Common block is for IDL color routines.)
;
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
r_curr = bytarr(n_colors, /nozero)
g_curr = r_curr
b_curr = r_curr
;
;	Fill special colors.
;
n_special = 3
n_gray = n_colors - n_special
r_curr(0) = 255				; contour:  yellow
g_curr(0) = 0
b_curr(0) = 0
r_curr(1) = 255				; contour:  red
g_curr(1) = 0
b_curr(1) = 0
r_curr(2) = 0				; no-data:  ~cyan
g_curr(2) = 150
b_curr(2) = 200
;
;	Fill grayscale.
;
ramp = bindgen(n_gray)
ixr = fixr(cent * (n_gray - 1))
ix = n_special + ixr
n = n_gray - ixr
r_curr(ix:*) = ramp(0:n-1)
g_curr(ix:*) = ramp(0:n-1)
b_curr(ix:*) = ramp(0:n-1)
if ixr gt 0 then begin
	r_curr(n_special:ix-1) = ramp(n:*)
	g_curr(n_special:ix-1) = ramp(n:*)
	b_curr(n_special:ix-1) = ramp(n:*)
endif
tvlct, r_curr, g_curr, b_curr
;
end

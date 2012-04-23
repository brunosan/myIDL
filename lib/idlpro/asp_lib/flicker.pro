pro flicker, a, b, rate=rate, scale=scale, big=big
;+
;
;	procedure:  flicker
;
;	purpose:  open new window and flicker between two images
;
;	author:  rob@ncar, 4/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  flicker, a, b"
	print
	print, "	Open new window and flicker between two images."
	print
	print, "	Arguments"
	print, "		a, b	- images (see 'scale' below)"
	print
	print, "	Keywords"
	print, "		rate	- flicker rate"
	print, "			  (def=1.0 sec/frame)"
	print, "		scale	- if set, scale a and b to bytes"
	print, "			  between 0 and 255 (def=assume"
	print, "			  already scaled)"
	print, "		big	- if set, double the image dimensions"
	print
	print, "   ex:  flicker, a, b, /big"
	print
	return
endif
;-
;
;	Set parameters.
;
true = 1
false = 0
xs = sizeof(a, 1)
ys = sizeof(a, 2)
do_big = false
if keyword_set(big) then do_big = true
if n_elements(rate) eq 0 then rate = 1.0
;
;	Create new window.
;
if do_big then begin
	xs = xs * 2
	ys = ys * 2
	a_use = rebin(a, xs, ys, sample=1)
	b_use = rebin(b, xs, ys, sample=1)
endif else begin
	a_use = a
	b_use = b
endelse
window, /free, xsize=xs, ysize=ys, title='flicker'
;
;	Print usage message.
;
print
print, 'Hit return to end "flicker" ...'
print
;
;	Optionally scale; do flicker.
;
if keyword_set(scale) then begin
	flick, bytscl(a_use), bytscl(b_use), rate
endif else begin
	flick, a_use, b_use, rate
endelse
;
;	Delete window and exit.
;
wdelete, !d.window
end

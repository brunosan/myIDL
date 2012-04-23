pro newwct, ctype, carg=carg, plot=plot, $
	back_col=back_col, cont1_col=cont1_col, cont2_col=cont2_col, $
	nd1_col=nd1_col, nd2_col=nd2_col, text_col=text_col, currw=currw
;+
;
;	procedure:  newwct
;
;	purpose:  install color map with part that 'wraps around'
;
;	author:  rob@ncar, 8/92
;
;	example:  @wrap.com			<-- define common block
;		  newwct, 1			<-- set color table
;		  ...
;		  tv, wrap_scale(arr1, 2), ...	<-- use tv, not tvscl !
;		  tv, wrap_scale(arr2, 3), ...
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  newwct, ctype"
	print
	print, "	Install color map with part that wraps around."
	print
	print, "	Arguments"
	print, "	    ctype	- colormap type"
	print, "		          1 = normal (rgb + grayscales)"
	print, "		          2 = grayscale and reverse only"
	print, "		          3 = red/blue + grayscales"
	print, "		          4 = bluescale only"
	print, "		          5 = 4-colors + grayscales"
	print, "		          6 = 6-colors + grayscales"
	print
	print, "	Keywords"
	print, '	    carg	- colormap argument (must be >= 1.0;"
	print, "		          rgb_sine_curve_width=#total/carg)"
	print, "		          (def = 1.1)"
	print, "	    plot	- if set, plot rgb curves"
	print, "		          (def = don't plot)"
	print, "	    currw	- if set, use current window"
	print, "		          for plot (def=open new window;"
	print, "		          this is relevant only if plot set)"
	print, "	    back_col	- color for background in X, or for"
	print, "		          text in PostScript"
	print, "		          (def = [0, 0, 0] = black)"
	print, "	    cont1_col	- color for first contours"
	print, "		          (def = [255, 255, 0] = yellow)"
	print, "	    cont2_col	- color for second contours"
	print, "		          (def = [0, 0, 0] = black)"
	print, "	    nd1_col	- color for no-data of color image"
	print, "		          (def = [0, 0, 0] = black)"
	print, "	    nd2_col	- color for no-data of gray image"
	print, "		          (def = [0, 0, 0] = white)"
	print, "	    text_col	- color for X windows text"
	print, "		          (def = [255, 255, 255] = white)"
	print
	return
endif
;-
;
;	Check 'ctype' variable.
;
if (ctype lt 1) or (ctype gt 6) then begin
	print
	print, 'Value "ctype" must be in range 1 to 6.'
	print
	return
endif
;
;	Check 'carg' variable.
;
if n_elements(carg) eq 0 then carg = 1.1
if (carg lt 1.0) then begin
	print
	print, 'Value "carg" must be >= 1.0'
	print
	return
endif
;
;	Specify common block.
;
@wrap.com
;
;	Pass ctype to wrap.set code via common.
;
ix_back = ctype
;
;	Set types, sizes, and initial values of common block variables.
;
@wrap.set
;
;	Create and zero R,G,B arrays.
;
r = bytarr(num_total)
g = bytarr(num_total)
b = bytarr(num_total)
;
;	Fill special entries.
;
if n_elements(back_col) eq 0 then begin
	r(ix_back) = 0				; background default = black
	g(ix_back) = 0
	b(ix_back) = 0
endif else begin
	r(ix_back) = back_col(0)
	g(ix_back) = back_col(1)
	b(ix_back) = back_col(2)
endelse
if n_elements(cont1_col) eq 0 then begin
	r(ix_cont1) = 255			; 1st contour default = yellow
	g(ix_cont1) = 255
	b(ix_cont1) = 0
endif else begin
	r(ix_cont1) = cont1_col(0)
	g(ix_cont1) = cont1_col(1)
	b(ix_cont1) = cont1_col(2)
endelse
if n_elements(cont2_col) eq 0 then begin
	r(ix_cont2) = 0				; 2nd contour default = black
	g(ix_cont2) = 0
	b(ix_cont2) = 0
endif else begin
	r(ix_cont2) = cont2_col(0)
	g(ix_cont2) = cont2_col(1)
	b(ix_cont2) = cont2_col(2)
endelse
if n_elements(nd1_col) eq 0 then begin
	r(ix_nodat) = 255			; nodata #1 default = black
	g(ix_nodat) = 255
	b(ix_nodat) = 255
endif else begin
	r(ix_nodat) = nd1_col(0)
	g(ix_nodat) = nd1_col(1)
	b(ix_nodat) = nd1_col(2)
endelse
if n_elements(nd2_col) eq 0 then begin
	r(ix_nodat2) = 255			; nodata #2 default = white
	g(ix_nodat2) = 255
	b(ix_nodat2) = 255
endif else begin
	r(ix_nodat2) = nd2_col(0)
	g(ix_nodat2) = nd2_col(1)
	b(ix_nodat2) = nd2_col(2)
endelse
if n_elements(text_col) eq 0 then begin
	r(ix_text) = 255			; text default = white
	g(ix_text) = 255
	b(ix_text) = 255
endif else begin
	r(ix_text) = text_col(0)
	g(ix_text) = text_col(1)
	b(ix_text) = text_col(2)
endelse
;
;	Fill grayscale.
;
ramp = bytscl( findgen(num_gray) )
ix = ix_gray + num_gray - 1
if ctype ne 4 then r(ix_gray:ix) = ramp
if ctype ne 4 then g(ix_gray:ix) = ramp
b(ix_gray:ix) = ramp				; note 'bluescale' (ctype=4)
;
;	Fill colorscale.
;
;	(Overlapping sine curves of R,G,B)
;
if ctype eq 1 then begin
	w_denom = float(carg)			; 2 => "~1/2 of total width"
	width = fixr(num_color / w_denom)	; fixr = rounding fix
	curv = (findgen(width) / (width - 1.0)) * !pi
	curv = bytscl(sin(curv))		; note max color value is 255
	rmid = fixr(num_color / 3.0)
	gmid = num_color - rmid
;
	ix = ix_color + num_color - 1
	insert_wrap, r, ix_color, ix, curv, rmid
	insert_wrap, g, ix_color, ix, curv, gmid
	insert_wrap, b, ix_color, ix, curv, ix_color
;
;	(Ramps of Red and Blue)
;
endif else if ctype eq 3 then begin
	tweek = 0
	ramplen = num_color - tweek
	ramp = bytscl( findgen(ramplen) )
	ix = ix_color + num_color - 1
	b(ix - ramplen + 1:ix) = ramp
;
	ramp = 255 - ramp
	ix = ix_color + ramplen - 1
	r(ix_color:ix) = ramp
;
;	(Overlapping sine curves of 4 colors.)
;
endif else if ctype eq 5 then begin
	w_denom = float(carg)			; 2 => "~1/2 of total width"
	width = fixr(num_color / w_denom)	; fixr = rounding fix
	curv = (findgen(width) / (width - 1.0)) * !pi
	curv = bytscl(sin(curv))		; note max color value is 255
	rmid = fixr(num_color * 3.0 / 8.0)
	bmid = fixr(num_color * 5.0 / 8.0)
	gmid = fixr(num_color * 7.0 / 8.0)
;
	ix = ix_color + num_color - 1
	insert_wrap, r, ix_color, ix, curv, rmid
	insert_wrap, g, ix_color, ix, curv, gmid
	insert_wrap, b, ix_color, ix, curv, bmid

	ymid = fixr(num_color * 1.0 / 8.0) ; yellow
	insert_wrapm, r, ix_color, ix, curv, ymid
	insert_wrapm, g, ix_color, ix, curv, ymid
;
;	(Overlapping sine curves of 6 colors.)
;
endif else if ctype eq 6 then begin
	w_denom = float(carg)			; 2 => "~1/2 of total width"
	width = fixr(num_color / w_denom)	; fixr = rounding fix
	curv = (findgen(width) / (width - 1.0)) * !pi
	curv = bytscl(sin(curv))		; note max color value is 255
	rmid = fixr(num_color / 3.0)
	gmid = num_color - rmid
;
	ix = ix_color + num_color - 1
	insert_wrap, r, ix_color, ix, curv, rmid
	insert_wrap, g, ix_color, ix, curv, gmid
	insert_wrap, b, ix_color, ix, curv, ix_color

	vmid = fixr(num_color / 6.0)	; magenta
	tmid = num_color - vmid		; cyan
	ymid = fixr(num_color / 2.0)	; yellow
	insert_wrapm, r, ix_color, ix, curv, vmid
	insert_wrapm, r, ix_color, ix, curv, ymid
	insert_wrapm, g, ix_color, ix, curv, ymid
	insert_wrapm, g, ix_color, ix, curv, tmid
	insert_wrapm, b, ix_color, ix, curv, tmid
	insert_wrapm, b, ix_color, ix, curv, vmid
endif
;
;	Install color table.
;
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
r_curr = r
g_curr = g		; set for IDL library color routines
b_curr = b
tvlct, r, g, b
;
;	Optionally display R,G,B settings.
;
if keyword_set(plot) then begin
;;	if not keyword_set(currw) then window, /free, title='rgb settings'
	fileps = 'idl.ps'
	print
	print, "Making PostScript file '" + stringit(fileps) + "' ..."
	print

rt = r_curr
g_t = g_curr
bt = b_curr
ix_r = 20
ix_g = 21
ix_b = 22
rt(ix_r) = 255	& g_t(ix_r) = 0	& bt(ix_r) = 0
rt(ix_g) = 0	& g_t(ix_g) = 255 & bt(ix_g) = 0
rt(ix_b) = 0	& g_t(ix_b) = 0	& bt(ix_b) = 255
rt(ix_text) = 0	& g_t(ix_text) = 0	& bt(ix_text) = 0
tvlct, rt, g_t, bt

	set_plot, 'ps'

	old_font = !p.font		; save old font info
	!p.font = 0			; select hardware font

;;	color = 0	& bits = 4
	color = 1	& bits = 8
	device, file=fileps, /landscape, /times, /bold, color=color, bits=bits

	title = 'Custom IDL Colormap'
	xtitle = 'Colormap Index'
	ytitle = 'Intensity'
	cs = 1.5
	thick = 2.0
	plot, r, title=title, xtitle=xtitle, ytitle=ytitle, charsize=cs, $
		thick=thick, xthick=thick, ythick=thick, color=ix_text, /nodata

	oplot, r(1:128), thick=thick*2, color=ix_r
	oplot, g(1:128), thick=thick*2, color=ix_g
	oplot, b(1:128), thick=thick*2, color=ix_b
r(0:128) = 0
g(0:128) = 0
b(0:128) = 0
	oplot, r, thick=thick*2, color=ix_text
	oplot, g, thick=thick*2, color=ix_text
	oplot, b, thick=thick*2, color=ix_text

;;	plot, r, color=ix_text, title=title, xtitle=xtitle, ytitle=ytitle
;;	oplot, g, color=ix_text
;;	oplot, b, color=ix_text

	!p.font = old_font		; restore font setting
	device, /close

	set_plot, 'x'
endif
;
;	Done.
;
end

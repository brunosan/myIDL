pro wrap_key2, xloc, yloc, rad1, rad2, kflag, type, $
	aratio=aratio, xwin=xwin, ixback=ixback
;+
;
;	procedure:  wrap_key2
;
;	purpose:  display an annulus key (180 or 360 degrees)
;
;	author:  rob@ncar, 2/93
;
;	notes:  - this is the new, fast version
;
;	ex1:  wrap_key2, 0, 0, 0.01, 0.02, 2, 4
;	ex2:  wrap_key2, 0, 0, 50, 100, 2, 4, /xwin
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 6 then begin
	print
	print, "usage:  wrap_key2, xloc, yloc, rad1, rad2, kflag, type"
	print
	print, "	Display an annulus key (NEW, FAST VERSION)."
	print
	print, "	Arguments"
	print, "	    xloc, yloc	- lower left corner in NDC"
	print, "		          for PostScript, pixels for X"
	print, "	    rad1, rad2	- inner and outer radii in"
	print, "		          X dimension NDC for PS,"
	print, "		          in pixels for X windows"
	print, "	    kflag	- key flag"
	print, "		            1 = 180 degree annulus"
	print, "		            2 = 360 degree annulus"
	print, "	    type	- see wrap_scale.pro 'type'"
	print
	print, "	Keywords"
	print, "	    aratio	- aspect ratio of PostScript"
	print, "		          output device (X/Y;"
	print, "		          def=11.0/8.5 <==Landscape)"
	print, "	    ixback	- index for PS background color"
	print, "		          (def=ix_text from wrap.com)"
	print, "	    xwin	- output to X window"
	print, "		          (def=output to PostScript)"
	print
	print
	print, "   ex:  wrap_key2, 0, 0, 200, 400, 2, 4, /xwin"
	print
	return
endif
;-
;
;	Specify common block.
;
@wrap.com
on_error, 2		; return to caller if error
;
;	Set parameters for specific colormap type.
;
case type of
  0: begin						; BLACK-AND-WHITE
	message, 'Type ' + stringit(type) + $
		' not currently supported.'
     end
  1: begin						; GRAYSCALE
	ix_col = ix_gray
	ncol = num_gray
	inc_col = 1
     end
  2: begin						; REVERSE GRAYSCALE
	ix_col = ix_gray + num_gray - 1
	ncol = num_gray
	inc_col = -1
     end
  3: begin						; COLORSCALE
	ix_col = ix_color2
	ncol = num_color2
	inc_col = 1
     end
  4: begin						; WRAPPED COLOR
	ix_col = ix_color
	ncol = num_color
	inc_col = 1
     end
  5: begin						; DISJOINT COLORSCALE
	message, 'Type ' + stringit(type) + $
		' not currently supported.'
     end
  else: begin						; ERROR
	  message, 'Incorrect type of ' + $
		stringit(type) + '.'
	end
endcase
;
;	Set some general parameters.
;
true = 1
false = 0
ncol1 = ncol - 1
do_ps = true
if keyword_set(xwin) then do_ps = false
if (kflag lt 1) or (kflag gt 2) then $
	message, 'kflag must be 1 (180 degrees) or 2 (360 degrees).'
if rad2 le rad1 then $
	message, 'rad2 must be > rad1.'
if (xloc lt 0.0) or (yloc lt 0.0) then $
	message, 'xloc and yloc must be ge 0.0.'
;
;	Set specific parameters for 180 vs. 360 degrees.
;
if kflag eq 1 then begin
	ndeg = 180.0		; number of degrees to put in key
	fdeg = 90.0		; first degree
	ldeg = -90.0		; last degree
endif else begin
	ndeg = 360.0
	fdeg = 0.0
	ldeg = 360.0
endelse
;
;	Set number of degrees per color.
;
ndeg_p_col = ndeg / ncol1
;
;	Set up specially for PostScript.
;	(Open a pixmap in memory to plot to.)
;
if do_ps then begin
	rad1_use = 50					; set pixmap radii
	rad2_use = 100
	xsize = rad2_use * kflag			; set pixmap sizes
	ysize = rad2_use * 2
	set_plot, 'x'					; change to X windows
	window, 0, xsize=xsize, ysize=ysize, /pixmap	; open pixmap
	if n_elements(ixback) eq 0 then ixback = ix_text
	erase, ixback					; set background color
endif else begin
	rad1_use = rad1
	rad2_use = rad2
endelse
;
;	Calculate vector of angles (radians) for boundaries of color cells.
;
if ldeg gt fdeg then sign = 1.0 else sign = -1.0
r = (fdeg + sign*(0.5*ndeg_p_col + findgen(ncol1)*ndeg_p_col)) * !dtor
;
;	Calculate cartesian corners of color cells.
;
x = [cos(fdeg*!dtor), cos(r), cos(ldeg*!dtor)]
y = [sin(fdeg*!dtor), sin(r), sin(ldeg*!dtor)]
;
x1 = x * rad1_use		; inner radius X  (180 deg)
x2 = x * rad2_use		; outer radius X  (180 deg)
if kflag eq 2 then begin
	x1 = x1 + rad2_use	; inner radius X  (360 deg)
	x2 = x2 + rad2_use	; outer radius X  (360 deg)
endif
;
y1 = y * rad1_use + rad2_use	; inner radius Y
y2 = y * rad2_use + rad2_use	; outer radius Y
;
;	Offset image for X windows output.
;
if not do_ps then begin
	if xloc gt 0.0 then begin
		x1 = x1 + xloc		& x2 = x2 + xloc
	endif
	if yloc gt 0.0 then begin
		y1 = y1 + yloc		& y2 = y2 + yloc
	endif
endif
;
;------------------------------------------------
;
;	LOOP FOR EACH COLOR CELL.
;
ix = 0
ixc = ix_col
;
for i = 0, ncol1 do begin
;
;	Color a cell.
	ix1 = ix + 1
	polyfill, [x1(ix), x2(ix), x2(ix1), x1(ix1)], $
		  [y1(ix), y2(ix), y2(ix1), y1(ix1)], $
		  color=ixc, /device
	ix = ix1
;
;	Increment color index.
	ixc = ixc + inc_col
endfor
;
;------------------------------------------------
;
;	Display annulus for PostScript output
;	(already displayed real-time for X windows).
;
if do_ps then begin
	ann = tvrd()			; read pixmap image
	set_plot, 'ps'			; return to PostScript mode
	xsize = rad2 * kflag		; set size in NDC units
	ysize = (rad2 * 2.0) * aratio
	tv, ann, xloc, yloc, xsize=xsize, ysize=ysize, /normal
endif
;
;	Label annulus.
;

;
;	Done.
;
end

pro plot_4, i, q, u, v,						$
	title=title, t2=t2, t3=t3,				$
	x1=x1, x2=x2, y1=y1, y2=y2,				$
	xs1=xs1, ys1=ys1, xs2=xs2, ys2=ys2, scale=scale,	$
	xscan=xscan, map=map, ps=ps, sps=sps, noqu=noqu,	$
	fileps=fileps, color=color, cfudge=cfudge, afile=afile
;+
;
;	procedure:  plot_4
;
;	purpose:  plot 4 images on one plot (e.g., I, Q, U, V)
;
;	author:  rob@ncar, 5/92
;
;	notes:	- see '~stokes/src/idl/pprun' for more examples of the
;		  PostScript (/ps) run
;		- the "simple PostScript run" (/sps) produces a non-fancy
;		  output, as does the X run
;
;   ex1:  readscan, 'map', 81, i81, q81, u81, v81, x2=240, y1=4
;	  plot_4, i81, q81, u81, v81, title='scan 81 test'
;	  plot_4, i81, q81, u81, v81, /sps, afile='map', fileps='81.ps'
;
;   ex2:  plot_4, i, q, u, v, ys1=2, ys2=220
;
;   ex3:  plot_4, i, q, u, v, /ps, afile='21.fa.map', map=map50, xscan=50
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  plot_4, i, q, u, v"
	print
	print, "	Plot 4 images on one plot."
	print
	print, "	Arguments"
	print, "	    i,q,u,v	- input arrays"
	print
	print, "	Keywords"
	print, "		title	- title of X11 window or PS page"
	print, "		          (def='plot_4')"
	print, "		x1,y1	- starting col,row indices (defs=0)"
	print, "		x2,y2	- ending col,row indices (defs=last)"
	print, "		xs1,xs2	- values outside this rectangle"
	print, "		ys1,ys2	  will be truncated to the min/max"
	print, "		          values inside the rectangle (done"
	print, "		          before scaling mentioned below in"
	print, "			  noqu and scale; defs=x1, y1, x2, y2)"
	print, "		noqu	- set to scale Q and U independently"
	print, "		          (def=scale Q and U together;"
	print, "			  unused if 'scale' set)"
	print, "		scale   - vector containing info for scaling"
	print, "			  I,Q,U,V, respectively, expressed as"
	print, "			  a fraction of maximum-I; e.g.,"
	print, "			  [1.0, .03, .03, .04] for symmetric"
	print, "			  scaling around 0 for Q,U,V; e.g.,"
	print, "			  [0,1, -.02,.04, -.02,.04, -.04,.04]"
	print, "			  for explicit control of min,max vals"
	print, "			  (def=straight scaling, using 'noqu'"
	print, "			  as set)"
	print
	print, "	PostScript-Output Keywords"
	print, "		ps	- if set, output to PostScript file"
	print, "		          (def=X Windows)"
	print, "		sps	- if set, output to PostScript file"
	print, "		          in simple fashion (no titles or shg;"
	print, "			  def=X Windows)"
	print, "		t2	- second title for PostScript plot"
	print, "			  (def=no second title)"
	print, "		t3	- third title for PostScript plot"
	print, "			  (def=no third title)"
	print, "		map	- input shg (array) for PS output"
	print, "			  (use shg.pro; no default for /ps)"
	print, "		fileps	- PostScript file (def=plot_4.ps)"
	print, "		xscan	- X index of scan within map for PS;"
	print, "			  if negative, make thick line"
	print, "			  (no default for /ps option)"
	print, "		color	- set for color PS output"
	print, "		          (def=black-and-white)"
	print, "		cfudge	- param. to tweak character sizes of"
	print, "		          PS run titles (larger cfudge gives"
	print, "		          smaller numbers; def=1.0)"
	print, "		afile	- ASP data file (used to get map step"
	print, "		          size for PostScript runs; no def)"
	print
	return
endif
;-
;
;	Set common blocks.
;
@op_hdr.com
@op_hdr.set
;
;	Set general parameters.
;
true = 1
false = 0
stdout_unit = -1
scalequ = not keyword_set(noqu)
if n_elements(title) eq 0 then title = 'plot_4'
;
;	Set X and Y ranges.
;
nx = sizeof(i, 1)	& nx1 = nx - 1
ny = sizeof(i, 2)	& ny1 = ny - 1
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = nx1
if n_elements(y2) eq 0 then y2 = ny1
if (x1 gt x2) or (y1 gt y2) or $
   (x1 lt 0) or (y1 lt 0) or $
   (x2 gt nx1) or (y2 gt ny1) then $
	message, "Error specifying 'x1,y1,x2,y2'."
;
;	Set scaling X and Y ranges.
;
if n_elements(xs1) eq 0 then xs1 = x1
if n_elements(ys1) eq 0 then ys1 = y1
if n_elements(xs2) eq 0 then xs2 = x2
if n_elements(ys2) eq 0 then ys2 = y2
if (xs1 lt x1) or (xs1 gt xs2) or (xs2 gt x2) $
   (ys1 lt y1) or (ys1 gt ys2) or (ys2 gt y2) then $
	message, "Error specifying 'xs1,ys1,xs2,ys2'."
do_trunc = false
if (xs1 ne x1) or (ys1 ne y1) or $
   (xs2 ne x2) or (ys2 ne y2) then do_trunc = true
xxs1 = xs1 - x1
xxs2 = xs2 - x1			; get relative range
yys1 = ys1 - y1
yys2 = ys2 - y1
;
;	Set PostScript- or X-specific parameters.
;
if keyword_set(sps) then begin			   ; Simple PostScript
	plot_ps = true
	plot_sps = true
	if not keyword_set(color) then color = 0
	if n_elements(fileps) eq 0 then $
		fileps = 'plot_4.ps'
	if n_elements(afile) eq 0 then $
		message, "Must specify 'afile'."
endif else if keyword_set(ps) then begin	   ; Regular PostScript
	plot_ps = true
	plot_sps = false
	if not keyword_set(color) then color = 0
	if n_elements(fileps) eq 0 then $
		fileps = 'plot_4.ps'
	if n_elements(t2) eq 0 then t2 = ''
	if n_elements(t3) eq 0 then t3 = ''
	if n_elements(cfudge) eq 0 then cfudge = 1.0
	if n_elements(xscan) eq 0 then $
		message, "Error specifying 'xscan'."
	xscan_use = abs(xscan)
	if n_elements(map) eq 0 then $
		message, "Error specifying 'map'."
	if n_elements(afile) eq 0 then $
		message, "Must specify 'afile'."
endif else begin				   ; X11
	plot_ps = false
	plot_sps = false
endelse
;
;	Get subsets of the arrays.
;
ii = i(x1:x2, y1:y2)
qq = q(x1:x2, y1:y2)
uu = u(x1:x2, y1:y2)
vv = v(x1:x2, y1:y2)
;
;	Truncate values outside scale range to the max/min of the range.
;
if do_trunc then asp_trunc, ii, qq, uu, vv, xxs1, yys1, xxs2, yys2
;
;	Set ranges and scale images.
;
if n_elements(scale) ne 0 then begin		; -- use 'scale' keyword --
;
    if n_elements(scale) eq 4 then begin
	max_i = max(ii, min=min_i)
	max_q = scale(1)*max_i 	& min_q = -max_q
	max_u = scale(2)*max_i 	& min_u = -max_u
	max_v = scale(3)*max_i 	& min_v = -max_v
	qq = bytscl(qq, max=max_q, min=min_q)
	uu = bytscl(uu, max=max_u, min=min_u)
	vv = bytscl(vv, max=max_v, min=min_v)
;
	max_i = scale(0)*max_i
	ii = bytscl(ii, max=max_i)
;
    endif else if n_elements(scale) eq 8 then begin
	max_i = max(ii)
	min_q = scale(2)*max_i   & max_q = scale(3)*max_i
	min_u = scale(4)*max_i   & max_u = scale(5)*max_i
	min_v = scale(6)*max_i   & max_v = scale(7)*max_i
	qq = bytscl(qq, max=max_q, min=min_q)
	uu = bytscl(uu, max=max_u, min=min_u)
	vv = bytscl(vv, max=max_v, min=min_v)
;
	min_i = scale(0)*max_i   & max_i = scale(1)*max_i
	ii = bytscl(ii, max=max_i, min=min_i)
;
    endif else message, "'scale' must contain 4 or 8 elements"
;
endif else begin				; -- NO 'scale' keyword  --
	max_i = max(ii, min=min_i)
	max_v = max(vv, min=min_v)
	ii = bytscl(ii)
	vv = bytscl(vv)
;
	if scalequ then begin		    	; (scale Q and U together)
		max_q = max([qq, uu], min=min_q)
		max_u = max_q	& min_u = min_q
		qq = bytscl(qq, min=min_q, max=max_q)
		uu = bytscl(uu, min=min_u, max=max_u)
	endif else begin		    	; (scale Q and U independently)
		max_q = max(qq, min=min_q)
		max_u = max(uu, min=min_u)
		qq = bytscl(qq)
		uu = bytscl(uu)
	endelse
endelse

;;
;;	Scale the image to fit the available colormap range.
;;	(The '> 1.0' is there to handle zero'ed images.)
;;
;;n_use = newct.n_colors - newct.n_special
;;if n_elements(srange) eq 0 then begin
;;	minv = min(im, max=maxv)
;;	image = byte( (n_use - 1.0) * (im - minv) $
;;			/ (float(maxv - minv) > 1.0) )
;;endif else begin
;;	minv = srange(0)
;;	maxv = srange(1)
;;	image = byte( (n_use - 1.0) * ((minv > im < maxv) - minv) $
;;			/ (float(maxv - minv) > 1.0) )
;;endelse

;
;
;------------------------------------------------------------
;	 PostScript Output
;------------------------------------------------------------
;
if plot_ps then begin
;
;	Set device information.
	old_font = !p.font	; save old font info
	!p.font = 0		; select hardware font
	charsize = 1.8
	charsize_md = 1.5
	charsize_sm = 1.0
	set_plot, 'ps'
	xlen_dev = 8.5		; dimensions of entire plot in inches
	ylen_dev = 10.5
	device, bits_per_pixel=8, file=fileps, scale_factor=1.0, /inches, $
		xoffset=0.0, yoffset=0.25, xsize=xlen_dev, ysize=ylen_dev, $
		/helvetica, /bold, color=color
	xlen = 0.40		; dimensions of I,Q,U,V in NDC
	ylen = 0.27
;
;	Read operation header to get map step size.
	openr, unit, afile, /get_lun
	if read_op_hdr(unit, stdout_unit, false) eq 1 then return
	free_lun, unit
;
;	Set dimensions of map in NDC with correct aspect ratio.
	ylen_map = ylen		; make map the same height as I,Q,U,V
	y_pixel_d = 0.370	; distance in asec between pixels along slit
	ratio0 = mstepsz / y_pixel_d		    ; ratio of asec
	ratio1 = ylen_dev / xlen_dev		    ; ratio of PS output
	ratio2 = float(sizeof(map,1)) / $
		 float(sizeof(map,2))		    ; ratio of input
	xlen_map = ylen_map * ratio0*ratio1*ratio2  ; use aspect ratios
;
;	Set various positioning parameters.
	xlen_border = (1.0 - 2*xlen) / 3.0
	ylen_border = (1.0 - 2*ylen - ylen_map) / 4.0
	x_map = 1.0 - xlen_border - xlen_map
	y_map = 1.0 - ylen_border - ylen_map
;
	x_u = xlen_border
	x_v = x_u + xlen + xlen_border
	x_i = x_u	& x_q = x_v
;
	y_u = ylen_border
	y_i = y_u + ylen + ylen_border
	y_q = y_i	& y_v = y_u
;
	label_x = 0.01
	label_y = 0.028
	x_iu_label = x_i + label_x	& x_qv_label = x_q + label_x
	y_iq_label = y_i - label_y	& y_uv_label = y_u - label_y
;
;	Plot map.
	if not plot_sps then begin
		m = bytscl(map)
		m(xscan_use,*) = 255
		if xscan lt 0 then begin	; (thicken line)
			nxx = sizeof(m, 1) - 1
			if xscan_use ge 1   then m(xscan_use-1,*) = 255
			if xscan_use lt nxx then m(xscan_use+1,*) = 255
		endif
		tv, m, x_map, y_map, xsize=xlen_map, ysize=ylen_map, /normal
	endif
;
;	Plot colorbar.
	if not plot_sps then begin
		ndig = 4
		xct = x_i
		yct = y_i + ylen + ylen_border
		xlen_ct = 1.0 - xlen_map - 3*xlen_border
		ylen_ct = 0.05
		x1_ctlabel = x_i
		x2_ctlabel = x_i + xlen_ct - 0.07
		y_ctlabel = 0.02
		yv_ctlabel = yct + ylen_ct + 0.01
		yu_ctlabel = yv_ctlabel + y_ctlabel
		yq_ctlabel = yu_ctlabel + y_ctlabel
		yi_ctlabel = yq_ctlabel + y_ctlabel

		displayctn, 0, 255, xct, yct, xlen_ct, ylen_ct
		xyouts, x1_ctlabel, yi_ctlabel, 'I (raw #): ' + $
			float_str(min_i, 1), /normal, charsize=charsize_sm
		xyouts, x1_ctlabel, yq_ctlabel, 'Q (# / Imax): ' + $
			float_str(min_q/max_i, ndig), /normal, $
			charsize=charsize_sm
		xyouts, x1_ctlabel, yu_ctlabel, 'U (# / Imax): ' + $
			float_str(min_u/max_i, ndig), /normal, $
			charsize=charsize_sm
		xyouts, x1_ctlabel, yv_ctlabel, 'V (# / Imax): ' + $
			float_str(min_v/max_i, ndig), /normal, $
			charsize=charsize_sm
;
		xyouts, x2_ctlabel, yi_ctlabel, float_str(max_i, 1), $
			/normal, charsize=charsize_sm
		xyouts, x2_ctlabel, yq_ctlabel, float_str(max_q/max_i, ndig), $
			/normal, charsize=charsize_sm
		xyouts, x2_ctlabel, yu_ctlabel, float_str(max_u/max_i, ndig), $
			/normal, charsize=charsize_sm
		xyouts, x2_ctlabel, yv_ctlabel, float_str(max_v/max_i, ndig), $
			/normal, charsize=charsize_sm
	endif
;
;	Plot images.
	xyouts, x_iu_label, y_iq_label, 'I', /normal, charsize=charsize
	xyouts, x_qv_label, y_iq_label, 'Q', /normal, charsize=charsize
	xyouts, x_iu_label, y_uv_label, 'U', /normal, charsize=charsize
	xyouts, x_qv_label, y_uv_label, 'V', /normal, charsize=charsize
	tv, ii, x_i, y_i, xsize=xlen, ysize=ylen, /normal
	tv, qq, x_q, y_q, xsize=xlen, ysize=ylen, /normal
	tv, uu, x_u, y_u, xsize=xlen, ysize=ylen, /normal
	tv, vv, x_v, y_v, xsize=xlen, ysize=ylen, /normal
;
;	Plot titles.
	if not plot_sps then begin
		x_title = xct + 0.5 * xlen_ct + 0.01
		y_t = 0.04
		y_t1 = y_map + ylen_map - .025
		y_t2 = y_t1 - y_t
		y_t3 = y_t2 - y_t
		xyouts, x_title, y_t1, title, /normal, align=0.5, $
			charsize=charsize/cfudge
		xyouts, x_title, y_t2, t2, /normal, align=0.5, $
			charsize=charsize_md/cfudge
		xyouts, x_title, y_t3, t3, /normal, align=0.5, $
			charsize=charsize_md/cfudge
	endif
;
;	Close PS device and restore X Windows.
	print, '	Plot to file ' + stringit(fileps), format='(/A/)'
	device, /close_file
	set_plot, 'x'
	!p.font = old_font	; restore font setting
;
;
;------------------------------------------------------------
;	 X Windows Output
;------------------------------------------------------------
;
endif else begin
;
;	Set various positioning parameters and open window.
	xlen = x2 - x1 + 1
	ylen = y2 - y1 + 1
	border_width = 20
	x_i = 0
	x_q = xlen + border_width
	x_u = x_i
	x_v = x_q
	y_i = ylen + border_width
	y_q = y_i
	y_u = 0
	y_v = y_u
	xsize = xlen * 2 + border_width
	ysize = ylen * 2 + border_width
	window, /free, xsize=xsize, ysize=ysize, title=title
;
;	Plot images.
	tv, ii, x_i, y_i
	tv, qq, x_q, y_q
	tv, uu, x_u, y_u
	tv, vv, x_v, y_v
;
endelse
;
end

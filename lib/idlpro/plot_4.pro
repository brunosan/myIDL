pro plot_4, i, q, u, v,						$
	title=title, t2=t2, t3=t3,				$
	x1=x1, x2=x2, y1=y1, y2=y2,				$
	xs1=xs1, ys1=ys1, xs2=xs2, ys2=ys2,			$
	i_scl=i_scl, q_scl=q_scl, u_scl=u_scl, v_scl=v_scl,	$
	xscan=xscan, map=map, ps=ps, sps=sps, noqu=noqu,	$
	fileps=fileps, color=color, cfudge=cfudge, afile=afile,ind=ind
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
;   ex4:   plot_4,imi,imq,imu,imv,ind=44,fileps='tip4.ps',/sps (Este es mio)
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
	print, "		xs1,xs2	- indices used for scaling;"
	print, "		ys1,ys2	  values outside this rectangle"
	print, "		          will be truncated to the max/min"
	print, "		          values inside the rectangle"
	print, "		          (defs=x1, y1, x2, y2)"
	print, "		noqu	- set to scale Q and U independently"
	print, "		          (def=scale Q and U together)"
	print, "		i_scl,	- data value ranges at which to scale"
	print, "		q_scl,	  I, Q, U, and V, respectively"
	print, "		u_scl,	  (defs=[min, max] of the data"
	print, "		v_scl	   inside points xs1,ys1 to xs2,ys2)"
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
	print, "		map	- shg (map) for PostScript output"
	print, "			  (no default for /ps option)"
	print, "		fileps	- PostScript file (def=plot_4.ps)"
	print, "		xscan	- X index of scan within map for PS"
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
if n_elements(ind) eq 0 then ind = -1
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
;	if n_elements(afile) eq 0 then $
;		message, "Must specify 'afile'."
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
iii = i(x1:x2, y1:y2)
iqq = q(x1:x2, y1:y2)
iuu = u(x1:x2, y1:y2)
ivv = v(x1:x2, y1:y2)
;
;	Truncate values outside scale range to the max/min of the range.
;
if do_trunc then asp_trunc, ii, qq, uu, vv, xxs1, yys1, xxs2, yys2
;
;	Set ranges and scale images.
;
max_i = max(ii, min=min_i)
max_v = max([qq,uu,vv], min=min_v)
val = max_v
;ffudge = 500
;vv= -val > v < (val - ffudge)
ii = bytscl(ii,min=min_i/1.2,max=max_i*1.0)
vv = bytscl(vv,min=min_v/2.5,max=max_v/2.5)
;
if scalequ then begin		    	; scale Q and U together
	qu = [qq, uu]
	qu = bytscl(qu)
	x_len = sizeof(qq, 1)
	x_end = x_len + x_len - 1
	qq = qu(0:x_len-1, *)
	uu = qu(x_len:x_end, *)
	max_q = max(qu, min=min_q)
	max_u = max_q & min_u = min_q
endif else begin		    	; scale Q and U independently
;	max_q = max(qq, min=min_q)
;	max_u = max(uu, min=min_u)
;	max_u=1.4*max_q
;	min_u=min_q
;	print,max_q,min_q
;	qq = bytscl(qq,min=min_q,max=max_q)
;	uu = bytscl(uu,min=min_u,max=max_u)
	max_q = max([qq,uu,vv], min=min_q)
	max_u = max([qq,uu,vv], min=min_u)
;	val = max_q
;	ffudge = 0  ;100
;	qq= -val > q < (val - ffudge)
;	uu= -val > u < (val - ffudge)
	qq = bytscl(qq,min=min_v,max=max_v)
	uu = bytscl(uu,min=min_v/2.5,max=max_v/2.5)
endelse
 
ii(128:150,ind)=byte(255)
qq(128:150,ind)=byte(255)
uu(128:150,ind)=byte(255)
vv(128:150,ind)=byte(255)
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
;	openr, unit, afile, /get_lun
;	if read_op_hdr(unit, stdout_unit, false) eq 1 then return
;	free_lun, unit
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
	arrow='!M'+string("256B)+'!X'
	if not plot_sps then begin
		m = bytscl(map)
		tv, m, x_map, y_map, xsize=xlen_map, ysize=ylen_map, /normal
		xyouts,x_map+.348,y_map+.146,arrow,charthick=4, $
		charsize=2,/normal,orientation=270+45
		xyouts,x_map+.400,y_map+.090,arrow,charthick=4, $
		charsize=2,/normal,orientation=180-45
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
		x2_ctlabel = x_i + xlen_ct - 0.06
;		y_ctlabel = 0.02
		y_ctlabel = 0.03
;		yv_ctlabel = yct + ylen_ct + 0.01
		yv_ctlabel = yct + ylen_ct - 0.03
		yu_ctlabel = yv_ctlabel + y_ctlabel
		yq_ctlabel = yu_ctlabel + y_ctlabel
		yi_ctlabel = yq_ctlabel + y_ctlabel
		yl_ctlabel = yi_ctlabel + y_ctlabel
		max_in = max(iii, min=min_in)
		max_qn = max(iqq, min=min_qn)
		max_un = max(iuu, min=min_un)
		max_vn = max(ivv, min=min_vn)
		print,max_in,min_in
;		displayctn, 0, 255, xct, yct, xlen_ct, ylen_ct
		xyouts, x1_ctlabel, yl_ctlabel,'!16  min!X',$
			/normal, charsize=charsize_sm
		xyouts, x1_ctlabel, yi_ctlabel,' '+float_str(min_in, 0) + $
			'                !16 I!X (ADU)',/normal,  $
			charsize=charsize_sm
		xyouts, x1_ctlabel, yq_ctlabel, $
			float_str(min_qn/max_in, ndig) +  $
			'          !16   Q/Imax!X', /normal, $
			charsize=charsize_sm
		xyouts, x1_ctlabel, yu_ctlabel, $
			float_str(min_un/max_in, ndig) +  $
			'          !16   U/Imax!X', /normal, $
			charsize=charsize_sm
		xyouts, x1_ctlabel, yv_ctlabel, $
			float_str(min_vn/max_in, ndig) +  $
			'          !16   V/Imax!X', /normal, $
			charsize=charsize_sm
		print,max_in,min_in
;
	        print,float_str(max_in, 0) 	
		xyouts, x2_ctlabel, yl_ctlabel, '!16  max!X', $
			/normal, charsize=charsize_sm
		xyouts, x2_ctlabel, yi_ctlabel, ' '+float_str(max_in, 0), $
			/normal, charsize=charsize_sm
		xyouts, x2_ctlabel, yq_ctlabel, $
			float_str(max_qn/max_in, ndig), $
			/normal, charsize=charsize_sm
		xyouts, x2_ctlabel, yu_ctlabel, $
			float_str(max_un/max_in, ndig), $
			/normal, charsize=charsize_sm
		xyouts, x2_ctlabel, yv_ctlabel, $
			float_str(max_vn/max_in, ndig), $
			/normal, charsize=charsize_sm
	endif
;
;	Plot images.
        xx1=0	; limites del plot para TIP y normalizacion
	xx2=255
        norm=22000.
;       xx1=100	; limites del plot para LPSP y normalizacion
;	xx2=200
;	norm=18000.
        if(ind ge 0) then begin
	   plot,i(xx1:xx2,ind)/norm,$
	     position=[x_iu_label+0.1*xlen,3.3*ylen,$
	        x_iu_label+0.9*xlen,4.3*ylen],$
	        /ynoz,thick=3,ytit='!16I/I!s!uph!r!dc!n!X',xtit='!16px!X',$
                yticks=4,yrange=[0.6,1.0],/ysty,charsize=1.3
	   plot,q(xx1:xx2,ind)/norm,$
	      position=[x_qv_label+0.1*xlen,3.3*ylen,$
	         x_qv_label+0.9*xlen,4.3*ylen],$
;	     /ynoz,$
	     thick=3,ytit='!16Q/I!s!uph!r!dc!n!X',xtit='!16px!X',yticks=4,$
	     /noerase,yrange=[-0.01,0.01],/ysty,charsize=1.3
	   plot,u(xx1:xx2,ind)/norm,$
	     position=[x_iu_label+0.1*xlen,2.7*ylen,$
	        x_iu_label+0.9*xlen,3.1*ylen],$
;	     /ynoz,$
	     thick=3,ytit='!16U/I!s!uph!r!dc!n!X',xtit='!16px!X',yticks=4,$
	     /noerase,yrange=[-0.01,0.01],/ysty,charsize=1.3
	   plot,v(xx1:xx2,ind)/norm,$
	      position=[x_qv_label+0.1*xlen,2.7*ylen,$
	         x_qv_label+0.9*xlen,3.1*ylen],$
;	     /ynoz,$
	     thick=3,ytit='!16V/I!s!uph!r!dc!n!X',xtit='!16px!X',$
;	     /ysty,$
	     yticks=4,/noerase,yrange=[-0.01,0.01],/ysty,charsize=1.3
	endif   
	xyouts, x_iu_label, y_iq_label, '!16I!X', /normal, charsize=charsize
	xyouts, x_qv_label, y_iq_label, '!16Q!X', /normal, charsize=charsize
	xyouts, x_iu_label, y_uv_label, '!16U!X', /normal, charsize=charsize
	xyouts, x_qv_label, y_uv_label, '!16V!X', /normal, charsize=charsize
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
!p.multi=0
;
end


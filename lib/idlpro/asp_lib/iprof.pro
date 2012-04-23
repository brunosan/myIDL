pro iprof, infiles, points=points, ps=ps, fileps=fileps, landscape=landscape
;+
;
;	procedure:  iprof
;
;	purpose:  display I,Q,U,V profiles given *.pf files output from
;		  the Stokes inversion code
;
;	author:  rob@ncar, 12/93
;
;	ex:  iprof, ['12.67b.pf', '12.75u.pf', '12.81r.pf']
;
;	notes:  - only PostScript mode currently supported
;		- code to skip to specific point needs to be added
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  iprof, infiles"
	print
	print, "	Display I,Q,U,V profiles given *.pf files output from"
	print, "	the Stokes inversion code."
	print
	print, "	Arguments"
	print, "		infiles	- input name(s) of *.pf files"
	print, "			  (a string or array of strings)"
	print
	print, "	Keywords"
	print, "		points	- X,Y points to obtain from each"
	print, "			  infile (def=use 2nd point in file)"
	print
;;	print, "		ps	- set to output to PostScript file"
;;	print, "			  (def=output to X Windows)"
	print, "		fileps	- PostScript file (def='iprof.ps')"
;;	print, "		land	- set to output to landscape mode"
;;	print, "			  (def=portrait)"
	print
	print
	print, "   ex:  iprof,      ['14.pf',  '15.pf'], $"
	print, "             points=[[69,105], [85,79]]"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Set general parameters.
;
true = 1
false = 0
skip = ''
tiny = 0.00001
do_ps = keyword_set(ps)
do_land = keyword_set(land)
do_port = 1 - do_land
if n_elements(fileps) eq 0 then fileps = 'iprof.ps'

line = {point, loc:0, i_obs:0.0, q_obs:0.0, u_obs:0.0, v_obs:0.0, $
	       i_calc:0.0, i_imag:0.0, q_calc:0.0, u_calc:0.0, v_calc:0.0, $
	       band:0}
iquv = replicate({point}, 256)
;
;	Check input files/points.
;
n_prof = n_elements(infiles)
n_prof1 = n_prof - 1
n_points = n_elements(points)
do_points = true
if (n_points eq 0) then begin
	do_points = false
endif else if (n_points ne 2*n_prof) then begin
	message, "'points' must contain one '[X, Y]' per each input file"
endif else if (n_prof gt 1) then begin
	if (sizeof(points, 0) ne 2) then message, $
		"'points' must contain one '[X, Y]' per each input file"
	if (sizeof(points, 1) ne 2) then message, $
		"'points' must contain one '[X, Y]' per each input file"
endif
;
;	Define dot symbol for plotting observed values.
;
a = findgen(16) * (!pi * 2.0/16.0)
fact = 0.25
usersym, fact*cos(a), fact*sin(a), /fill
psym_obs = 8


;
;	Set plotting variables.
;

; (set these)

center1 = 43			; from model file
center2 = 121
dispersion = 12.59
half_width = 400.0
range = half_width/dispersion	; (pixels in half of "half-plot")
xticks = 4
xtickname = [' ', '-.02', '0', '.02', ' ']
yl_off = 0.010			; offset for vertical line

if do_land then begin
	xlen_dev = 11.0
	ylen_dev = 8.5		; --- LANDSCAPE MODE ---
	xoffset  = 0.0
	yoffset  = 11.0

	; (tweak these)

	ticklen = 0.03		; axis ticklength (0.02 is normal)
	xlen = 0.18		; width of a plot in NDC

	x_border_r = 0.60	; fraction of (left + right borders) left gets
	y_border_r = 0.60	; fraction of (top + bottom borders) top gets

	x_border2 = 0.045	; X border between I & Q (and U & V) in NDC
	x_border3 = 0.010	; X border between Q & U (and other) in NDC

	x_lab_off = 0.01	; offset from l.l. corner to I|Q|U|V label

	csize = 0.8		; overall character size (1.0 = normal)
	thick = 3.0		; curve thickness (1.0 = normal)
	thick_axis = 3.0	; X,Y axis thickness

	csize_lab  = 1.0	; I|Q|U|V label character size (1.0 = normal)

	ls_calc = 0		; line style of calculated profile
	ls_imag = 0		; line style of image profile

endif else begin
	xlen_dev = 8.5
	ylen_dev = 11.0		; --- PORTRAIT MODE ---
	xoffset  = 0.0
	yoffset  = 0.0

	; (tweak these)

	ticklen = 0.03		; axis ticklength (0.02 is normal)

	xlen = 0.18		; width of a plot in NDC

	x_border_r = 0.60	; fraction of (left + right borders) left gets
	y_border_r = 0.60	; fraction of (top + bottom borders) top gets

	x_border2 = 0.050	; X border between I & Q (and U & V) in NDC
	x_border3 = 0.015	; X border between Q & U (and other) in NDC

	x_lab_off = 0.01	; offset from l.l. corner to I|Q|U|V label

	csize = 0.8		; overall character size (1.0 = normal)
	thick = 3.0		; curve thickness (1.0 = normal)
	thick_axis = 3.0	; X,Y axis thickness

	csize_lab  = 1.0	; I|Q|U|V label character size (1.0 = normal)

	ls_calc = 0		; line style of calculated profile
	ls_imag = 0		; line style of image profile
endelse

nval_half = range*2 + 1		; num values in a "half-plot"
xvals = (findgen(nval_half) - range) * half_width / 10000.0

xlen_half = 0.5 * xlen

xlen_qtr = 0.25 * xlen

ratio = xlen_dev / ylen_dev

x_left = 1.0 - 4.0*xlen - 2*x_border2 - x_border3
x_border1 = x_border_r * x_left

ylen = xlen * ratio		; height of a plot in NDC
y_border2 = x_border3 * ratio
y_left = 1.0 - n_prof*ylen - (n_prof1)*y_border2
y_border1 = y_border_r * y_left
y_border3 = (1.0 - y_border_r) * y_left
y_lab_off = x_lab_off * ratio

ll_ix = x_border1			; set lower-left-corner X,Y values
ll_qx = ll_ix + xlen + x_border2
ll_ux = ll_qx + xlen + x_border3
ll_vx = ll_ux + xlen + x_border2	; note lower-left Y's go top down
ll_y = reverse(findgen(n_prof))*(ylen+y_border2) + y_border3

;
;	Set device information.
;
old_font = !p.font	; save old font info
!p.font = 0		; select hardware font

set_plot, 'ps'

if do_land then begin
	device, bits_per_pixel=8, file=fileps, scale_factor=1.0, /inches, $
		xoffset=xoffset, yoffset=yoffset, $
		xsize=xlen_dev, ysize=ylen_dev, $
		/times, /bold, /landscape
endif else begin
	device, bits_per_pixel=8, file=fileps, scale_factor=1.0, /inches, $
		xoffset=xoffset, yoffset=yoffset, $
		xsize=xlen_dev, ysize=ylen_dev, $
		/times, /bold, /portrait
endelse
;
;----------------------------------------------------------------
;
;	LOOP FOR EACH INPUT FILE
;
for iprof = 0, n_prof1 do begin

;	Set input file name.
	infile = infiles(iprof)

;	Open input file.
	openr, in_unit, infile, /get_lun

;	Skip scattered light profile.
	for i=1,256+4 do readf, in_unit, skip

;	Read first regular profile.
	readf, in_unit, iquv

;	Scale for plotting.
	max_i = max(iquv(*).i_obs)
	i_obs1 = iquv(center1-range:center1+range).i_obs   / max_i
	i_obs2 = iquv(center2-range:center2+range).i_obs   / max_i
	i_calc1 = iquv(center1-range:center1+range).i_calc / max_i
	i_calc2 = iquv(center2-range:center2+range).i_calc / max_i
	i_imag1 = iquv(center1-range:center1+range).i_imag / max_i
	i_imag2 = iquv(center2-range:center2+range).i_imag / max_i

	q_obs1 = iquv(center1-range:center1+range).q_obs   / max_i
	q_obs2 = iquv(center2-range:center2+range).q_obs   / max_i
	q_calc1 = iquv(center1-range:center1+range).q_calc / max_i
	q_calc2 = iquv(center2-range:center2+range).q_calc / max_i

	u_obs1 = iquv(center1-range:center1+range).u_obs   / max_i
	u_obs2 = iquv(center2-range:center2+range).u_obs   / max_i
	u_calc1 = iquv(center1-range:center1+range).u_calc / max_i
	u_calc2 = iquv(center2-range:center2+range).u_calc / max_i

	v_obs1 = iquv(center1-range:center1+range).v_obs   / max_i
	v_obs2 = iquv(center2-range:center2+range).v_obs   / max_i
	v_calc1 = iquv(center1-range:center1+range).v_calc / max_i
	v_calc2 = iquv(center2-range:center2+range).v_calc / max_i

;	Get Y range for Q and U.
	min_qu = min([q_obs1, q_calc1, q_obs2, q_calc2, $
		      u_obs1, u_calc1, u_obs2, u_calc2], $
		     max=max_qu) 
	yrange_qu = [min_qu, max_qu]

;	Get Y locations for the row of I,Q,U,V profiles.
	y1 = ll_y(iprof)
	y2 = y1 + ylen
	y_lab = y1 + y_lab_off

;	Plot profiles.
	if iprof eq n_prof1 then begin		; BOTTOM ROW

		pos = [ll_ix, y1, ll_ix+xlen_half, y2]
		plot, xvals, i_obs1, /noerase, /normal, ystyle=8, $
			pos=pos, /xstyle, charsize=csize, $
			thick=thick, xthick=thick_axis, ythick=thick_axis, $
			ticklen=ticklen, psym=psym_obs, xticks=xticks, $
			xtickname=xtickname
		oplot, xvals, i_calc1, lines=ls_calc
		oplot, xvals, i_imag1, lines=ls_imag
		xyouts, ll_ix+x_lab_off, y_lab, '!8I!X', /normal, $
			charsize=csize_lab
		x = ll_ix + xlen_qtr
		plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	    pos = [ll_ix+xlen_half, y1, ll_ix+xlen, y2]
	    plot, xvals, i_obs2, /noerase, /normal, ystyle=0, $
		    pos=pos, /xstyle, charsize=csize, ycharsize=tiny, $
		    thick=thick, xthick=thick_axis, ythick=thick_axis, $
		    ticklen=ticklen, psym=psym_obs, xticks=xticks, $
		    xtickname=xtickname
	    oplot, xvals, i_calc2, lines=ls_calc
	    oplot, xvals, i_imag2, lines=ls_imag
	    xyouts, ll_ix+x_lab_off, y_lab, '!8I!X', /normal, $
		    charsize=csize_lab
	    x = ll_ix + xlen_half + xlen_qtr
	    plots, [x, x], [y1+yl_off, y2-yl_off], /normal

		pos = [ll_qx, y1, ll_qx+xlen_half, y2]
		plot, xvals, q_obs1, /noerase, /normal, ystyle=8, $
			pos=pos, /xstyle, charsize=csize, xticks=xticks, $
			thick=thick, xthick=thick_axis, ythick=thick_axis, $
			yrange=yrange_qu, ticklen=ticklen, psym=psym_obs, $
			xtickname=xtickname
		oplot, xvals, q_calc1, lines=ls_calc
		xyouts, ll_qx+x_lab_off, y_lab, '!8Q!X', /normal, $
			charsize=csize_lab
		x = ll_qx + xlen_qtr
		plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	    pos = [ll_qx+xlen_half, y1, ll_qx+xlen, y2]
	    plot, xvals, q_obs2, /noerase, /normal, ystyle=0, xticks=xticks, $
		    pos=pos, /xstyle, charsize=csize, ycharsize=tiny, $
		    thick=thick, xthick=thick_axis, ythick=thick_axis, $
		    yrange=yrange_qu, ticklen=ticklen, psym=psym_obs, $
		    xtickname=xtickname
	    oplot, xvals, q_calc2, lines=ls_calc
	    xyouts, ll_qx+x_lab_off, y_lab, '!8Q!X', /normal, $
		    charsize=csize_lab
	    x = ll_qx + xlen_half + xlen_qtr
	    plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	
		pos = [ll_ux, y1, ll_ux+xlen_half, y2]
		plot, xvals, u_obs1, /noerase, /normal, ystyle=8, $
			xticks=xticks, $
			pos=pos, /xstyle, charsize=csize, ycharsize=tiny, $
			thick=thick, xthick=thick_axis, ythick=thick_axis, $
			yrange=yrange_qu, ticklen=ticklen, psym=psym_obs, $
			xtickname=xtickname
		oplot, xvals, u_calc1, lines=ls_calc
		xyouts, ll_ux+x_lab_off, y_lab, '!8U!X', /normal, $
			charsize=csize_lab
		x = ll_ux + xlen_qtr
		plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	    pos = [ll_ux+xlen_half, y1, ll_ux+xlen, y2]
	    plot, xvals, u_obs2, /noerase, /normal, ystyle=0, xticks=xticks, $
		    pos=pos, /xstyle, charsize=csize, ycharsize=tiny, $
		    thick=thick, xthick=thick_axis, ythick=thick_axis, $
		    yrange=yrange_qu, ticklen=ticklen, psym=psym_obs, $
		    xtickname=xtickname
	    oplot, xvals, u_calc2, lines=ls_calc
	    xyouts, ll_ux+x_lab_off, y_lab, '!8U!X', /normal, $
		    charsize=csize_lab
	    x = ll_ux + xlen_half + xlen_qtr
	    plots, [x, x], [y1+yl_off, y2-yl_off], /normal

		pos = [ll_vx, y1, ll_vx+xlen_half, y2]
		plot, xvals, v_obs1, /noerase, /normal, ystyle=8, $
			pos=pos, /xstyle, charsize=csize, xticks=xticks, $
			thick=thick, xthick=thick_axis, ythick=thick_axis, $
			ticklen=ticklen, psym=psym_obs, $
			xtickname=xtickname
		oplot, xvals, v_calc1, lines=ls_calc
		xyouts, ll_vx+x_lab_off, y_lab, '!8V!X', /normal, $
			charsize=csize_lab
		x = ll_vx + xlen_qtr
		plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	    pos = [ll_vx+xlen_half, y1, ll_vx+xlen, y2]
	    plot, xvals, v_obs2, /noerase, /normal, ystyle=0, xticks=xticks, $
		    pos=pos, /xstyle, charsize=csize, ycharsize=tiny, $
		    thick=thick, xthick=thick_axis, ythick=thick_axis, $
		    ticklen=ticklen, psym=psym_obs, $
		    xtickname=xtickname
	    oplot, xvals, v_calc2, lines=ls_calc
	    xyouts, ll_vx+x_lab_off, y_lab, '!8V!X', /normal, $
		    charsize=csize_lab
	    x = ll_vx + xlen_half + xlen_qtr
	    plots, [x, x], [y1+yl_off, y2-yl_off], /normal

	endif else begin			; OTHER THAN BOTTOM ROW

		pos = [ll_ix, y1, ll_ix+xlen_half, y2]
		plot, xvals, i_obs1, /noerase, /normal, ystyle=8, $
			pos=pos, /xstyle, charsize=csize, xcharsize=tiny, $
			thick=thick, xthick=thick_axis, ythick=thick_axis, $
			ticklen=ticklen, xticks=xticks, psym=psym_obs
		oplot, xvals, i_calc1, lines=ls_calc
		oplot, xvals, i_imag1, lines=ls_imag
		xyouts, ll_ix+x_lab_off, y_lab, '!8I!X', /normal, $
			charsize=csize_lab
		x = ll_ix + xlen_qtr
		plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	    pos = [ll_ix+xlen_half, y1, ll_ix+xlen, y2]
	    plot, xvals, i_obs2, xticks=xticks, /noerase, /normal, ystyle=0, $
		    pos=pos, /xstyle, charsize=tiny, $
		    thick=thick, xthick=thick_axis, ythick=thick_axis, $
		    ticklen=ticklen, psym=psym_obs
	    oplot, xvals, i_calc2, lines=ls_calc
	    oplot, xvals, i_imag2, lines=ls_imag
	    xyouts, ll_ix+x_lab_off, y_lab, '!8I!X', /normal, $
		    charsize=csize_lab
	    x = ll_ix + xlen_half + xlen_qtr
	    plots, [x, x], [y1+yl_off, y2-yl_off], /normal

		pos = [ll_qx, y1, ll_qx+xlen_half, y2]
		plot, xvals, q_obs1, /noerase, /normal, ystyle=8, $
			pos=pos, /xstyle, charsize=csize, xcharsize=tiny, $
			thick=thick, xthick=thick_axis, ythick=thick_axis, $
			yrange=yrange_qu, ticklen=ticklen, psym=psym_obs, $
			xticks=xticks
		oplot, xvals, q_calc1, lines=ls_calc
		xyouts, ll_qx+x_lab_off, y_lab, '!8Q!X', /normal, $
			charsize=csize_lab
		x = ll_qx + xlen_qtr
		plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	    pos = [ll_qx+xlen_half, y1, ll_qx+xlen, y2]
	    plot, xvals, q_obs2, /noerase, /normal, ystyle=0, $
		    pos=pos, xticks=xticks, /xstyle, charsize=tiny, $
		    thick=thick, xthick=thick_axis, ythick=thick_axis, $
		    yrange=yrange_qu, ticklen=ticklen, psym=psym_obs
	    oplot, xvals, q_calc2, lines=ls_calc
	    xyouts, ll_qx+x_lab_off, y_lab, '!8Q!X', /normal, $
		    charsize=csize_lab
	    x = ll_qx + xlen_half + xlen_qtr
	    plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	
		pos = [ll_ux, y1, ll_ux+xlen_half, y2]
		plot, xvals, u_obs1, /noerase, /normal, ystyle=8, $
			pos=pos, /xstyle, xticks=xticks, charsize=tiny, $
			thick=thick, xthick=thick_axis, ythick=thick_axis, $
			yrange=yrange_qu, ticklen=ticklen, psym=psym_obs
		oplot, xvals, u_calc1, lines=ls_calc
		xyouts, ll_ux+x_lab_off, y_lab, '!8U!X', /normal, $
			charsize=csize_lab
		x = ll_ux + xlen_qtr
		plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	    pos = [ll_ux+xlen_half, y1, ll_ux+xlen, y2]
	    plot, xvals, u_obs2, /noerase, /normal, ystyle=0, $
		    pos=pos, /xstyle, charsize=tiny, xticks=xticks, $
		    thick=thick, xthick=thick_axis, ythick=thick_axis, $
		    yrange=yrange_qu, ticklen=ticklen, psym=psym_obs
	    oplot, xvals, u_calc2, lines=ls_calc
	    xyouts, ll_ux+x_lab_off, y_lab, '!8U!X', /normal, $
		    charsize=csize_lab
	    x = ll_ux + xlen_half + xlen_qtr
	    plots, [x, x], [y1+yl_off, y2-yl_off], /normal

		pos = [ll_vx, y1, ll_vx+xlen_half, y2]
		plot, xvals, v_obs1, /noerase, /normal, ystyle=8, $
			pos=pos, /xstyle, charsize=csize, xcharsize=tiny, $
			thick=thick, xthick=thick_axis, ythick=thick_axis, $
			ticklen=ticklen, psym=psym_obs, xticks=xticks
		oplot, xvals, v_calc1, lines=ls_calc
		xyouts, ll_vx+x_lab_off, y_lab, '!8V!X', /normal, $
			charsize=csize_lab
		x = ll_vx + xlen_qtr
		plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	    pos = [ll_vx+xlen_half, y1, ll_vx+xlen, y2]
	    plot, xvals, v_obs2, /noerase, /normal, ystyle=0, $
		    pos=pos, /xstyle, charsize=tiny, $
		    thick=thick, xthick=thick_axis, ythick=thick_axis, $
		    ticklen=ticklen, psym=psym_obs, xticks=xticks
	    oplot, xvals, v_calc2, lines=ls_calc
	    xyouts, ll_vx+x_lab_off, y_lab, '!8V!X', /normal, $
		    charsize=csize_lab
	    x = ll_vx + xlen_half + xlen_qtr
	    plots, [x, x], [y1+yl_off, y2-yl_off], /normal
	endelse

;	Close input file and free unit number.
	free_lun, in_unit

endfor
;----------------------------------------------------------------
;
;	Close PS file and return to X Windows.
;
print, '	Plot to file ' + stringit(fileps), format='(/A/)'
device, /close_file
set_plot, 'x'
!p.font = old_font	; restore font setting
;
;	Done.
;
end

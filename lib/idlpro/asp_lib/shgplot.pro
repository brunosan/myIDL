pro shgplot, tape, isave, vsave, $
	fileps=fileps, comment=comment, encapsulated=encapsulated, $
	mstepsz=mstepsz
;+
;
;	function:  shgplot
;
;	purpose:  plot I and V spectroheliograms to PostScript file
;
;	author:  rob@ncar, 8/92
;
;	ex:  shg, 'map2', i, x1=90,  x2=100, savefile='i.save'
;	     shg, 'map2', v, x1=140, x2=145, savefile='v.save', itype='v'
;	     shgplot, 'W920614A1', 'i.save', 'v.save'
;
;	notes:  - we are not trying to destreak the V shg -- only I
;		- mu of 1.0 is disk center; mu of 0.0 is on the limb
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 3 then begin
	print
	print, "usage:  shgplot, tape, isave, vsave"
	print
	print, "	Plot I and V spectroheliograms to PostScript file."
	print
	print, "	Arguments"
        print, "	    tape	- Exabyte tape name"
	print, "	    isave	- shg.pro savefile from I run"
	print, "	    vsave	- shg.pro savefile from V run"
	print
	print, "	Keywords"
	print, "	    mstepsz	- map step size to use for plotting"
	print, "		          (def = use value from op header)"
	print, "	    fileps	- PostScript file name"
	print, "		          (def = 'shgplot.ps', or
	print, "		           'shgplot.eps' if /encap set)"
	print, "	    encap	- set to O/P encapsulated PostScript"
	print, "		          (tape name will not appear on O/P)"
        print, "	    comment	- miscellaneous info to put on plot"
        print, "		          (def = no comments)"
	print
	return
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
do_encap = keyword_set(encapsulated)
if n_elements(fileps) eq 0 then begin
	if do_encap  then fileps='shgplot.eps'  else fileps='shgplot.ps'
endif
;
;	Restore saved information.
;
sec_sv = 0
restore, isave
restore, vsave
nfstep = 1L
if sizeof(ii, 0) eq 3 then nfstep = sizeof(ii, 3)	; movie map (3 dim's)
;
;	Set map step size to use.
;
if n_elements(mstepsz) ne 0 then mstepsz_use = mstepsz    $
			    else mstepsz_use = mstepsz_sv
if mstepsz_use eq 0 then message, "specify a non-zero 'mstepsz' (keyword)"
;
;	Select hardware font.
;
old_font = !p.font
!p.font = 0
;
;	Set up for PostScript device.
;
set_plot, 'ps'
xlen_dev = 8.0
ylen_dev = 10.5
xoffset = 0.5 * (8.5 - xlen_dev)
yoffset = 0.5 * (11.0 - ylen_dev)
device, bits_per_pixel=8, file=fileps, scale_factor=1.0, /inches, $
       	xoffset=xoffset, yoffset=yoffset, xsize=xlen_dev, ysize=ylen_dev, $
	/times, /bold, encapsulated=do_encap
;
;	Prepare restored information for plot.
;
operation = 'Operation ' + stringit(opnum_sv)
date = stringit(month_sv) + '/' + stringit(day_sv) + '/' + stringit(year_sv)
time = string(hour_sv, format='(I2.2)') + ':' + $
       string(min_sv,  format='(I2.2)') + ' UT'
map_steps = stringit(nmstep_sv) + ' steps at ' + $
	float_str(mstepsz_sv, 2) + '"'

;;mu = '!M\155!X ' + float_str(mu_sv, 2)   ; (does not work now with IDL 3.1.0)
mu = '!M' + string("155B) + '!X ' + float_str(mu_sv, 2)

location = 'Lat ' + float_str(lat_sv, 2) + $
	',  Long ' + float_str(long_sv, 2) + ' degrees, ' + noaa_sv
;
;	Plot titles.
;
x = 0.5
y = 0.95
d = 0.02
d_big = 0.04
s = ',  '
xyouts, x, y, /normal, align=0.5, 'HAO/NSO Advanced Stokes Polarimeter', $
	charsize=2.0, charthick=3.0
y = y - d_big
xyouts, x, y, /normal, align=0.5, 'Spectroheliograms of Raw Data', $
	charsize=1.5, charthick=2.5
y = y - d_big
;
if do_encap then begin
	xyouts, x, y, /normal, align=0.5, operation + s + date + ' ' + time
endif else begin
	xyouts, x, y, /normal, align=0.5, operation + s + date + ' ' + time $
		+ s + 'Tape ' + tape
endelse
;
y = y - d
xyouts, x, y, /normal, align=0.5, map_steps + s + mu + s + location
y = y - d
if n_elements(comment) ne 0 then  xyouts, x, y, /normal, align=0.5, $
	'Comments:  ' + comment
;
;	Set plot dimensions, respecting original map aspect ratio.
;
y_pixel_d = 0.370		; distance in asec between pixels along slit
xlen_map = float(sizeof(ii,1))
ylen_map = float(sizeof(ii,2))
ratio0 = mstepsz_use / y_pixel_d			; ratio of asec
ratio1 = ylen_dev / xlen_dev				; ratio of PS output
ratio2 = xlen_map / ylen_map				; ratio of input
;
;	y/2		ylen_norm	(Using up remaining y with 2 plots
;	------	=	---------	of 256 in map dimension; actual
;	256		ylen_map	y dimension will be prob. < 256,
;					so will have space around each plot)
;
ylen_norm = ylen_map * y / 512.0
xlen_norm = ylen_norm * ratio0 * ratio1 * ratio2	; use aspect ratios
y_vv = (y - ylen_norm - ylen_norm) / 3.0
y_ii = y_vv + ylen_norm + y_vv
;
;	Plot non-movie map.
;
if nfstep eq 1 then begin
	x = 0.5 - 0.5 * xlen_norm
	xlist = 1.0 - 0.5 * x
;
;	Plot I shg.
	tvscl, ii, x, y_ii, /normal, xsize=xlen_norm, ysize=ylen_norm
	ylist = y_ii + 0.5 * ylen_norm
	xyouts, xlist, ylist, /normal, align=0.5, 'I', charsize=2.0, $
		charthick=2.5
;
;	Plot V shg.
	tvscl, vv, x, y_vv, /normal, xsize=xlen_norm, ysize=ylen_norm
	ylist = y_vv + 0.5 * ylen_norm
	xyouts, xlist, ylist, /normal, align=0.5, 'V', charsize=2.0, $
		charthick=2.5
;
;	Close PS file.
	print
	print, '	Plot to file ' + stringit(fileps)
	print
	device, /close_file
;
;	Plot movie map.
;
endif else begin
	xsize = xlen_norm * nfstep
;
;	Multiple PS pages of output.
	if xsize gt 1.0 then begin
		print
		print, 'Multiple-page-plot code not written yet ...'
		print
		print, 'normalized width per map = ' + stringit(xlen_norm)
		print, '    total number of maps = ' + stringit(nfstep)
		print
		return
	endif
;
;	Single PS page of output.
	xspace = (1.0 - xsize) / (nfstep + 2)	; extra space on R for key
	x = xspace
	for iframe = 0, nfstep-1 do begin
		tvscl, ii(*, *, iframe), x, y_ii, /normal, $
			xsize=xlen_norm, ysize=ylen_norm
		tvscl, vv(*, *, iframe), x, y_vv, /normal, $
			xsize=xlen_norm, ysize=ylen_norm
		x = x + xlen_norm + xspace
	endfor
	xlist = 1.0 - 0.5 * xspace
	ylist = y_ii + 0.5 * ylen_norm
	xyouts, xlist, ylist, /normal, align=0.5, 'I', charsize=2.0, $
		charthick=2.5
	ylist = y_vv + 0.5 * ylen_norm
	xyouts, xlist, ylist, /normal, align=0.5, 'V', charsize=2.0, $
		charthick=2.5
	print
	print, '	Plot to file ' + stringit(fileps)
	print
	device, /close_file
endelse
;
;	Return to X Windows.
;
set_plot, 'x'
!p.font = old_font	; restore font setting
;
;	Done.
;
end

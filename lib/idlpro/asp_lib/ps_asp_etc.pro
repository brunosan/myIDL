pro ps_asp_etc_usage
;+
;
;	procedure:  ps_asp_etc
;
;	purpose:  finish out PostScript file details started by
;		  azam or ps_asp
;
;	author:  rob@ncar 1/93  paul@ncar 10/93
;
;	routines:  ps_asp_etc_usage  ps_asp_arrow    ps_asp_hilight
;		   plo               xyo             ps_asp_open
;		   ps_asp_oimage     ps_asp_1per     ps_asp_etc
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:  ps_asp_etc, ps, umbra, laluz, op $"
	print, "	, ifarrow, azm, incl, sxy, date=date $
	print, "	, by__cct  = by__cct   $"
	print, "	, by_fld   = by_fld    $"
	print, "	, by_s_fld = by_s_fld  $"
	print, "	, by_1azm  = by_1azm   $"
	print, "	, by_1incl = by_1incl  $"
	print, "	, by_cen1  = by_cen1   $"
	print, "	, by_flux  = by_flux   $"
	print, "	, azam     = aa"
	print
	print, "    Finish out PostScript file details started by"
	print, "    azam or ps_asp.  Actual PostScript files output"
	print, "    depend on data made available by keywords."
	print
	print, "Arguments:"
	print, "    ps		- structure initialized by ps_asp_str.pro
	print, "    umbra	- where umbra hi light array"
	print, "    laluz	- where array for to hi light"
	print, "    op		- op number (def not used)"
	print, "    ifarrow	- 1 if arrow points are to be plotted.
	print, "    azm		- 2D azimuth array.
	print, "    incl	- 2D incline array.
	print, "    sxy		- where the is data in azm and incl.
	print
	print, "Keywords: (all are input and are unchanged)"
	print, "    date	- month day year, 3 component vector
	print, "    by__cct	- color byte image of continuum"
	print, "    by_fld	- color byte image of mag field"
	print, "    by_s_fld	- color byte image of signed mag field"
	print, "    by_1azm	- color byte image of local frame azimuth"
	print, "    by_1incl	- color byte image of local frame inclination"
	print, "    by_cen1	- color byte image of doppler"
	print, "    by_flux	- color byte image of mag. flux"
	print, "    azam	- input azam structure"
	print
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	function:  ps_asp_arrow
;
;	purpose:  return arrow point structure for PostScript images 
;
;------------------------------------------------------------------------------
function ps_asp_arrow, azm, incl, ifdata, xinches
;
;	Check number or parameters.
;
if  n_params() eq 0  then begin
	print
	print, "usage:  arrow = ps_asp_arrow( azm, incl, ifdata, xinches )"
	print
	print, "    Return arrow point structure for azam display images"
	print
	print, "Arguments: (all input and are unchanged)"
	print
	print, "    azm		- azimuth 2D array, degrees"
	print, "    incl	- inclination 2D array, degrees"
	print, "    ifdata	- 2D logical array for data locations"
	print, "    xinches	- X size on device in inches."
	print
	return, 0
end
				    ;
				    ;arrow point length in inches.
				    ;
asize = 1./8.
				    ;
				    ;Get array dimensions.
				    ;
sizeazm = size(azm)
xdim    = sizeazm(1)
ydim    = sizeazm(2)
				    ;
				    ;Get y size in inches.
				    ;
yinches = ydim*xinches/xdim
				    ;
				    ;Form blank arrow point storage.
				    ;
arx = fltarr(3,xinches*yinches/(asize*asize))
ary = fltarr(3,xinches*yinches/(asize*asize))
ari = fltarr(  xinches*yinches/(asize*asize))
				    ;
				    ;Initial arrow point count.
				    ;
num = -1
				    ;
				    ;Loop over two spacial dimensions.
				    ;
for  ix = asize/2., xinches-asize/2., 1.2*asize  do begin
for  iy = asize/2., yinches-asize/2., 1.2*asize  do begin
				    ;
	xc = xdim*ix/xinches
	yc = ydim*iy/yinches
				    ;
	if  ifdata(xc,yc)  then begin
				    ;
				    ;Compute arrow point.
				    ;
		xrast = [ -asize/2.,  asize/2., -asize/2. ] $
		* sin(incl(xc,yc)*!pi/180.)
		yrast = [  asize/4.,        0., -asize/4. ]
		cn = cos(azm(xc,yc)*!pi/180.)
		sn = sin(azm(xc,yc)*!pi/180.)
		xprm = cn*xrast-sn*yrast
		yprm = sn*xrast+cn*yrast
				    ;
				    ;Install arrow point.
				    ;Save corresponding inclination.
				    ;
		num = num+1
		arx(*,num) = xprm+ix
		ary(*,num) = yprm+iy
		ari(  num) = incl(xc,yc)
				    ;
	end
				    ;
end
end
				    ;
				    ;Set arrow point structure
				    ;
return, { num:num $
, arx:arx(*,0:(0>num)), ary:ary(*,0:(0>num)), ari:ari(0:(0>num)) }
				    ;
end
;------------------------------------------------------------------------------
;
;	function:  ps_asp_hilight
;
;	purpose:  translate array imbedded highlights to structure for
;		  vector drawn highlights.
;
;------------------------------------------------------------------------------
function ps_asp_hilight, high
;
;	Check number or parameters.
;
if  n_params() eq 0  then begin
	print
	print, "usage:  arrow = ps_asp_hilight( high )"
	print
	print, "	Translate array imbedded highlights to structure for"
	print, "	vector drawn highlights"
	print
	print, "	high	- 2D array logical array of hilight locations"
	print
	return,0
end
				    ;
				    ;Get array dimensions.
				    ;
size_high = size(high)
xdim      = size_high(1)
ydim      = size_high(2)
				    ;
				    ;Form blank vector storage.
				    ;
arx = intarr(2,xdim*ydim)
ary = intarr(2,xdim*ydim)
				    ;
				    ;Initial vector count.
				    ;
num = -1
				    ;
				    ;Loop over two spacial dimensions.
				    ;
for  ix = 0,xdim-2  do begin
for  iy = 0,ydim-2  do begin
				    ;
	if high(ix,iy) then begin
				    ;
		if high(ix+1,iy) then begin
				    ;
				    ;Install horizontal vector.
				    ;
			num = num+1
			arx(*,num) = [ ix, ix+1 ]
			ary(*,num) = iy
				    ;
		end
				    ;
		if high(ix,iy+1) then begin
				    ;
				    ;Install vertical vector.
				    ;
			num = num+1
			arx(*,num) = ix
			ary(*,num) = [ iy, iy+1 ]
				    ;
		end
				    ;
		if high(ix+1,iy+1)   then begin
		if not high(ix,iy+1) then begin
		if not high(ix+1,iy) then begin
				    ;
				    ;Install diagonal vector.
				    ;
			num = num+1
			arx(*,num) = [ ix, ix+1 ]
			ary(*,num) = [ iy, iy+1 ]
				    ;
		end
		end
		end
				    ;
	end else begin
				    ;
		if high(ix,iy+1)       then begin
		if high(ix+1,iy)       then begin
		if not high(ix+1,iy+1) then begin
				    ;
				    ;Install anti diagonal vector.
				    ;
			num = num+1
			arx(*,num) = [ ix, ix+1 ]
			ary(*,num) = [ iy+1, iy ]
				    ;
		end
		end
		end
				    ;
	end
				    ;
end
end
				    ;
				    ;Set vector structure.
				    ;
return, { num:num, arx:arx(*,0:(0>num)), ary:ary(*,0:(0>num)) }
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure: plo
;
;	purpose: scale vectors to normal coordinates and output with plots.
;
;------------------------------------------------------------------------------
pro plo, ps, x, y $
, color=color, thick=thick
				    ;
if n_elements(color   ) eq 0 then    color = 0
if n_elements(thick   ) eq 0 then    thick = !p.thick
				    ;
plots, /normal, x/ps.xdev, y/ps.ydev, color=color, thick=thick
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure: xyo
;
;	purpose: scale normal coordinates and output string with xyouts.
;
;------------------------------------------------------------------------------
pro xyo, ps, x, y, s $
, color=color, charsize=charsize, align=align, orient=orient
				    ;
if n_elements(orient  ) eq 0 then   orient = 0.
if n_elements(color   ) eq 0 then    color = 0
if n_elements(charsize) eq 0 then charsize = 1.
				    ;
xyouts, /normal, x/ps.xdev, y/ps.ydev, s $
, color=color, charsize=charsize, align=align, orient=orient
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure:  ps_asp_open
;
;	purpose:  Open Postscript file; output heading, date and op number.
;
;------------------------------------------------------------------------------
pro ps_asp_open, ps, file
				    ;
				    ;Open file in landscape mode.
				    ;
device, bits_per_pixel=8, file=ps.dty+file+'.'+ps.cs_ext, /inches $
, xoffset=0., yoffset=ps.xdev $
, xsize=ps.xdev, ysize=ps.ydev $
, color=1, /times, /bold, /landscape
				    ;
				    ;Output heading.
				    ;
xyo, ps, charsize=2.0, align=0.0 $
, ps.mrg_lft, ps.ydev-7./16. $
, 'HAO/NSO Advanced Stokes Polarimeter'
				    ;
				    ;Output date
				    ;
xyo, ps, charsize=2.0, align=1.0 $
, ps.xdev-3./16., ps.ydev-7./16. $
, ps.cs_date
				    ;
				    ;Output op number.
				    ;
if ps.cs_op ne '' then $
xyo, ps, charsize=2.0, align=1.0 $
, ps.xdev-3./16., ps.ydev-3./4. $
, ps.cs_op
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure:  ps_asp_oimage
;
;	purpose:  output and partly annotate one PostScript image
;
;------------------------------------------------------------------------------
pro ps_asp_oimage, ps, image, name $
, vumbra, color_umb $
, vlaluz, color_luz $
, arrow, color_hi, color_lo
				    ;
				    ;Get some info from ps structure.
				    ;
xdev=ps.xdev & xorg=ps.xorg & xinches=ps.xinches & xx0=ps.xx0 & xx1=ps.xx1
ydev=ps.ydev & yorg=ps.yorg & yinches=ps.yinches & yy0=ps.yy0 & yy1=ps.yy1
x_mm = ps.x_mm
ticklen = ps.ticklen & hithick=ps.hithick
xnumber = ps.xnumber & ynumber=ps.ynumber
				    ;
				    ;Output image name.
				    ;
xyo, ps, charsize=2.0, align=0.5 $
, xorg+.5*xinches, yorg+yinches+.1 $
, name
				    ;
				    ;Output byte image.
				    ;
tv, image(xx0:xx1,yy0:yy1), xorg, yorg $
, xsize=xinches, ysize=yinches, /inches
				    ;
				    ;Plot arrow points.
				    ;
if arrow.num ge 0 then begin
	arx = arrow.arx+xorg
	ary = arrow.ary+yorg
	for i=0,arrow.num do begin
		if arrow.ari(i) le 90. then col=color_hi else col=color_lo
		plo, ps, arx(*,i), ary(*,i), color=col, thick=hithick/2.
	end
end
				    ;
				    ;Plot umbra contour.
				    ;
if vumbra.num ge 0 then begin
	arx = vumbra.arx*xinches/(xx1-xx0)+xorg
	ary = vumbra.ary*yinches/(yy1-yy0)+yorg
	for i=0,vumbra.num do $
	plo, ps, arx(*,i), ary(*,i), color=color_umb, thick=hithick
end
				    ;
				    ;Plot laluz highlight.
				    ;
if vlaluz.num ge 0 then begin
	arx = vlaluz.arx*xinches/(xx1-xx0)+xorg
	ary = vlaluz.ary*yinches/(yy1-yy0)+yorg
	for i=0,vlaluz.num do $
	plo, ps, arx(*,i), ary(*,i), color=color_luz, thick=hithick
end
				    ;
				    ;Frame image.
				    ;
plo, ps, color=0 $
, [ 0.,      0., xinches, xinches, 0. ]+xorg $
, [ 0., yinches, yinches,      0., 0. ]+yorg
				    ;
				    ;Interval for axis numbers and tick marks.
				    ;
interval = 10.*xinches/x_mm
				    ;
				    ;Draw x-axis tick marks.
				    ;
nlbl = long(xinches/interval)
lgen = lindgen(nlbl)+1
tick = xorg+lgen*interval
for i=0,nlbl-1 do begin
	plo, ps, color=0, tick(i), [0., ticklen]+yorg
	plo, ps, color=0, tick(i), [0.,-ticklen]+yorg+yinches
end
				    ;
				    ;Number x-azis.
				    ;
if xnumber then begin
	xyo, ps, charsize=1.75, align=0.0 $
	, xorg, yorg-5./16. $
	, '0'
	xyo, ps, charsize=1.75, align=0.5 $
	, tick, yorg-5./16. $
	, stringit(10*lgen)
end
				    ;
				    ;Draw y-axis tick marks.
				    ;
nlbl = long(yinches/interval)
lgen = lindgen(nlbl)+1
tick = yorg+lgen*interval
for i=0,nlbl-1 do begin
	plo, ps, color=0, [0., ticklen]+xorg, tick(i)
	plo, ps, color=0, [0.,-ticklen]+xorg+xinches, tick(i)
end
				    ;
				    ;Number y-azis.
				    ;
if ynumber then begin
	xyo, ps, charsize=1.75, align=1.0 $
	, xorg-1./16., yorg $
	, '0'
	xyo, ps, charsize=1.75, align=1.0 $
	, xorg-1./16., tick-3./32. $
	, stringit(10*lgen)
end
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure:  ps_asp_1per
;
;	purpose:  open file for PostScript and output one image per page
;		  with some annotation
;
;------------------------------------------------------------------------------
pro ps_asp_1per, ps, file, image, name $
, vumbra, color_umb $
, vlaluz, color_luz $
, arrow, color_hi, color_lo
				    ;
				    ;Open postscript file and output
				    ;heading, date and op number.
				    ;
ps_asp_open, ps, file
				    ;
				    ;Output and partly annotate image.
				    ;
ps_asp_oimage, ps, image, name $
, vumbra, color_umb $
, vlaluz, color_luz $
, arrow, color_hi, color_lo
				    ;               N
				    ;Print symbol  E W
				    ;               S
xyo, ps, charsize=2.0, align=.0 $
, [ .220, .235, .000, .400 ]+ps.xorg+ps.xinches+1./16. $
, [ .500, .000, .250, .250 ]+ps.yorg+ps.yinches-7./8.  $
, [  'N',  'S',  'E',  'W' ]
				    ;
				    ;Output xy scale units.
				    ;
xyo, ps, charsize=2.0, align=0.0 $
, ps.mrg_lft, ps.ydev-3./4. $
, 'Megameters xy'
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure:  azam_ps_etc
;
;	purpose:  finish out PostScript files details started by
;		  azam or ps_asp
;
;------------------------------------------------------------------------------
pro ps_asp_etc, ps, umbra, laluz, op $
, ifarrow, azm, incl, sxy, date=date $
, by__cct  = by__cct   $
, by_fld   = by_fld    $
, by_s_fld = by_s_fld  $
, by_1azm  = by_1azm   $
, by_1incl = by_1incl  $
, by_cen1  = by_cen1   $
, by_flux  = by_flux   $
, azam     = aa
				    ;
				    ;Check number of parameters.
				    ;
if n_params() eq 0 then begin
	ps_asp_etc_usage
return
end
				    ;
				    ;Save active window.
				    ;
w_sav = !d.window
				    ;
				    ;Image dimensions.
				    ;
xdim  = ps.xdim
ydim  = ps.ydim
				    ;
				    ;Strings for max field strength.
				    ;
field_max1 = strtrim(string(ps.mxfld,format='(i4)'))
field_max4 = strtrim(string(ps.mxfld/1000.,format='(f3.1)'))
				    ;
				    ;Special tvasp colors.
				    ;
@tvasp.com
white  = tvasp.ix_white
yellow = tvasp.ix_yellow
red    = tvasp.ix_red
green  = tvasp.ix_green
blue   = tvasp.ix_blue
black  = tvasp.ix_black
				    ;
				    ;Null highlights.
				    ;
null_vumbra = { num:-1 }
null_vlaluz = { num:-1 }
null_arrow  = { num:-1 }
				    ;
				    ;Get date from header.
				    ;
month = long(ps.head(0)+.5)
day   = long(ps.head(1)+.5)
year  = long(ps.head(2)+.5)
if n_elements(date) ne 0 then begin
	month = date(0)
	day   = date(1)
	year  = date(2)
end
tmp = [' zip' $
,' Jan ',' Feb ',' Mar ',' Apr ',' May ',' Jun ' $
,' Jul ',' Aug ',' Sep ',' Oct ',' Nov ',' Dec ' ]
ps.cs_date = stringit(day)+tmp(month)+stringit(year)
				    ;
				    ;Set string for op number.
				    ;
ps.cs_op = ''
if n_elements(op) ne 0 then  ps.cs_op = 'Op '+stringit(op)
				    ;
				    ;Set array bounds if images is too large.
				    ;
ps.xx0 = 0
ps.xx1 = xdim-1
if ps.x_mm gt ps.x_avail*ps.mm_per_inch then begin
	xsz     = (xdim-1) * ps.x_avail * ps.mm_per_inch / ps.x_mm
	dx      = long(xsz+1.5)
	ps.xx0  = 0 > ( (ps.xctr-dx/2) < (xdim-dx) )
	ps.xx1  = (ps.xx0+dx-1) < (xdim-1)
	xsz     = float( ps.xx1-ps.xx0 )
	ps.x_mm = xsz / ps.pix_deg * ps.mm_per_deg
end
				    ;
ps.yy0 = 0
ps.yy1 = ydim-1
if ps.y_mm gt ps.y_avail*ps.mm_per_inch then begin
	ysz     = (ydim-1) * ps.y_avail * ps.mm_per_inch / ps.y_mm
	dy      = long(ysz+1.5)
	ps.yy0  = 0 > ( (ps.yctr-dy/2) < (ydim-dy) )
	ps.yy1  = (ps.yy0+dy-1) < (ydim-1)
	ysz     = float( ps.yy1-ps.yy0 )
	ps.y_mm = ysz / ps.pix_deg * ps.mm_per_deg
end
				    ;
				    ;Image size in inches.
				    ;
ps.yinches = ps.y_mm / ps.mm_per_inch
ps.xinches = ps.x_mm * ps.yinches / ps.y_mm
				    ;
				    ;Set vector drawn umbra structure.
				    ;
vumbra = null_vumbra
if n_elements(umbra) ne 0 then  if sizeof(umbra,0) ne 0 then begin
	tmp = intarr(xdim,ydim)
	tmp(umbra) = 1
	vumbra = ps_asp_hilight( tmp(ps.xx0:ps.xx1,ps.yy0:ps.yy1) )
end
				    ;
				    ;Set vector drawn laluz structure.
				    ;
vlaluz = null_vlaluz
if n_elements(laluz) ne 0 then  if sizeof(laluz,0) ne 0 then begin
	tmp = intarr(xdim,ydim)
	tmp(laluz) = 1
	vlaluz = ps_asp_hilight( tmp(ps.xx0:ps.xx1,ps.yy0:ps.yy1) )
end
				    ;
				    ;Compute arrow point structure.
				    ;
arrow = null_arrow
if ifarrow then begin
	ifdata = bytarr(xdim,ydim)
	ifdata( sxy ) = 1
	arrow = ps_asp_arrow(  $
	  azm(    ps.xx0:ps.xx1, ps.yy0:ps.yy1 ) $
	, incl(   ps.xx0:ps.xx1, ps.yy0:ps.yy1 ) $
	, ifdata( ps.xx0:ps.xx1, ps.yy0:ps.yy1 ) $
	, ps.xinches )
end
				    ;
				    ;Image lower left corner in inches.
				    ;
ps.yorg = ps.ydev-ps.mrg_top-ps.yinches		 &  ps.yll = ps.yorg
ps.xorg = ps.mrg_lft+.5*(ps.x_avail-ps.xinches)  &  ps.xll = ps.xorg
				    ;
				    ;Save font info.
				    ;Save plots line thickness.
				    ;Set plots line thickness.
				    ;Select hardware font.
				    ;Set PostScript device.
				    ;
sav_p_font  = !p.font
sav_p_thick = !p.thick
!p.thick    = 5.
!p.font     = 0
set_plot, 'ps'
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot and annotate azam custom image.
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if  n_elements(aa) ne 0  then begin
				    ;Set hilight colors.
	if aa.custgray then begin
		luz = yellow
		umb = red
	end else begin
		luz = white
		umb = black
	end
				    ;Open *.ps file and plot image.
	ps_asp_1per, ps, aa.custname, aa.cust, aa.custname $
	, vumbra, umb $
	, vlaluz, luz $
	, arrow, umb, luz
				    ;Plot color bar.
	x0 = ps.xorg+ps.xinches+7./16.
	x1 = x0+1./2.
	y1 = ps.yorg+ps.yinches-1.5
	y0 = y1-3.
	tvasp, lindgen(20,100)/20, /notv, bi=tmp $
	, gray=aa.custgray, invert=aa.custinv, wrap=aa.custwrap
	tv, tmp, x0, y0, xsize=x1-x0, ysize=y1-y0, /inches
	plo, ps, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	xyo, ps, charsize=1.5, align=0.0 $
	, x0, [ y0-5./16., y1+1./32. ] $
	, strcompress(/remove_all,string([aa.custmin,aa.custmax]))

	;	xyo, ps, charsize=2.0, align=0.5, orient=90. $
	;	, x0-1./16., .5*(y0+y1) $
	;	, ''
				    ;Close *.ps file.
	device, /close_file
end
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot and annotate by__cct image
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
if  n_elements(by__cct) ne 0  then begin
				    ;
	ps_asp_1per, ps, 'cct', by__cct, 'Continuum Intensity' $
	, vumbra, red $
	, vlaluz, yellow $
	, arrow, red, yellow
				    ;
				    ;Plot color bar.
				    ;
	x0 = ps.xorg+ps.xinches+7./16.
	x1 = x0+1./2.
	y1 = ps.yorg+ps.yinches-1.5
	y0 = y1-3.
	tvasp, lindgen(20,100)/20, /notv, bi=tmp, /gray
	tv, tmp, x0, y0, xsize=x1-x0, ysize=y1-y0, /inches
	plo, ps, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	xyo, ps, charsize=2.0, align=1.0 $
	, x1, [ y0-5./16., y1+1./32. ] $
	, [ stringit(long(ps.cct_min+.5)), stringit(long(ps.cct_max+.5)) ]
	xyo, ps, charsize=2.0, align=0.5, orient=90. $
	, x0-1./16., .5*(y0+y1) $
	, 'Instrument scale'
				    ;
	device, /close_file
end
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot and annotate by_fld image
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
if  n_elements(by_fld) ne 0  then begin
				    ;
	ps_asp_1per, ps, 'fld', by_fld, 'Field Magnitude' $
	, vumbra, red $
	, vlaluz, yellow $
	, arrow, red, yellow
				    ;
				    ;Plot color bar.
				    ;
	x0 = ps.xorg+ps.xinches+7./16.
	x1 = x0+1./2.
	y1 = ps.yorg+ps.yinches-1.5
	y0 = y1-3.
	tvasp, lindgen(20,100)/20, /notv, bi=tmp, /gray, /invert
	tv, tmp, x0, y0, xsize=x1-x0, ysize=y1-y0, /inches
	plo, ps, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	xyo, ps, charsize=2.0, align=1.0 $
	, x1, [ y0-5./16., y1+1./32. ] $
	, [ '0', field_max1 ]
	xyo, ps, charsize=2.0, align=0.5, orient=90. $
	, x0-1./16., .5*(y0+y1) $
	, 'Gauss'
				    ;
	device, /close_file
end
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot and annotate by_flux image
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
if  n_elements(by_flux) ne 0  then begin
				    ;
	ps_asp_1per, ps, 'flux', by_flux, 'Magnetic Flux' $
	, vumbra, white $
	, vlaluz, black $
	, arrow, white, black
				    ;
				    ;Plot color bar.
				    ;
	x0 = ps.xorg+ps.xinches+7./16.
	x1 = x0+1./2.
	y1 = ps.yorg+ps.yinches-1.5
	y0 = y1-3.
	tmp0 = lindgen(20,100)/20
	lgap = 100.*(2.*ps.mxfld+ps.gap)/(2.*ps.mxfld)-100.
	tmp0(*,50:99) = tmp0(*,50:99)+lgap
	tvasp, tmp0, /notv, bi=tmp, /invert
	tv, tmp, x0, y0, xsize=x1-x0, ysize=y1-y0, /inches
	plo, ps, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	xyo, ps, charsize=2.0, align=1.0 $
	, x1, [ y0-5./16., y1+1./32. ] $
	, [ '-', '' ]+field_max1
	xyo, ps, charsize=2.0, align=0.5, orient=90. $
	, x0-1./16., .5*(y0+y1) $
	, 'Gauss'
				    ;
	device, /close_file
end
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot and annotate by_cen1 image
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
if  n_elements(by_cen1) ne 0  then begin
				    ;
	ps_asp_1per, ps, 'cen1', by_cen1, 'Doppler Shift' $
	, vumbra, white $
	, vlaluz, black $
	, arrow, white, black
				    ;
				    ;Plot color bar.
				    ;
	x0 = ps.xorg+ps.xinches+7./16.
	x1 = x0+1./2.
	y1 = ps.yorg+ps.yinches-1.5
	y0 = y1-3.
	tvasp, lindgen(20,100)/20, /notv, bi=tmp
	tv, tmp, x0, y0, xsize=x1-x0, ysize=y1-y0, /inches
	plo, ps, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	xyo, ps, charsize=2.0, align=1.0 $
	, x1, [ y0-5./16., y1+1./32. ] $
	, [ '-2', '2' ]
	xyo, ps, charsize=2.0, align=0.5, orient=90. $
	, x0-1./16., .5*(y0+y1) $
	, 'km/sec'
				    ;
	device, /close_file
end
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot and annotate by_1azm image
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
if  n_elements(by_1azm) ne 0  then begin
				    ;
	ps_asp_1per, ps, '1azm', by_1azm, 'Field Azimuth' $
	, vumbra, white $
	, vlaluz, black $
	, arrow, white, black
				    ;
				    ;Plot color table.
				    ;
	x0 = ps.xorg+ps.xinches
	x1 = x0+1.
	y1 = ps.yorg+ps.yinches-1.75
	y0 = y1-2.
				    ;
	xrast = lindgen(101,101)
	yrast = xrast/101
	xrast = xrast-yrast*101
	whr = where( ( (xrast-50)^2+(yrast-50)^2 le 50^2 ) $
         	and ( (xrast-50)^2+(yrast-50)^2 ge 25^2 ) )
	tmp0 = replicate(1000.,101,101)
	tmp0(whr) = atan( yrast(whr)-50, xrast(whr)-50 )
	tvasp, tmp0, /notv, bi=tmp, min=-!pi, max=!pi $
	, white=where( tmp0 eq 1000.), /wrap
	tv, tmp, x0, y0+5./16., xsize=1., ysize=1., /inches
				    ;
	plo, ps, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	plo, ps, [ x1-1./4., x1 ], y0+13./16
				    ;
	xyo, ps, charsize=2.0*.8, align=0.5 $
	, .5*(x1+x0) $
	, [ y0, y0+1.+5./16., y0+1.+11./16. ]+1./16. $
	, [ '270', '90', 'Degrees' ]
				    ;
	device, /close_file
end
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot and annotate by_1incl image
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
if  n_elements(by_1azm) ne 0  then begin
				    ;
	ps_asp_1per, ps, '1incl', by_1incl, 'Field Inclination' $
	, vumbra, white $
	, vlaluz, black $
	, arrow, white, black
				    ;
				    ;Plot color table.
				    ;
	x0 = ps.xorg+ps.xinches
	x1 = x0+1.
	y1 = ps.yorg+ps.yinches-1.75
	y0 = y1-3.
				    ;
	xrast = lindgen(101,201)
	yrast = xrast/101
	xrast = xrast-yrast*101
	whr = where( ( xrast^2+(yrast-100)^2 le 100^2 ) $
         	and ( xrast^2+(yrast-100)^2 ge  50^2 ) )
	tmp0 = replicate(1000.,101,201)
	tmp0(whr) = atan( xrast(whr), yrast(whr)-100 )
	tvasp, tmp0, /notv, bi=tmp, min=0., max=!pi $
	, white=where( tmp0 eq 1000.)
	tv, tmp, x0, y0+5./16., xsize=1., ysize=2., /inches
				    ;
	plo, ps, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	plo, ps, [ x1-1./2., x1 ], y0+1.+5./16.
				    ;
	xyo, ps, charsize=2.0*.8, align=0.0 $
	, x0+.03 $
	, [ y0, y0+2.+5./16., y0+2.+11./16. ]+1./16. $
	, [ '180', '0', 'Degrees' ]
				    ;
	device, /close_file
end
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Set for four per page format.
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
				    ;Get copy of ps structure to be modified.
				    ;
p4 = ps
				    ;
				    ;Reset tick mark length.
				    ;
p4.ticklen = 1./8.
				    ;
				    ;Reset highlight line thickness.
				    ;
p4.hithick = 2.5
				    ;
				    ;Size of space between plots.
				    ;
spcy = .5
spcx = .5
				    ;
				    ;Set image size in inches.
				    ;
scale_fac = (.5*(ps.y_avail-spcy)/ps.y_avail) $
     < (.5*(ps.x_avail-spcx)/ps.x_avail)
p4.xinches = scale_fac*ps.xinches
p4.yinches = scale_fac*ps.yinches
				    ;
				    ;Compute arrow point structure.
				    ;
arrow4 = null_arrow
if ifarrow then begin
	arrow4 = ps_asp_arrow(  $
	  azm(    p4.xx0:p4.xx1, p4.yy0:p4.yy1 ) $
	, incl(   p4.xx0:p4.xx1, p4.yy0:p4.yy1 ) $
	, ifdata( p4.xx0:p4.xx1, p4.yy0:p4.yy1 ) $
	, p4.xinches )
end
				    ;
				    ;Set lower left corner of lower left image.
				    ;
spcx = spcx > (.5*(p4.x_avail-2.*p4.xinches))
p4.xll = p4.mrg_lft > (p4.mrg_lft+p4.x_avail-2.*p4.xinches-1.5*spcx)
p4.yll = p4.yll
				    ;
				    ;Permit y-axis numbers in the middle
				    ;if there is enough space.
				    ;
if  spcx gt 1.+1./8.  then  ybetween=1  else  ybetween=0
				    ;
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot iiii file.
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
if   n_elements(by__cct) ne 0  and  n_elements(by_1azm ) ne 0  $
and  n_elements(by_fld ) ne 0  and  n_elements(by_1incl) ne 0  then begin
				    ;
				    ;Open postscript file and output
				    ;heading, date and op number.
				    ;
	ps_asp_open, p4, 'iiii'
				    ;
				    ;Output and annotate by__cct image.
				    ;
	p4.xorg = p4.xll
	p4.yorg = p4.yll+p4.yinches+spcy
	p4.xnumber = 0
	p4.ynumber = 1
	ps_asp_oimage, p4, by__cct, 'Continuum Intensity' $
	, vumbra, red $
	, vlaluz, yellow $
	, arrow4, red, yellow
				    ;
				    ;Output and annotate by_fld image.
				    ;
	p4.xorg = p4.xll
	p4.yorg = p4.yll
	p4.xnumber = 1
	p4.ynumber = 1
	ps_asp_oimage, p4, by_fld, 'Field Magnitude (kGauss)' $
	, vumbra, red $
	, vlaluz, yellow $
	, arrow4, red, yellow
				    ;
				    ;Output and annotate by_1azm image.
				    ;
	p4.xorg = p4.xll+p4.xinches+spcx
	p4.yorg = p4.yll+p4.yinches+spcy
	p4.xnumber = 0
	p4.ynumber = ybetween
	ps_asp_oimage, p4, by_1azm, 'Field Azimuth (degrees)' $
	, vumbra, white $
	, vlaluz, black $
	, arrow4, white, black
				    ;
				    ;Output and annotate by_1incl image.
				    ;
	p4.xorg = p4.xll+p4.xinches+spcx
	p4.yorg = p4.yll
	p4.xnumber = 0
	p4.ynumber = ybetween
	ps_asp_oimage, p4, by_1incl, 'Field Inclination (degrees)' $
	, vumbra, white $
	, vlaluz, black $
	, arrow4, white, black
				    ;
				    ;Plot color bar for by_fld.
				    ;
	xorg = p4.xll
	yorg = p4.yll
	x0 = xorg+p4.xinches+1./16.
	x1 = x0+1./4.
	y0 = yorg+3./8.
	y1 = yorg+p4.yinches-3./8.
	tvasp, lindgen(10,100)/10, /notv, bi=tmp, /gray, /invert
	tv, tmp, x0, y0, xsize=x1-x0, ysize=y1-y0, /inches
	plo, p4, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	xyo, p4, charsize=2.0, align=0.0 $
	, x0, [ y0-5./16., y1+1./32. ] $
	, [ '0', field_max4 ]
				    ;
				    ;Plot color table for by_1azm.
				    ;
	xorg = p4.xll+p4.xinches+spcx
	yorg = p4.yll+p4.yinches+spcy
	x0 = xorg+p4.xinches
	x1 = x0+1.
	y1 = yorg+p4.yinches-5./8.
	y0 = y1-(1.+5./8.)
				    ;
	xrast = lindgen(101,101)
	yrast = xrast/101
	xrast = xrast-yrast*101
	whr = where( ( (xrast-50)^2+(yrast-50)^2 le 50^2 ) $
         	and ( (xrast-50)^2+(yrast-50)^2 ge 25^2 ) )
	tmp0 = replicate(1000.,101,101)
	tmp0(whr) = atan( yrast(whr)-50, xrast(whr)-50 )
	tvasp, tmp0, /notv, bi=tmp, min=-!pi, max=!pi $
	, white=where( tmp0 eq 1000.), /wrap
	tv, tmp, x0, y0+5./16., xsize=1., ysize=1., /inches
				    ;
	plo, p4, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	plo, p4, [ x1-1./4., x1 ], y0+13./16
				    ;
	xyo, p4, charsize=2.0*.8, align=0.5 $
	, .5*(x1+x0), [ y0, y0+1.+5./16. ]+1./16. $
	, [ '270', '90' ]
				    ;
				    ;Plot color table for by_1incl.
				    ;
	xorg = p4.xll+p4.xinches+spcx
	yorg = p4.yll
	x0 = xorg+p4.xinches
	x1 = x0+.5
	y1 = yorg+p4.yinches-5./8.
	y0 = y1-(1.+5./8.)
				    ;
	xrast = lindgen(101,201)
	yrast = xrast/101
	xrast = xrast-yrast*101
	whr = where( ( xrast^2+(yrast-100)^2 le 100^2 ) $
         	and ( xrast^2+(yrast-100)^2 ge  50^2 ) )
	tmp0 = replicate(1000.,101,201)
	tmp0(whr) = atan( xrast(whr), yrast(whr)-100 )
	tvasp, tmp0, /notv, bi=tmp, min=0., max=!pi $
	, white=where( tmp0 eq 1000.)
	tv, tmp, x0, y0+5./16., xsize=.5, ysize=1., /inches
				    ;
	plo, p4, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	plo, p4, [ x1-1./4., x1 ], y0+13./16.
				    ;
	xyo, p4, charsize=2.0*.8, align=0.0 $
	, x0+.03, [ y0, y0+1.+5./16. ]+1./16. $
	, [ '180', '0' ]
				    ;
				    ;Output xy scale units.
				    ;
	xyo, p4, charsize=2.0, align=0.0 $
	, p4.xll+p4.xinches+.5*spcx+.25, p4.yorg-5./16. $
	, 'Megameters xy'
				    ;               N
				    ;Print symbol  E W
				    ;               S
	xyo, p4, charsize=2.0, align=.0 $
	, [ .220, .235, .000, .400 ]+p4.mrg_lft+p4.x_avail $
	, [ .500, .000, .250, .250 ]+yorg+p4.yinches $
	, [  'N',  'S',  'E',  'W' ]
				    ;
	device, /close_file
end
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Plot cct_fld file.
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
if   n_elements(by__cct) ne 0  and  n_elements(by_s_fld) ne 0  then begin
				    ;
				    ;Open postscript file and output
				    ;heading, date and op number.
				    ;
	ps_asp_open, p4, 'cct_fld'
				    ;
				    ;Output and annotate by__cct image.
				    ;
	p4.xorg = p4.xll
	p4.yorg = p4.yll+p4.yinches+spcy
	p4.xnumber = 1
	p4.ynumber = 1
	ps_asp_oimage, p4, by__cct, 'Continuum Intensity' $
	, null_vumbra, white $
	, vlaluz, white $
	, null_arrow, black, white
				    ;
				    ;Output and annotate by_fld image.
				    ;
	p4.xorg = p4.xll+p4.xinches+spcx
	p4.yorg = p4.yll+p4.yinches+spcy
	p4.xnumber = 0
	p4.ynumber = 0
	ps_asp_oimage, p4, by_s_fld, 'Field Magnitude (kGauss)' $
	, vumbra, white $
	, vlaluz, white $
	, arrow4, black, white
				    ;
				    ;Plot color bar for by_fld.
				    ;
	xorg = p4.xll+p4.xinches+spcx
	yorg = p4.yll+p4.yinches+spcy
	x0 = xorg+p4.xinches+1./8.
	x1 = x0+1./4.
	y0 = yorg+3./8.
	y1 = yorg+p4.yinches-3./8.
	tvasp, lindgen(10,100)/10, /notv, bi=tmp, /gray, invert=0
	tv, tmp, x0, y0, xsize=x1-x0, ysize=y1-y0, /inches
	plo, p4, [x0,x0,x1,x1,x0], [y0,y1,y1,y0,y0]
	xyo, p4, x0, [ y0-5./16., y1+1./32. ] $
	, [ '-'+field_max4, field_max4 ] $
	, charsize=2.0, align=0.0
				    ;
				    ;Print xy scale units.
				    ;
	xyo, p4 $
	, p4.xll+p4.xinches+.5*spcx+.25 $
	, p4.yll+p4.yinches+spcy-5./16. $
	, 'Megameters xy', charsize=2.0, align=0.0
				    ;               N
				    ;Print symbol  E W
				    ;               S
	xyo, p4, charsize=2.0, align=.0 $
	, [ .220, .235, .000, .400 ]+p4.mrg_lft+p4.x_avail $
	, [ .500, .000, .250, .250 ]+yorg-3./4. $
	, [  'N',  'S',  'E',  'W' ]
				    ;
	device, /close_file
end
				    ;
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;Return to X windows.
				    ;Restore old font setting.
				    ;
set_plot, 'x'
!p.thick = sav_p_thick
!p.font  = sav_p_font
if  w_sav ge 0  then  wset, w_sav
return
				    ;
end

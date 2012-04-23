pro ps_asp_usage
;+
;
;	procedure:  ps_asp
;
;	purpose:  from directory with a_* files plot some images in PostScript
;
;	routines:  ps_asp_usage   ps_asp_message   ps_asp_click
;		   ps_asp_extend  ps_asp_op        ps_asp_mm_inch
;		   ps_asp
;
;	author:  rob@ncar 1/93  paul@ncar 10/93
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:  ps_asp [, op [, dir ]]"
	print
	print, "	From directory with a_* files output PostScript"
	print, "	images cct.ps, fld.ps, 1azm.ps, 1incl.ps, flux.ps,"
	print, "	cen1.ps, and iiii.ps."
	print
	print, "	Arguments"
	print, "	    op		- operation number (def=none)"
	print, "	    dir		- directory path (string;"
	print, "			  def=use current working directory)"
	print
	print, "	Keywords "
	print, "	    pip_min	- polarization percent minimum"
	print, "			  for reversal line (def=.0)"
	print, "	    mm_per_inch - megameters per inch on"
	print, "			  color printer page (def=10.)"
	print, "	    date        - vector [month,day,year]"
	print
	print, "ex:"
	print, "	op = 7"
	print, "	dir = '/hilo/d/asp/data/red/92.06.19/op07'"
	print, "	ps_asp, op, dir, pip_min=.1"
	print
	print, "	;related UNIX"
	print, "	$ pageview -dpi 72 -left 1azm.ps &"
	print, "	$ lpr -Phaocolor 1azm.ps"
	print, "	$ hcprint *.ps ### high quality printing ###"
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	procedure:  ps_asp_message
;
;	purpose:  print or erase message on interactive image.
;
;------------------------------------------------------------------------------
pro ps_asp_message, ps, message
				    ;
white  = !d.n_colors-1
yellow = !d.n_colors-3 
black  = 0
				    ;
if n_elements(message) ne 0 then begin
	tv, replicate( yellow, ps.txdim, 28 ), 0, ps.tydim
	xyouts, ps.txdim/2, ps.tydim+8, message $
	, /device, align=0.5, charsize=1.4, color=black
return
end
				    ;
tv, replicate( white, ps.txdim, 28 ), 0, ps.tydim
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure:  ps_asp_click
;
;	purpose:  print or erase message on interactive image.
;
;------------------------------------------------------------------------------
pro ps_asp_click, x0, y0, ps, message
				    ;
ps_asp_message, ps, message
cursor, xc, yc, /up, /device
ps_asp_message, ps
				    ;
x0 = xc/ps.t
y0 = ( yc < (ps.tydim-1) ) / ps.t
				    ;
end
;------------------------------------------------------------------------------
;
;	function:  ps_asp_extend
;
;	purpose:  prompt user for file name extension
;
;------------------------------------------------------------------------------
function ps_asp_extend, ps
				    ;
				    ;Table of choices.
				    ;
table = $
[ 'ps0',      'ps1' $
, 'ps2',      'ps3' $
, 'ps4',      'ps5' $
, 'ps6',      'ps7' $
, 'ps8',      'ps9' $
, 'ps.rob',   'ps.paul' $
, 'ps.sku',   'ps.vmp' $
, 'ps.lites', 'ps.tomczyk' $
, 'ps',       'keyboard entry' $
]
				    ;
				    ;Pop up window with choices.
				    ;
ext = table( pop_cult( title='click on file name extension', table ) )
				    ;
				    ;Return click value if not keyboard entry.
				    ;
if  ext ne 'keyboard entry'  then  return, ext
				    ;
				    ;Prompt for keyboard entry.
				    ;
ps_asp_message, ps, 'Enter file name extension on keyboard'
on_ioerror, ioerror0
ioerror0:
ext = ''
read,'Enter file name extension--> ', ext
ps_asp_message, ps
return, ext
				    ;
end
;------------------------------------------------------------------------------
;
;	function:  ps_asp_op
;
;	purpose:  prompt user for op number
;
;------------------------------------------------------------------------------
function ps_asp_op, ps
				    ;
				    ;Pop up window with choices.
				    ;
	num = pop_cult( title='click on op number', $
	[ '0',  '1' $
	, '2',  '3' $
	, '4',  '5' $
	, '6',  '7' $
	, '8',  '9' $
	,'10', '11' $
	,'12', '13' $
	,'14', '15' $
	,'16', '17' $
	,'18', '19' $
	,'20', '21' $
	,'22', '23' $
	,'24', '25' $
	,'26', '27' $
	,'28', '29' $
	,'30', '31' $
	,'32', '33' $
	,'34', '35' $
	,'36', '37' $
	,'38', '39' $
	,'40', '41' $
	,'42', '43' $
	,'44', '45' $
	,'46', '47' $
	,'48', '49' $
	,'50', 'keyboard entry' $
	] )
				    ;
				    ;Return click value if not keyboard entry.
				    ;
	if  num le 50  then  return, num
				    ;
				    ;Prompt for keyboard entry.
				    ;
	ps_asp_message, ps, 'Enter op number on keyboard'
	on_ioerror, ioerror0
	ioerror0:
	num = 0L
	read,'Enter op number--> ', num
	ps_asp_message, ps
	return, num
				    ;
end
;------------------------------------------------------------------------------
;
;	function:  ps_asp_mm_inch
;
;	purpose:  prompt user for image scale in megameters/inch
;
;------------------------------------------------------------------------------
function ps_asp_mm_inch, ps
				    ;
				    ;Scale that will just fit.
				    ;
just = (ps.x_mm/ps.x_avail) > (ps.y_mm/ps.y_avail)
				    ;
				    ;
				    ;
whole = 'just fit '+stringit(just)
				    ;
				    ;Table of choices.
				    ;
table = $
[                   whole,            whole $
, 'standard 10.0', 'keyboard entry' $
]
				    ;
				    ;Pop up window with choices.
				    ;
scl = pop_cult( title='pick xy scale megameters/inch' , table )
				    ;
				    ;Return click value if not keyboard entry.
				    ;
if scl le 1  then return, just
if scl eq 2  then return, 10.
				    ;
				    ;Prompt for keyboard entry.
				    ;
ps_asp_message, ps, 'Enter megameters/inch scale on keyboard'
on_ioerror, ioerror0
ioerror0:
scl = 0L
read,'Enter megameters/inch--> ', scl
ps_asp_message, ps
return, scl
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure:  ps_asp
;
;	purpose:  from directory with a_* files plot some images in PostScript
;
;------------------------------------------------------------------------------
pro ps_asp, op, dir, dummy $
, pip_min=pip_min, mm_per_inch=mm_per_inch, date=date
				    ;
				    ;Check number of parameters.
				    ;
if n_params() gt 2 then begin
	ps_asp_usage
	return
end
				    ;
				    ;Save active window.
				    ;
w_sav = !d.window
				    ;
				    ;Isolate directory path.
				    ;
dty = ''
if n_elements(dir) ne 0 then  dty=dir
if dty ne '' then if strmid(dty,strlen(dty)-1,1) ne '/' then dty = dty+'/'
				    ;
				    ;Number of pixels/degree
				    ;
pix_degree = 50.
				    ;
				    ;Get the data into IDL.
				    ;
c__cct  = c_image( dty+'a__cct',  c_str=c, pix_deg=pix_degree )
c_fld   = c_image( dty+'a_fld',   c_str=c, /reuse             )
c_1azm  = c_image( dty+'a_1azm',  c_str=c, /reuse             )
c_1incl = c_image( dty+'a_1incl', c_str=c, /reuse             )
c_cen1  = c_image( dty+'a_cen1',  c_str=c, /reuse             )
c__pip  = c_image( dty+'a__pip',  c_str=c, /reuse             )
c_alpha = c_image( dty+'a_alpha', c_str=c, /reuse             )
				    ;
				    ;Get ps structure.
				    ;
ps_asp_str, c, ps
				    ;
				    ;Velocity of light (km/sec).
				    ;Initial guess for line center (pixel).
				    ;Dispersion (mA/pixel).
				    ;Line wavelength (A).
				    ;Velocity per pixel ((km/sec)/pixel). 
				    ;
cee          = 299792.458
cen0         = ps.head(36)
disper       = ps.head(39)
wavlth       = ps.head(40)
km_sec_pixel = disper*cee/(1000.*wavlth)
				    ;
				    ;Average fipsed line center (pixel).
				    ;
tmp = c_cen1(c.sxy)
cen_avg = total(tmp)/sizeof(tmp,1)
print
print, ' center initial guess ', cen0
print, 'fipsed center average ', cen_avg
				    ;
				    ;Display image magnification factor.
				    ;
t = ps.t
				    ;
				    ;Image dimensions.
				    ;
xdim  = ps.xdim
ydim  = ps.ydim
txdim = ps.txdim
tydim = ps.tydim
				    ;
				    ;Open window to display images.
				    ;
xpos = 100
ypos = 100
window, /free, xsize=txdim, ysize=tydim+28, xpos=xpos, ypos=ypos
w0 = !d.window
				    ;
				    ;Compute azimuth byte image by_1azm
				    ;
tvasp, c_1azm, 0, ydim $
, bi=by_1azm, min=-180., max=180. $
, white=c.sbkg, /wrap
				    ;
				    ;Compute inclination byte image by_1incl
				    ;
tvasp, c_1incl, xdim, ydim $
, bi=by_1incl, min=0., max=180. $
, white=c.sbkg
				    ;
				    ;Compute doppler byte image by_cen1
				    ;
tvasp, c_cen1, xdim, 0 $
, bi=by_cen1, min=cen_avg-2./km_sec_pixel, max=cen_avg+2./km_sec_pixel $
, white=c.sbkg, /invert
				    ;
				    ;Compute continuum byte image by__cct
				    ;
tvasp, c__cct, 0, 0 $
, bi=by__cct, min=c.cct_min, max=c.cct_max $
, white=c.pbkg, /gray
				    ;
				    ;Prompt for maximum field to display.
				    ;
ps.mxfld = 500L*( 1+pop_cult(title='Pick max field to display' $
, ['500','1000','1500','2000','2500','3000','3500' $
, 'standard 4000','4500','5000']+' gauss' ) )
				    ;
				    ;Compute field byte image by_fld
				    ;
tvasp, c_fld, 0, ydim $
, bi=by_fld, min=0., max=ps.mxfld $
, white=c.sbkg, /gray, /invert
				    ;
				    ;Compute signed field byte image by_s_fld
				    ;
tmp0 = c_fld
whr = where( c_1incl gt 90., nwhr )
if nwhr ne 0 then  tmp0(whr) = -tmp0(whr)
if sizeof(c.sbkg,0) ne 0 then  tmp0(c.sbkg)= 0.
tvasp, tmp0, xdim, ydim $
, bi=by_s_fld, min=-ps.mxfld, max=ps.mxfld $
, white=c.sbkg, /gray
				    ;
				    ;Compute flux byte image by_flux
				    ;
tmp0 = c_fld*cos(c_1incl*(!pi/180.))*(1.-c_alpha)
whr = where( tmp0 ge 0., nwhr )
if nwhr ne 0 then  tmp0(whr) = tmp0(whr)+ps.gap
tvasp, tmp0, xdim, 0 $
, bi=by_flux, min=-ps.mxfld, max=ps.mxfld+ps.gap $
, white=c.sbkg, /invert
				    ;
				    ;Display magnified continuum.
				    ;
tv, puff(by__cct,t), 0, 0
				    ;
				    ;Prompt for area of interest.
				    ;
ps_asp_click, x0, y0, ps, 'Click on area of interest'
ps.xctr = x0
ps.yctr = y0
				    ;
				    ;Plot ranges in megameters.
				    ;
ps.x_mm = (xdim-1.) / pix_degree * c.mm_per_deg
ps.y_mm = (ydim-1.) / pix_degree * c.mm_per_deg
				    ;
				    ;Set megameters per inch scale.
				    ;
if n_elements(mm_per_inch) ne 0 then begin
	ps.mm_per_inch = mm_per_inch
end else begin
	ps.mm_per_inch = ps_asp_mm_inch( ps )
end
				    ;
				    ;Prompt for Postscript file name extension.
				    ;
ps.cs_ext = ps_asp_extend( ps )
				    ;
				    ;Prompt for ASP op number.
				    ;
if n_elements(op) eq 0 then  op=ps_asp_op( ps )
				    ;
				    ;Prompt if user wants arrow points.
				    ;
ifarrow = 1-pop_cult(title='Want arrow points?', ['yes','no'])
				    ;
				    ;Set null highlights.
				    ;
umbra  = -1
laluz  = -1
				    ;
				    ;Prompt if user wants contours.
				    ;
want_reversal = 1-pop_cult(title='Want reversal line?',['yes','no'])
want_umbra    = 1-pop_cult(title='Want umbra contour?',['yes','no'])
				    ;
				    ;Prompt for umbra contour.
				    ;
get_umbra = want_umbra
while  get_umbra  do begin
				    ;
	if pop_cult(title='Want umbra by',['keyboard entry','click entry']) $
	then begin
		ps_asp_click, x0, y0, ps, 'Click on umbra contour'
		cctcon = long(c__cct(x0,y0))
	end else begin
		ps_asp_message, ps, 'Enter umbra contour on keyboard'
		on_ioerror, ioerror0
		ioerror0:
		cctcon = 0L
		read, 'Enter umbra contour--> ', cctcon
		ps_asp_message, ps
	end
	print, 'Umbra contour is', cctcon
				    ;
				    ;Compute umbra contour.
				    ;
	umbra = cont( c__cct, c.pxy, cctcon )
				    ;
				    ;Display magnified continuum.
				    ;
	red = !d.n_colors-4
	tmp = by__cct
	if sizeof(umbra,0) ne 0 then  tmp(umbra)=red
	tv, puff(tmp,t), 0, 0
				    ;
				    ;Prompt if umbra value is ok.
				    ;
	get_umbra = pop_cult(title='Umbra contour ok?',['yes','no'])
				    ;
end
				    ;
				    ;Set reversal contour.
				    ;
if  want_reversal  then begin
	if n_elements(pip_min) eq 0 then  pip_min = 0.0
	tmp = bytarr(xdim,ydim)
	tmp( c.sxy ) = 1
	if pip_min gt 0.0 then begin
		whr = where( c__pip lt pip_min, nwhr )
		if nwhr ne 0 then  tmp(whr) = 0
	end
	laluz = cont( c_1incl, where(tmp), 90. )
end
				    ;
ps_asp_message, ps, 'Program running to completion.'
				    ;
				    ;Output PostScript files.
				    ;
ps_asp_etc, ps, umbra, laluz, op $
, ifarrow, c_1azm, c_1incl, c.sxy, date=date $
, by__cct  = by__cct  $
, by_fld   = by_fld   $
, by_s_fld = by_s_fld $
, by_1azm  = by_1azm  $
, by_1incl = by_1incl $
, by_cen1  = by_cen1  $
, by_flux  = by_flux
				    ;
				    ;Restore active window.
				    ;
wdelete, w0
if w_sav gt -1 then  wset, w_sav
				    ;
end

pro azam_op, dty, aa, umbra, laluz, arrow
;+
;
;	procedure:  azam_op
;
;	purpose:  compute an azam structure for an ASP op and display window
;
;	author:  paul@ncar, 6/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 5 then begin
	print
	print, "usage:	azam_op, dty, aa, umbra, laluz, arrow"
	print
	print, "	Compute an azam structure for an ASP op and display"
	print, "	window."
	print
	print, "	Arguments"
	print, "		dty	- input directory path string"
	print, "		aa	- output azam data set structure"
	print, "		umbra	- output -1, null umbra hi light"
	print, "		laluz	- output -1, null hi light"
	print, "		arrow	- output null arrow structure"
	print
	return
endif
;-
				    ;
				    ;Common with info about tvasp color table
				    ;
@tvasp.com
				    ;
				    ;Set stretch flag.
				    ;
labels = [ 'yes', 'no', 'Must for PostScript' ]
if labels( pop_cult( title='Want stretched images?', labels ) ) $
eq 'no'  then  stretch=0L  else  stretch=1L
				    ;
				    ;Image magnification factor.
				    ;
t = 1L+pop_cult(title='Pick Magnification Factor',['1','2','3'])

				    ;Prompt for maximum field to display.
mxfld = 500L*( 1+pop_cult(title='Pick max field to display' $
, ['500','1000','1500','2000','2500','3000','3500' $
, '4000','4500','5000']+' gauss' ) )
				    ;Right margin for cursor offset.
rmg = 28L
				    ;Read azimuth data.
				    ;Default 50. pixels per degree is used.
if stretch $
then  b_azm = c_image( dty+'a_azm', c_str=b ) $
else  b_azm = b_image( dty+'a_azm', b_str=b )

				    ;Read longitude and latitude.
tmp  = read_floats( dty+'a__longitude' )
tmp0 = read_floats( dty+'a__latitude'  )

				    ;Replace longitude by approximate great
				    ;circle angles.
lng_min = min( tmp, max=lng_max )
tmp = (tmp-.5*(lng_min+lng_max))*cos((!pi/180.)*tmp0)

				    ;Form 2D images of east-west and latitude.
b__e_w = fltarr(b.xdim,b.ydim)  &  b__e_w(b.pxy) = tmp( b.vec_pxy)
b__lat = fltarr(b.xdim,b.ydim)  &  b__lat(b.pxy) = tmp0(b.vec_pxy)

				    ;For unstretched images find what would
				    ;be the angle CCW to the local frame x
				    ;axis.
angxloc = 0.
if stretch eq 0 then begin
	i0 = b.xdim/2
	j0 = b.ydim/2
	angxloc = atan( b__lat(i0+1,j0)-b__lat(i0,j0) $
	              , b__e_w(i0+1,j0)-b__e_w(i0,j0) )*(180./!pi)
	print
	print, 'Angle CCW to stretched display is about', angxloc
end
				    ;Read local azimuth & local inclination.
b_1azm  = s_image( dty+'a_1azm',  b          )
b_1incl = s_image( dty+'a_1incl', b, bkg=90. )

				    ;Byte images of azimuth & local azimuth.
if 1 or (angxloc eq 0.) then begin
	tvasp, b_azm $
	, min=-180., max=180., /notv, bi=azm,   white=b.sbkg, /wrap
	tvasp, b_1azm $
	, min=-180., max=180., /notv, bi=azm1,  white=b.sbkg, /wrap
end else begin
	tvasp, azam_azm_off( b_azm,  angxloc ) $
	, min=-180., max=180., /notv, bi=azm,   white=b.sbkg, /wrap
	tvasp, azam_azm_off( b_1azm, angxloc ) $
	, min=-180., max=180., /notv, bi=azm1,  white=b.sbkg, /wrap
end
				    ;Byte image local inclination.
tvasp, b_1incl, min=0.,    max=180., /notv, bi=incl1, white=b.sbkg

				    ;Set some display parameters.
xdim = b.xdim
ydim = b.ydim
blt = 100L
bwd = 20L
xsize = t*xdim+rmg
				    ;Open windows to display interactive
				    ;images with margin.
window, /free, xsize=xsize, ysize=t*ydim, title=dty $
, xpos=(xsize+8)<(1144-(t*xdim+rmg)), ypos=900-(t*ydim+66)
win1  = !d.window

window, /free, xsize=xsize, ysize=t*ydim, title=dty $
, xpos=0, ypos=900-(t*ydim+66)
win0  = !d.window
				    ;Open ascii and button window
				    ;on first entry.
common common_ab, wina, winb
if wina eq -1 then begin
				    ;Open ascii window.
	window, /free, xsize=3*blt+10, ysize=11*bwd, xpos=250, ypos=40
	wina = !d.window
				    ;Open button window.
	window, /free, xsize=6*blt, ysize=3*bwd, xpos=0, ypos=900-3*bwd
	winb = !d.window
end
wshow, wina
				    ;Create azam structure.
aa = $
{ index:	2L $
, stretch:	stretch $
, angxloc:	angxloc $
, npoints:	b.npoints $
, nsolved:	b.nsolved $
, xdim:		xdim $
, ydim:		ydim $
, pxy:		b.pxy $
, sxy:		b.sxy $
, op:		-1L $
, head:		b.head $
, vec_pxy:	b.vec_pxy $
, vec_sxy:	b.vec_sxy $
, cct_min:	b.cct_min $
, cct_max:	b.cct_max $
, mxfld:	mxfld $
, mm_per_deg:	b.mm_per_deg $
, win0:		win0 $
, win1:		win1 $
, wina:		wina $
, winb:		winb $
, bx:		-1L $
, by:		-1L $
, bs:		0L $
, white:	tvasp.ix_white $
, yellow:	tvasp.ix_yellow $
, red:		tvasp.ix_red $
, black:	tvasp.ix_black $
, cen_lat:	0. $
, cen_e_w:	0. $
, pix_deg:	b.pix_deg $
, zoom:		0L $
, x0:		0L $
, y0:		0L $
, xy5000:	replicate(-1L,xdim,ydim) $
, umb_lvl:	-1L $
, b_azm:	b_azm $
, b_amb:	fltarr(xdim,ydim) $
, b_1azm:	b_1azm $
, b_1incl:	b_1incl $
, b__cct:	s_image( dty+'a__cct',  b          ) $
, b_fld:	s_image( dty+'a_fld',   b          ) $
, b_psi:	s_image( dty+'a_psi',   b          ) $
, b_2azm:	s_image( dty+'a_2azm',  b          ) $
, b_2incl:	s_image( dty+'a_2incl', b, bkg=90. ) $
, b_cen1:	s_image( dty+'a_cen1',  b          ) $
, b_alpha:	s_image( dty+'a_alpha', b, bkg=1.  ) $
, b__lat:	b__lat $
, b__e_w:	b__e_w $
, azm:		azm $
, azm1:		azm1 $
, incl1:	incl1 $
, cct:		bytarr(xdim,ydim,/nozero) $
, fld:		bytarr(xdim,ydim,/nozero) $
, psi:		bytarr(xdim,ydim,/nozero) $
, amb:		bytarr(xdim,ydim,/nozero) $
, azm2:		bytarr(xdim,ydim,/nozero) $
, incl2:	bytarr(xdim,ydim,/nozero) $
, cen1:		bytarr(xdim,ydim,/nozero) $
, alpha:	bytarr(xdim,ydim,/nozero) $
, sdat:		bytarr(xdim,ydim) $
, azm_o:	azm $
, azm_r:	azm $
, img0:		puff( azm1,t) $
, img1:		puff(incl1,t) $
, blt:		blt $
, bwd:		bwd $
, xsize:	xsize $
, t:		t $
, t0:		t $
, rmg:          rmg $
, pwr:		3L $
, b_cust:	fltarr(xdim,ydim) $
, cust:		bytarr(xdim,ydim,/nozero) $
, custnp:	0L $
, custmin:	0. $
, custmax:	0. $
, custgray:	0L $
, custwrap:	0L $
, custinv:	0L $
, custback:	0L $
, custname:	'' $
, axa:		'8x8' $
, lock:		'mouse lock' $
, cri:		'reference' $
, anti:		'anti reference' $
, prime:	'wads' $
, name0:	'local azimuth' $
, name1:	'local incline' $
, drag0:	'local azimuth' $
, drag1:	'local incline' $
, hilite:	'ambigs' $
, spectra:	'' $
, dty:		dty $
}
				    ;Logical 2D array for solved data points.
aa.sdat(b.sxy) = 1
				    ;Compute ambigs hilite.
azam_ambigs, b_azm, aa.sdat, t, laluz, nwhr
if nwhr ne 0 then begin
	aa.img0(laluz) = aa.black
	aa.img1(laluz) = aa.black
end
				    ;Display local azimuth and inclination.
wset, win1  &  tv, aa.img1, 0, 0
wset, win0  &  tv, aa.img0, 0, 0
				    ;Set null highlight arrays.
umbra = -1
arrow = { hi:-1, lo:-1 }
				    ;Set ambiguous azimuth (-180. to 180.).
aa.b_amb = (((b_azm+360.) mod 360.)-180.)*aa.sdat

				    ;Form array for raster point numbers.
aa.xy5000(aa.pxy) = 5000*b.ypnt(b.vec_pxy)+b.xpnt(b.vec_pxy)

				    ;Velocity of light (km/sec).
				    ;Initial guess for line center (pixel).
				    ;Dispersion (mA/pixel).
				    ;Line wavelength (A).
				    ;Velocity per pixel ((km/sec)/pixel). 
cee          = 299792.458
cen0         = b.head(36)
disper       = b.head(39)
wavlth       = b.head(40)
km_sec_pixel = disper*cee/(1000.*wavlth)

				    ;Compute doppler shift.
tmp = aa.b_cen1(aa.sxy)
cen_avg = total(tmp)/n_elements(tmp)
aa.b_cen1(aa.sxy) = -(aa.b_cen1(aa.sxy)-cen_avg)*km_sec_pixel
print
print, ' initial center guess ', cen0
print, 'average fitted center ', cen_avg

				    ;Compute byte images.
tvasp, aa.b__cct,  min=b.cct_min, max=b.cct_max $
, /notv, bi=tmp, white=b.pbkg, /gray
aa.cct = tmp

tvasp, aa.b_fld,   min=0., max=mxfld $
, /notv, bi=tmp, white=b.sbkg, /gray, /invert
aa.fld   = tmp

tvasp, aa.b_psi,   min=0., max=180. $
, /notv, bi=tmp, white=b.sbkg
aa.psi    = tmp

tvasp, aa.b_2incl, min=0., max=180. $
, /notv, bi=tmp, white=b.sbkg
aa.incl2  = tmp

tvasp, aa.b_cen1,  min=-2., max=2. $
, /notv, bi=tmp, white=b.sbkg
aa.cen1   = tmp

tvasp, aa.b_alpha, min=0., max=1.$
, /notv, bi=tmp, black=b.sbkg, /gray, /invert
aa.alpha  = tmp

if 1 or (angxloc eq 0.) then begin

	tvasp, aa.b_amb $
	, min=-180., max=180. $
	, /notv, bi=tmp, white=b.sbkg, /wrap
	aa.amb    = tmp

	tvasp, aa.b_2azm $
	, min=-180., max=180. $
	, /notv, bi=tmp, white=b.sbkg, /wrap
	aa.azm2   = tmp

end else begin

	tvasp, azam_azm_off( aa.b_amb, angxloc ) $
	, min=-180., max=180. $
	, /notv, bi=tmp, white=b.sbkg, /wrap
	aa.amb    = tmp

	tvasp, azam_azm_off( aa.b_2azm, angxloc ) $
	, min=-180., max=180. $
	, /notv, bi=tmp, white=b.sbkg, /wrap
	aa.azm2   = tmp
end
				    ;Set custom image to flux.
void, azam_image( 'SET flux', aa, umbra, laluz, arrow )

				    ;Prompt for azimuth center.
azam_click_xy, aa, 'Click on azimuth center', xcen, ycen
aa.cen_lat = aa.b__lat(xcen,ycen)
aa.cen_e_w = aa.b__e_w(xcen,ycen)
				    ;Instructions.
azam_help

end

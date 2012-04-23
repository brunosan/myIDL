pro azam_bulk_usage
;+
;
;	procedure:  azam_bulk
;
;	purpose:  do bulk of processing for 'azam.pro'
;
;	routines:  azam_bulk_usage  azam_b_menu  azam_bulk
;
;	author:  paul@ncar, 6/94	(minor mod's by rob@ncar)
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	azam_bulk, aa, umbra, laluz, arrow, now_what"
	print
	print, "	Do bulk of processing for 'azam.pro'."
	print
	print, "	Arguments"
	print, "		aa	- I/O azam data set structure"
	print, "		umbra	- I/O where array for umbra hi light"
	print, "		laluz	- I/O where array for active hi light"
	print, "		arrow	- I/O arrow point structure."
	print, "		now_what- returned ascii string request"
	print
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	procedure:  azam_b_menu
;
;	purpose:  process clicks on azam button window
;
;------------------------------------------------------------------------------
pro azam_b_menu, aa, umbra, laluz, arrow, now_what

				    ;Set null return.
now_what = 'null'
				    ;Done if no mouse button pressed.
if aa.bs eq 0 then return
				    ;Set button number.
bttn = 6*(aa.by/aa.bwd)+aa.bx/aa.blt

				    ;Check if button is active.
if aa.zoom ne 0 then begin
	if bttn eq  5 then return
	if bttn eq 17 then return
end
if total( bttn eq [4,5,6,7,8,9,10,12,13,15,17] ) eq 0 then  return

				    ;Set that some action taken.
now_what = 'something else'
				    ;Erase button window.
erase, aa.black 

case 1 of 
				    ;Do menu options.
bttn eq 4: azam_menu, aa, umbra, laluz, arrow, now_what

				    ;Write BACKUP file.
bttn eq 5: begin
	if  aa.zoom eq 0  then $
	i = write_floats( aa.dty+'BACKUP', azam_a_azm(aa) )
	azam_message, aa, 'BACKUP file written'
	end
				    ;Change flip criteria.
bttn eq 6 or bttn eq 7: begin
	tmp = [ 'anti azimuth', 'unoriginal', 'anti reference' $
	,    'smooth','horizontal']
	whr = where( aa.anti eq tmp )
	whr = (whr(0)+1) mod 5
	aa.anti = tmp(whr)
	tmp = [      'azimuth',   'original',      'reference' $
	, 'reference',   'up down']
	aa.cri = tmp(whr)
	end
				    ;Change right buttom effect.
bttn eq 8: begin
	tmp = ['wads','smooth','ongoing','average']
	whr = where( aa.prime eq tmp )
	whr = (whr(0)+1) mod 4
	aa.prime = tmp(whr)
	end
				    ;Change azimuth window drag effect.
bttn eq 9: begin
	tmp = ['local azimuth','sight azimuth' $
	,'continuum','field','doppler','fill']
	whr = where( aa.drag0 eq tmp )
	whr = (whr(0)+1) mod 6
	aa.drag0 = tmp(whr)
	aa.prime = 'ongoing'
	end
				    ;Change incline window drag effect.
bttn eq 10: begin
	tmp = ['local incline','sight incline' $
	,'continuum','field','doppler','fill']
	whr = where( aa.drag1 eq tmp )
	whr = (whr(0)+1) mod 6
	aa.drag1 = tmp(whr)
	aa.prime = 'ongoing'
	end
				    ;Change of sub array size.
bttn eq 12: begin
	tmp = ['1x1','2x2','4x4','8x8','16x16']
	aa.pwr = (aa.pwr+1) mod 5
	aa.axa = tmp(aa.pwr)
	end
				    ;Lock or unlock mouse buttons.
bttn eq 13: if aa.lock eq 'unlock' $
	then aa.lock='mouse lock' $
	else aa.lock='unlock'
				    ;Set reference image & inform user.
bttn eq 15: begin
	aa.azm_r = aa.azm
	azam_message, aa, 'Reference image reset'
	end
				    ;Return if other op button was clicked.
bttn eq 17: now_what = 'other op'

else:
end

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_bulk
;
;	purpose:  do bulk of processing for 'azam.pro'
;
;------------------------------------------------------------------------------
pro azam_bulk, aa, umbra, laluz, arrow, now_what

				    ;Check number of parameters.
if n_params() eq 0 then begin
	azam_bulk_usage
	return
end
				    ;Reset some variables.
t      = aa.t
xdim   = aa.xdim
ydim   = aa.ydim
yellow = aa.yellow
black  = aa.black
white  = aa.white
				    ;Display azam buttons.
azam_bttn, aa
				    ;Numbers saved to check that cursor
				    ;has changed.
xsav = -1
ysav = -1
ssav = -1
slock =  0
				    ;Infinite loop till -EXIT-.
infinity:
				    ;Do computed cursor.
azam_cursor, aa, xerase, yerase $
, aa.win0, aa.win1, undef, undef, undef $
,   undef,   undef, undef, undef, undef $
, eraser0, eraser1, undef, undef, undef $
, xc, yc, state $
, likely=likely $
, maybe=[aa.win0,aa.win1] $
, no_ttack=no_ttack
				    ;Check if cursor is off images.
if xc eq -1 then begin
				    ;Delay if cursor is also off
				    ;button window.
	if aa.bx eq -1 then begin
		wait, .25
		goto, infinity
	end
				    ;Process interaction with button window.
	azam_b_menu, aa, umbra, laluz, arrow, now_what

				    ;Process returned instruction string.
	case now_what of
	'zoom'		: return
	'replace op'	: return
	'other op'	: return
	'-EXIT-'	: return
	'-RETURN-'	: return
	'null'		:
	else: begin
				    ;Remove state lock.
		slock = 0
		no_ttack = 0
				    ;Display azam buttons.
		azam_bttn, aa
		end
	end
	goto, infinity
end
				    ;Remove multi button states.
tmp = [0,1,2,1,4,1,2,1]
state = tmp(state)
				    ;Set state lock.
if aa.lock eq 'unlock' then begin
	slock = 0
end else if state eq 0 then begin
	state = slock
end else if slock eq 0 then begin
	slock = state
	wset, likely
	repeat	cursor, xxxx, yyyy, /device, /nowait  until  !err eq 0
end else begin
	state = 0
	slock = 0
	xc = -1
	ssav = -1
	wset, likely
	repeat	cursor, xxxx, yyyy, /device, /nowait  until  !err eq 0
	goto, infinity
end
				    ;Check if point number or mouse
				    ;button state has changed.
if  xc eq xsav  and  yc eq ysav  and  ssav eq state  then begin
	if n_elements(sum_same) eq 0 then  sum_same=0
	sum_same = (sum_same+1) < 1000
	if sum_same eq 1000 then  wait, .25
	goto, infinity
end
sum_same = 0
				    ;Save status to prevent reentry.
xsav = xc
ysav = yc
ssav = state
				    ;No image changes if state is zero.
if state eq 0 then begin
	if no_ttack then xc=-1
	no_ttack = 0
	goto, infinity
end
				    ;Erase ascii window.
if no_ttack eq 0 then begin
	wset, aa.wina
	erase, aa.black
end
				    ;Flag computed cursor routine not to
				    ;display thumb tack cursor.
no_ttack = 1
				    ;Set cat after the mouse.
case state of
1:	cat = aa.cri
2:	cat = aa.anti
else:	cat = aa.prime
end
				    ;Use at least 4x4 area for point to point.
if aa.pwr lt 2 then $
if cat eq 'wads' or cat eq 'smooth' then begin
	aa.pwr = 2
	aa.axa = '4x4'
	azam_bttn, aa
end
				    ;(x,y) ranges for area about cursor.
hlf = (2^aa.pwr)/2
x0 =  0 > (xc-hlf)
y0 =  0 > (yc-hlf)
x1 = x0 > (xc+hlf-1) < (xdim-1)
y1 = y0 > (yc+hlf-1) < (ydim-1)
				    ;Data locations about cursor location.
cr_sdat  = aa.sdat(x0:x1,y0:y1)
				    ;Initialize number azimuth flips to zero.
nchg = 0
avg = 0
				    ;Check for anti criteria.
anti = 1
case cat of
'anti azimuth':		cat  = 'azimuth'
'unoriginal':		cat  = 'original'
'anti reference':	cat  = 'reference'
'horizontal':		cat  = 'up down'
else:			anti = 0
end
				    ;Feed the cat.
case cat of
				    ;Find likely point to point ambigs.
'wads': chg = azam_wads( aa.b_azm(x0:x1,y0:y1) $
	, aa.b_fld(x0:x1,y0:y1), aa.b_psi(x0:x1,y0:y1) $
	, cr_sdat, nchg ) 
				    ;Find likely point to point ambigs.
'smooth': chg = azam_smooth( aa.b_azm(x0:x1,y0:y1) $
	, aa.b_fld(x0:x1,y0:y1), aa.b_psi(x0:x1,y0:y1) $
	, cr_sdat, nchg, x0, y0, aa.xdim, aa.ydim )

				    ;Print averages about cursor.
'average': begin
	avg = 1
	azam_average, aa, xc,yc, x0,y0, x1,y1
	end
				    ;Do azimuth flip criteria.
'azimuth': begin
				    ;Azimuth based on latitude and longitude.
	az0 = atan( $
	  (aa.b__lat(x0:x1,y0:y1)-aa.cen_lat) $
	, (aa.b__e_w(x0:x1,y0:y1)-aa.cen_e_w) $
	) *180./!pi
				    ;Chosen azimuth relative to
				    ;radial azimuth. 
	azm1 = aa.b_1azm(x0:x1,y0:y1)
	az1 = (azm1-az0+360.) mod 360.
	whr = where( az1 gt 180., nwhr )
	if nwhr ne 0 then  az1(whr) = az1(whr)-360.

				    ;Alternate azimuth relative to
				    ;radial azimuth. 
	azm2 = aa.b_2azm(x0:x1,y0:y1)
	az2 = (azm2-az0+360.) mod 360.
	whr = where( az2 gt 180., nwhr )
	if nwhr ne 0 then  az2(whr) = az2(whr)-360.

				    ;Pick closest azimuth.
	chg = where( abs(az2) lt abs(az1), nchg )
        end
				    ;Pick most radial inclination.
'up down': chg = where( $
	abs( aa.b_2incl(x0:x1,y0:y1)-90.) $
	gt abs( aa.b_1incl(x0:x1,y0:y1)-90.), nchg )

				    ;Pick original azimuth.
'original': chg = where( $
	aa.azm( x0:x1,y0:y1) ne aa.azm_o(x0:x1,y0:y1), nchg )

				    ;Pick reference azimuth.
'reference': chg = where( $
	aa.azm( x0:x1,y0:y1) ne aa.azm_r(x0:x1,y0:y1), nchg )
else:
end
				    ;Reverse for anti criteria.
if anti then begin
	tmp = cr_sdat
	if nchg ne 0 then  tmp(chg) = 0
	chg = where( tmp, nchg )
end
				    ;Do azimuth flips if any.
if  nchg ne 0 then begin
	xdm  = x1-x0+1
	ychg = chg/xdm
	xchg = chg-ychg*xdm
	azam_flipa, aa, (y0+ychg)*xdim+(x0+xchg)
end
				    ;Set sub images to drag on display.
luz0 = black
luz1 = black
if avg eq 0 then begin

	case aa.drag0 of
	'local azimuth': begin
		luz0 = black
		new0 = aa.azm1(x0:x1,y0:y1)
		end
	'sight azimuth': begin
		luz0 = black
		new0 = aa.azm(x0:x1,y0:y1)
		end
	'continuum': begin
		luz0 = yellow
		new0 = aa.cct(x0:x1,y0:y1)
		end
	'field': begin
		luz0 = yellow
		new0 = aa.fld(x0:x1,y0:y1)
		end
	'doppler': begin
		luz0 = black
		new0 = aa.cen1(x0:x1,y0:y1)
		end
	'fill': begin
		luz0 = yellow
		new0 = aa.alpha(x0:x1,y0:y1)
		end
	end

	case aa.drag1 of
	'local incline': begin
		luz1 = black
		new1 = aa.incl1(x0:x1,y0:y1)
		end
	'sight incline': begin
		luz1 = black
		new1 = aa.psi(x0:x1,y0:y1)
		end
	'continuum': begin
		luz1 = yellow
		new1 = aa.cct(x0:x1,y0:y1)
		end
	'field': begin
		luz1 = yellow
		new1 = aa.fld(x0:x1,y0:y1)
		end
	'doppler': begin
		luz1 = black
		new1 = aa.cen1(x0:x1,y0:y1)
		end
	'fill': begin
		luz1 = yellow
		new1 = aa.alpha(x0:x1,y0:y1)
		end
	end
				    ;Update core interactive images.
	tx0 = t*x0  &  tx1 = t*x1+t-1
	ty0 = t*y0  &  ty1 = t*y1+t-1
	aa.img0(tx0:tx1,ty0:ty1) = puff(new0,t)
	aa.img1(tx0:tx1,ty0:ty1) = puff(new1,t)
end
				    ;Get data and image bounds with one
				    ;pixel margin.
xb0  = 0 > (x0-1)
yb0  = 0 > (y0-1)
xb1  = (x1+1) < (xdim-1)
yb1  = (y1+1) < (ydim-1)
txb0 = t*xb0
tyb0 = t*yb0
txb1 = t*xb1+t-1
tyb1 = t*yb1+t-1
xdm  = txb1-txb0+1
ydm  = tyb1-tyb0+1
ll   = t-1
xr   = xdm-t
yu   = ydm-t
				    ;Get images for computed cursor.
xers = txb0
yers = tyb0
ers0 = aa.img0(txb0:txb1,tyb0:tyb1)
ers1 = aa.img1(txb0:txb1,tyb0:tyb1)
new0 = ers0
new1 = ers1
				    ;Do cursor ambigs calculation.
if avg eq 0 then begin
	azam_ambigs, aa.b_azm(xb0:xb1,yb0:yb1), aa.sdat(xb0:xb1,yb0:yb1) $
	, t, amb, namb
	if namb ne 0 then begin
		new0(amb) = luz0
		new1(amb) = luz1
		ers0(ll:xr,ll:yu) = new0(ll:xr,ll:yu)
		ers1(ll:xr,ll:yu) = new1(ll:xr,ll:yu)
		aa.img0(txb0:txb1,tyb0:tyb1) = ers0
		aa.img1(txb0:txb1,tyb0:tyb1) = ers1
		new0 = ers0
		new1 = ers1
	end
end
				    ;Place box around computed cursors.
if avg then begin
	new0(*,*) = yellow
	new1(*,*) = yellow
end
new0(ll:xr,ll:yu) = luz0
new1(ll:xr,ll:yu) = luz1
imn= (ll+1)<(xr-1)
imx= (ll+1)>(xr-1)
jmn= (ll+1)<(yu-1)
jmx= (ll+1)>(yu-1)
new0(imn:imx,jmn:jmx) = ers0(imn:imx,jmn:jmx)
new1(imn:imx,jmn:jmx) = ers1(imn:imx,jmn:jmx)

				    ;Erase old computed cursors.
if xerase ge 0 then begin
	tw, aa.win0, eraser0, xerase, yerase
	tw, aa.win1, eraser1, xerase, yerase
end
				    ;Display computed cursors.
eraser0 = ers0
eraser1 = ers1
xerase  = xers
yerase  = yers
tw, aa.win0, new0, xerase, yerase
tw, aa.win1, new1, xerase, yerase

goto, infinity

end

pro field_scale, cct_min, cct_max, title=title, mxfld=mxfld, window=window
;+
;
;	procedure:  field_scale
;
;	purpose:  create window with scales of field_plot displays
;
;	author:  paul@ncar, 5/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:	field_scale, cct_min, cct_max"
	print
	print, "	Arguments"
	print, "		cct_min	- minimun for continuum scale"
	print, "		cct_max	- maximun for continuum scale"
	print, "	Keywords"
	print, "		title	- title for window"
	print, "			  (def 'field_scale')"
	print, "		mxfld	- max field displayed, gauss"
	print, "			  (def 4000)"
	print, "		window	- index of opened free window"
	print
	return
endif
;-
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Save active window number.
			;
w_sav = !d.window
			;
			;Open window.
			;
xsize = 300
ysize = 300
mrg = 16
if  n_elements(title) eq 0  then  title='field_scale'
window,  /free, xsize=xsize, ysize=ysize, title=title $
, xpos=1144-xsize, ypos=900-ysize
window = !d.window
erase, !d.n_colors-1
			;
			;Label the window.
			;
xyouts, /device, align=0.5, charsize=1.4, color=0 $
,[     xsize/6,   xsize/2, xsize*5/6,     xsize/4,     xsize*3/4 ] $
,[   ysize-mrg, ysize-mrg, ysize-mrg, ysize/2-mrg,   ysize/2-mrg ] $
,[ 'Continuum',   'Field', 'Doppler',   'Azimuth', 'Inclination' ]
			;
			;Display continuum scale.
			;
xdim = 40
ydim = ysize/2-3*mrg
xrast = lindgen(xdim,ydim)
yrast = xrast/xdim
xrast = xrast-yrast*xdim
tvasp, yrast, xsize/6-xdim/2, ysize/2+mrg, /gray
cmin = strcompress(string(cct_min,format='(i10)'))
cmax = strcompress(string(cct_max,format='(i10)'))
xyouts, /device, align=0.5, charsize=1.4, color=0 $
,xsize/6 $
,[ ysize/2, ysize-2*mrg	]+2 $
,[    cmin,        cmax ]
			;
			;Display field strength scale.
			;
if n_elements(mxfld) eq 0 then  mxfld=4000
tvasp, yrast, xsize/2-xdim/2, ysize/2+mrg, /gray, /invert
xyouts, /device, align=0.5, charsize=1.4, color=0 $
,xsize/2 $
,[ ysize/2,     ysize-2*mrg ]+2 $
,[     '0', stringit(mxfld) ]
			;
			;Display doppler scale.
			;
tvasp, yrast, xsize*5/6-xdim/2, ysize/2+mrg
xyouts, /device, align=0.5, charsize=1.4, color=0 $
,xsize*5/6 $
,[     ysize/2, ysize-2*mrg ]+2 $
,[ '-2 km/sec',  '2 km/sec' ]
			;
			;Display azimuth scale.
			;
xdim= xsize/2-3*mrg
ydim= xdim
xrast = lindgen(xdim,ydim)
yrast = xrast/xdim
xrast = xrast-yrast*xdim
tmp = replicate(1000.,xdim,ydim)
whr = where( (xrast-xdim/2)^2+(yrast-ydim/2)^2 le (xdim/2)^2 )
tmp(whr) = atan( yrast(whr)-ydim/2, xrast(whr)-xdim/2 )
tvasp, tmp, xsize/4-xdim/2, mrg $
, min=-!pi, max=!pi, /wrap, white=where(tmp eq 1000.)
xyouts, /device, align=0.5, charsize=1.4, color=0 $
, xsize/4 $
,[ mrg+ydim,     0 ]+2 $
,[     '90', '270' ]
xyouts, /device, align=0.0, charsize=1.4, color=0 $
,[     0, xsize/4+xdim/2 ] $
, mrg+ydim/2-4 $
,[ '180',           ' 0' ]
			;
			;Display inclination scale.
			;
tmp = replicate(1000.,xdim,ydim)
whr = where( (xrast)^2+(yrast-ydim/2)^2 le (xdim/2)^2 )
tmp(whr) = atan( xrast(whr), yrast(whr)-ydim/2 )
tvasp, tmp, xsize*3./4.-xdim/4, mrg $
, min=0., max=!pi, white=where(tmp eq 1000.)
xyouts, /device, align=.0, charsize=1.4, color=0 $
,[ xsize*3/4-xdim/4, xsize*3/4+xdim/4, xsize*3/4-xdim/4 ] $
,[       mrg+ydim+2,     mrg+ydim/2-4,                2 ] $
,[	        '0',		' 90',            '180' ]
			;
			;Restore active window.
			;
wshow,!d.window,0
if  w_sav ne -1  then  wset, w_sav
			;
end

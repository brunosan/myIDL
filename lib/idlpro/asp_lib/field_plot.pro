pro field_plot				$
, b__cct,    b_fld,     b_psi,   b_azm	$
, b_1incl,  b_1azm,   b_2incl,  b_2azm	$
, b					$
, profile    = profile			$
, highlight  = highlight		$
, wdx	     = wdx
;+
;
;	procedure:  field_plot
;
;	purpose:  display b_* or c_* field images
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	; Display 2D magnetic field images."
	print, "	field_plot, b__cct,  b_fld,  b_psi,   b_azm,  $"
	print, "		    b_1incl, b_1azm, b_2incl, b_2azm, b"
	print
	print, "	; Display stretched 2D magnetic field images."
	print, "	field_plot, c__cct,  c_fld,  c_psi,   c_azm,  $"
	print, "		    c_1incl, c_1azm, c_2incl, c_2azm, c"
	print
	print, "	Arguments"
	print, "		b__cct	- 2D array of continuum"
	print, "		b_fld	- 2D array of magnetic field values"
	print, "			  (Gauss)"
	print, "		b_psi	- 2D array of inclination from line"
	print, "			  of sight (0. to 180.)"
	print, "		b_azm	- 2D array of azimuth ccw from normal"
	print, "			  to elevation mirror (-180. to 180.)"
	print, "		b_1incl	- 2D array of inclination from"
	print, "			  solar surface normal (0. to 180.)"
	print, "		b_1azm	- 2D array of azimuth from"
	print, "			  solar west (-180. to 180.)"
	print, "		b_2incl	- (ambigous inclination and azimuth)"
	print, "		b_2azm"
	print, "		b	- structure for data and directory"
	print
	print, "	Keywords"
	print, "		highlight - where() array to highlight display"
	print, "			    (def=no highlighting)"
	print, "		profile	- if set, to invoke PROFILES procedure"
	print, "			  (def=do profile)"
	print, "		wdx	- output array of 2 window numbers"
	print, "			  chosen by free selection"
	print, "			  (def, not output)"
	return
endif
;-
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Open 2 windows to display 4 images each.
			;
wdx = [ 0, 0 ]
xmrg = (124-b.xdim) > 24
xfrm = xmrg+b.xdim
ymrg = (124-b.ydim) > 24
yfrm = ymrg+b.ydim
window,  /free, xsize=xmrg+2*xfrm, ysize=ymrg+2*yfrm $
, xpos=0, ypos=900-(ymrg+2*yfrm)
wdx(0) = !d.window
erase, !d.n_colors-1
window,  /free, xsize=xmrg+2*xfrm, ysize=ymrg+2*yfrm $
, xpos=1144-(xmrg+2*xfrm), ypos=100
wdx(1) = !d.window
erase, !d.n_colors-1
			;
			;Label the windows.
			;
yl = indgen(4)/2
xl = indgen(4)-2*yl
			;
wset, wdx(0)
xyouts, /device, align=.5, charsize=1.4, color=0 $
, xmrg+xl*xfrm+b.xdim/2, (yl+1)*yfrm+4 $
, $
[   'Azimuth',  'Inclination' $
, 'Continuum',        'Field' $
]
xyouts, /device, align=1., charsize=1.4, color=0, orient=90. $
, xmrg+xl*xfrm-4, (yl+1)*yfrm $
, $
[ 'line of sight', 'line of sight' $
,              '',              '' $
]
			;
wset, wdx(1)
xyouts, /device, align=.5, charsize=1.4, color=0 $
, xmrg+xl*xfrm+b.xdim/2, (yl+1)*yfrm+4 $
, $
[ 'Azimuth',  'Inclination' $
, 'Azimuth',  'Inclination' $
]
xyouts, /device, align=1., charsize=1.4, color=0, orient=90. $
, xmrg+xl*xfrm-4, (yl+1)*yfrm $
, $
[   'ambiguous',   'ambiguous' $
, 'local frame', 'local frame' $
]
			;
			;Display image of continuum.
			;
wset, wdx(0)  &  wshow, wdx(0)
tvasp, b__cct, xmrg+0*xfrm, ymrg+1*yfrm, min=b.cct_min, max=b.cct_max, /gray $
, white=b.pbkg, yellow=highlight
			;
			;Display image of magnetic field.
			;
tvasp, b_fld, xmrg+1*xfrm, ymrg+1*yfrm, min=0., max=4000. $
, white=b.sbkg, yellow=highlight, /gray, /invert
			;
			;Display image of azimuth.
			;
tvasp, b_azm, xmrg+0*xfrm, ymrg+0*yfrm, min=-180., max=180., /wrap $
, white=b.sbkg, black=highlight
			;
			;Display image of inclination.
			;
tvasp, b_psi, xmrg+1*xfrm, ymrg+0*yfrm, min=0., max=180. $
, white=b.sbkg, black=highlight
			;
			;Display images of local frame azimuth.
			;
wset, wdx(1)  &  wshow, wdx(1)
tvasp, b_1azm, xmrg+0*xfrm, ymrg+1*yfrm, min=-180., max=180., /wrap $
, white=b.sbkg, black=highlight
			;
			;Display image of local frame inclination.
			;
tvasp, b_1incl, xmrg+1*xfrm, ymrg+1*yfrm, min=0., max=180. $
, white=b.sbkg, black=highlight
			;
			;Display image of ambiguous local frame azimuth.
			;
tvasp, b_2azm, xmrg+0*xfrm, ymrg+0*yfrm, min=-180., max=180., /wrap $
, white=b.sbkg, black=highlight
			;
			;Display image of ambiguous local frame inclination.
			;
tvasp, b_2incl, xmrg+1*xfrm, ymrg+0*yfrm, min=0., max=180. $
, white=b.sbkg, black=highlight
			;
			;Check keyword to do profiling.
			;
if  n_elements( profile ) eq 0  then  profile = 1
if  profile eq 0  then return
			;
			;Infinite loop till right mouse button set !err to 4.
			;
w_on = 0
leave = 2
while  leave ne 4  do begin
			;
			;Prompt for image to profile.
			;
	print
	print,"  left mouse button on image to profile."
	print,"center mouse button to swap current window."
	print," right mouse button to exit."
	field_cursor, wdx, w_on, xi,yi, xc,yc, xasp,yasp, leave, b
			;
	if  leave ne 4  then begin
			;
			;Get image to profile.
			;
		if  w_on eq 0  then begin
			if xi eq 0 and yi eq 1 then  tmp = b__cct
			if xi eq 1 and yi eq 1 then  tmp = b_fld
			if xi eq 0 and yi eq 0 then  tmp = b_azm
			if xi eq 1 and yi eq 0 then  tmp = b_psi
		end else begin
			if xi eq 0 and yi eq 1 then  tmp = b_1azm
			if xi eq 1 and yi eq 1 then  tmp = b_1incl
			if xi eq 0 and yi eq 0 then  tmp = b_2azm
			if xi eq 1 and yi eq 0 then  tmp = b_2incl
		end
			;
			;Prompt for image with moving cursor.
			;
		print
		print,"left   mouse button on image with interactive cursor."
		print,"center mouse button to swap current window."
		print,"right  mouse button to exit."
		field_cursor, wdx, w_on, xi,yi, xc,yc, xasp,yasp, leave, b
			;
	end
			;
	if  leave ne 4  then begin
			;
			;Do profiling.
			;
		print
		profiles, tmp, sx=xi*xfrm+xmrg, sy=yi*yfrm+ymrg
			;
	end
end
			;
end

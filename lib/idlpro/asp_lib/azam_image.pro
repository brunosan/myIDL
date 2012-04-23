function azam_image, aaname, aa, umbra, laluz, arrow
;+
;
;	function:  azam_image
;
;	purpose:  magnify azam image for display and set highlights.
;
;	author:  paul@ncar, 9/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if  n_params() eq 0  then begin
	print
	print, "usage:	image = azam_image( aaname, aa, umbra, laluz, arrow )"
	print
	print, "	Magnify azam image for display and set highlights."
	print
	print, "	Arguments"
	print, "		aaname	- input string name of image"
	print, "		aa	- input azam data set structure"
	print, "		umbra	- input where umbra hi light array"
	print, "		laluz	- input where array for to hi light"
	print, "		arrow	- input arrow point structure"
	print
	return, 0
endif
;-
				    ;Get some display variables.
t = aa.t
white  = aa.white
yellow = aa.yellow
red = aa.red
black  = aa.black
				    ;Update ambigs hilite.
if aa.hilite eq 'ambigs' then $
azam_ambigs, aa.b_azm, aa.sdat, t, laluz, nwhr

				    ;Get 2D data array.
				    ;Get and magnifiy image.
				    ;Select highlight colors.
case aaname of
'continuum': begin
	umb = red
	luz = yellow
	tmp = puff( aa.cct,   t )
	end
'field': begin
	umb = red
	luz = yellow
	tmp = puff( aa.fld,   t )
	end
'local azimuth': begin
	umb = white
	luz = black
	tmp = puff( aa.azm1,  t )
	end
'local incline': begin
	umb = white
	luz = black
	tmp = puff( aa.incl1, t )
	end
'ambig azimuth': begin
	umb = white
	luz = black
	tmp = puff( aa.azm2,  t )
	end
'ambig incline': begin
	umb = white
	luz = black
	tmp = puff( aa.incl2, t )
	end
'sight azimuth': begin
	umb = white
	luz = black
	tmp = puff( aa.azm,   t )
	end
'sight incline': begin
	umb = white
	luz = black
	tmp = puff( aa.psi,   t )
	end
'doppler': begin
	umb = white
	luz = black
	tmp = puff( aa.cen1,  t )
	end
'fill factor': begin
	umb = red
	luz = yellow
	tmp = puff( aa.alpha, t )
	end
'reference azimuth': begin
	tmp = aa.azm1
	umb = white
	luz = black
	whr = where( aa.azm ne aa.azm_r, nwhr )
	if nwhr ne 0 then  tmp(whr) = aa.azm2(whr)
	tmp = puff( tmp, t )
	end
'reference incline': begin
	tmp = aa.incl1
	umb = white
	luz = black
	whr = where( aa.azm ne aa.azm_r, nwhr )
	if nwhr ne 0 then tmp(whr) = aa.incl2(whr)
	tmp = puff( tmp, t )
	end
'original azimuth': begin
	tmp = aa.azm1
	umb = white
	luz = black
	whr = where( aa.azm ne aa.azm_o, nwhr )
	if nwhr ne 0 then  tmp(whr) = aa.azm2(whr)
	tmp = puff( tmp, t )
	end
'original incline': begin
	tmp = aa.incl1
	umb = white
	luz = black
	whr = where( aa.azm ne aa.azm_o, nwhr )
	if nwhr ne 0 then tmp(whr) = aa.incl2(whr)
	tmp = puff( tmp, t )
	end
aa.custname: begin
	if aa.custgray then begin
		umb = red
		luz = yellow
	end else begin
		umb = white
		luz = black
	end
	tmp = puff( aa.cust, t )
	end
'SET flux': begin
	aa.b_cust   = (1.-aa.b_alpha)*aa.b_fld*cos(aa.b_1incl*(!pi/180.))
	tvasp, aa.b_cust, min=-aa.mxfld, max=aa.mxfld $
	, /notv, bi=tmp, /gray
	aa.cust      = tmp
	aa.custmin   = -aa.mxfld
	aa.custmax   =  aa.mxfld
	aa.custname  = 'flux'
	aa.custgray  = 1L
	aa.custwrap  = 0L
	aa.custinv   = 0L
	aa.custnp    = aa.nsolved
	tvasp, [-1,0,1], /notv, bi=tmp, /gray
	aa.custback = tmp(1)
	umb = red
	luz = yellow
	tmp = puff( aa.cust, t )
	end
else: begin
	aaname = 'NO DATA'
	tmp = replicate( fix(aa.white), t*aa.xdim, t*aa.ydim )
	umb = red
	luz = yellow
	end
end
				    ;Set highlights.
if  n_elements( arrow ) ne 0  then begin
	if  n_dims(arrow.hi) gt 0  then tmp(arrow.hi)=umb
	if  n_dims(arrow.lo) gt 0  then tmp(arrow.lo)=luz
end
if  n_dims(umbra) gt 0  then tmp(umbra)=umb
if  n_dims(laluz) gt 0  then tmp(laluz)=luz

				    ;Return magnified image.
return, tmp

end

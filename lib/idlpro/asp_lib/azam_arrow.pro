function azam_arrow, azm, incl, sxy, t, angxloc
;+
;
;	function:  azam_arrow
;
;	purpose:  return arrow point structure for azam display images 
;
;	author:  paul@ncar,  10/93
;
;==============================================================================
;
;	Check number or parameters.
;
if  n_params() eq 0  then begin
	print
	print, "usage:  arrow = azam_arrow( azm, incl, sxy, t, angxloc )"
	print
	print, "	Return arrow point structure for azam display images"
	print
	print, "Arguments: (all input and are unchanged)"
	print
	print, "	azm	- azimuth 2D array, degrees"
	print, "	incl	- inclination 2D array, degrees"
	print, "	sxy	- where array there is data in 2D the arrays"
	print, "	t	- magnification factor to be used in"
	print, "		  target byte images"
	print, "	angxloc	- angle CCW form dislpay axis to solar"
	print, "		  frame x azis, degrees"
	print
	return,0
end
;-
				    ;
				    ;Get array dimensions.
				    ;
sizeazm = size(azm)
xdim    = sizeazm(1)
ydim    = sizeazm(2)
				    ;
				    ;Form logical array for solved points.
				    ;
ifdata = bytarr(xdim,ydim)
ifdata( sxy ) = 1
				    ;
				    ;Form blank magnified image.
				    ;
tmp = bytarr( t*xdim, t*ydim )
				    ;
				    ;Go over images with 12/t spacing.
				    ;
for  xc = 6/t,xdim-1,12/t  do begin
for  yc = 6/t,ydim-1,12/t  do begin
				    ;
	if  ifdata(xc,yc)  then begin
				    ;
				    ;Select inclination direction.
				    ;
		if  incl(xc,yc) le 90.  then  direc=1  else  direc=2
				    ;
		cradius = 6
		xcenter = t*xc+t/2
		ycenter = t*yc+t/2
		xx0 = 0 > (xcenter-cradius)
		yy0 = 0 > (ycenter-cradius)
		xx1 = (xcenter+cradius) < (t*xdim-1)
		yy1 = (ycenter+cradius) < (t*ydim-1)
		xdm  = xx1-xx0+1
		ydm  = yy1-yy0+1
		xctr = xcenter-xx0
		yctr = ycenter-yy0
				    ;
				    ;Blank symbol.
				    ;
		gyro = lonarr(xdm,ydm)
				    ;
				    ;Compute arrow point.
				    ;
		xrast = lindgen(2*cradius+1)-cradius
		xrast = xrast*sin(incl(xc,yc)*!pi/180.)
		yrast = (2*cradius-lindgen(2*cradius+1))/6.
		xrast = [ xrast, xrast ]
		yrast = [ yrast,-yrast ]
		agl = (azm(xc,yc)-angxloc)*!pi/180.
		cn = cos(agl)
		sn = sin(agl)
		xprm = cn*xrast-sn*yrast
		yprm = sn*xrast+cn*yrast
		xprm = round(xprm+xctr)
		yprm = round(yprm+yctr)
		whr = where( xprm ge 0 and xprm lt xdm $
			 and yprm ge 0 and yprm lt ydm )
		gyro( yprm(whr)*xdm+xprm(whr) ) = direc
				    ;
				    ;Install arrow point.
				    ;
		tmp(xx0:xx1,yy0:yy1) = gyro
				    ;
	end
				    ;
end
end
				    ;
				    ;Set arrow point structure
				    ;
return, { hi: where( tmp eq 1 ), lo: where( tmp eq 2 ) }
				    ;
end

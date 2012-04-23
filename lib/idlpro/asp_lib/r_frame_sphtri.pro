pro r_frame_sphtri, olat, b, c, x, y, z
;+
;
;	procedure:  r_frame_sphtri
;
;	purpose:  Transform a unit vector between two spherical
;		  reference points.
;
;	reference:  Fundamental spherical trigonometry equations from Smart:
;		    Text-Book on Spherical Astronomy, eq. A, B, C, and D.
;
;	authors:  kcjones@sunspot.noao.edu (Phil Wiborg),   paul@ncar
;
;=============================================================================
;
;	Check number of parameters.
;
if  n_params() lt 5  then begin
	print
	print, "usage:	r_frame_sphtri0 $"
	print, "	, olat		$ ;Input"
	print, "	, az0, el0	$ ;Input"
	print, "	, az1, el1    [	$ ;Output"
	print, "	, para	      ]	  ;Output"
	print
	print, "	Transform a unit vector between two spherical"
	print, "	reference points."
	print
	print, "	Definition:"
	print
	print, "		sct0	~ The great circle sector that"
	print, "			  connects the two reference points"
	print, "			  on the sphere"
	print
	print, "	Arguments (all in radians):"
	print
	print, "		olat	- !pi/2.-abs(sct0)"
	print, "		az0	- The azimuth about first reference"
	print, "			- point, from sector sct0"
	print, "		el0	- The elevation at first reference"
	print, "			  point, positive away from surface"
	print, "		az1	- The azimuth about second reference"
	print, "			  point, from sector sct0"
	print, "		el1	- The elevation at second reference"
	print, "			  point, positive away from surface"
	print, "		para	- In dircetion of the unit vector"
	print, "			  in a plane perpendicular to"
	print, "			  the unit vector, the angle CCW from"
	print, "			  projected axis of first reference"
	print, "			  point to projected axis of the"
	print, "			  second reference point"
	print
	print, "	Note: If az0 is positive CCW, the az1 is positive CCW"
	print, "	      If az0 is positive  CW, the az1 is positive  CW"
	print
	print, "The routine can be used to convert between coordinate"
	print, "systems as follows:"
	print
	print, "(1) Let: az0 = hour angle      (2) Let: az0 = azimuth"
	print, "         el0 = declination              el0 = elevation"
	print, "        olat = earth latitude          olat = earth latitude"
	print
	print, "   Then: az1 = azimuth            Then: az1 = hour angle"
	print, "         el1 = elevation                el1 = declination"
	print, "        para = parallatic              para = neg. parallatic"
	print, " 	       (positive counter"
	print, "	       clockwise from"
	print, "	       earth north)"
	print
	return
endif
;-
				    ;
				    ;Common to save info for reuse.
				    ;
common sphtri_com_0, osav, bsav, csav, xsav, ysav, zsav
				    ;
				    ;Try to use old answer.
				    ;
if  n_elements(osav) ne 0  then $
if  olat eq osav  and  b eq bsav  and  c eq csav  then begin
	x = xsav
	y = ysav
	z = zsav
return
end
				    ;
sina = sin(olat)
cosa = cos(olat)
				    ;
sinb = sin(b)
cosb = cos(b)
sinc = sin(c)
cosc = cos(c)
				    ;
tmp1 = cosc*cosb
tmp2 = sinc*cosa
sinx = -cosc*sinb
cosx = tmp2-tmp1*sina
siny = sinc*sina+tmp1*cosa
sinz = cosa*sinb
cosz = sina*cosc-tmp2*cosb
				    ;
x    = atan(sinx,cosx)
y    = asin(siny)
z    = atan(sinz,cosz)
				    ;
osav = olat
bsav = b
csav = c
xsav = x
ysav = y
zsav = z
				    ;
end

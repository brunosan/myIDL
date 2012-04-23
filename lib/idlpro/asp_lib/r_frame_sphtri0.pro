pro r_frame_sphtri0, olat, b, c, x, y
;+
;
;	procedure:  r_frame_sphtri0
;
;	purpose:  Transform a unit vector between two spherical
;		  reference points.
;		  (Same effect as r_frame_sphtri but does not do
;		  parallactic angle).
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
	print, "	, az1, el1	  ;Output"
	print
	print, "	Transform a unit vector between two spherical"
	print, "	reference points."
	print, "	(Same effect as r_frame_sphtri but does not do"
	print, "	parallactic angle)."
	print
	print, "	Definition:"
	print
	print, "		sct0	~ The great circle sector that"
	print, "			  connects the two reference points"
	print, "			  on the sphere"
	print
	print, "	Arguments (all in radians):"
	print
	print, "		olat	~ !pi/2.-abs(sct0)"
	print, "		az0	~ The azimuth about first reference"
	print, "			  point, from sector sct0"
	print, "		el0	~ The elevation at first reference"
	print, "			  point, positive away from surface"
	print, "		az1	~ The azimuth about second reference"
	print, "			  point, from sector sct0"
	print, "		el1	~ The elevation at second reference"
	print, "			  point, positive away from surface"
	print
	print, "	Note: If az0 is positive CCW, the az1 is positive CCW."
	print, "	      If az0 is positive  CW, the az1 is positive  CW."
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
	print
	return
endif
;-
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
				    ;
x    = atan(sinx,cosx)
y    = asin(siny)
				    ;
end

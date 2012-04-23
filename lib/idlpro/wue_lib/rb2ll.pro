;+
; NAME:
;       RB2LL
; PURPOSE:
;       From range, bearing compute latitude, longitude .
; CATEGORY:
; CALLING SEQUENCE:
;       rb2ll, lng0, lat0, dist, azi, lng1, lat1
; INPUTS:
;       lng0, lat0 = long, lat of starting point (deg).     in
;       dist = range to point point of interest (radians).  in
;       azi = azimuth to point of interest (degrees).       in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       lng1, lat1 = long, lat of point of interest (deg).  out
; COMMON BLOCKS:
; NOTES:
;       Notes: A unit sphere is assumed, thus dist is in radians.
; MODIFICATION HISTORY:
;       R. Sterner, 13 Feb,1991
;-
 
	pro rb2ll, lng1, lat1, dist, azi, lng2, lat2, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' From range, bearing compute latitude, longitude .'
	  print,' rb2ll, lng0, lat0, dist, azi, lng1, lat1'
	  print,'   lng0, lat0 = long, lat of starting point (deg).     in'
	  print,'   dist = range to point point of interest (radians).  in'
	  print,'   azi = azimuth to point of interest (degrees).       in'
	  print,'   lng1, lat1 = long, lat of point of interest (deg).  out'
	  print,' Notes: A unit sphere is assumed, thus dist is in radians.'
	  return
	endif
 
	ax = (360. - azi)/!radeg
	polrec3d, 1., dist, ax, x3, y3, z3
	rot_3d, 2, x3, y3, z3, (90.-lat1)/!radeg, x2, y2, z2
	rot_3d, 3, x2, y2, z2, (180.-lng1)/!radeg, x1, y1, z1
	recpol3d, x1, y1, z1, r, az, ax
	lng2 = ax*!radeg
	lat2 = 90. - az*!radeg
 
	return
	end

;+
; NAME:
;       LL2RB
; PURPOSE:
;       From latitude, longitude compute range, bearing.
; CATEGORY:
; CALLING SEQUENCE:
;       ll2rb, lng0, lat0, lng1, lat1, dist, azi
; INPUTS:
;       lng0, lat0 = long, lat of reference point (deg).    in
;       lng1, lat1 = long, lat of point of interest (deg).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       dist = range to point point of interest (radians).  out
;       azi = azimuth to point of interest (degrees).       out
; COMMON BLOCKS:
; NOTES:
;       Notes: A unit sphere is assumed, thus dist is in radians
;         so to get actual distance multiply dist by radius.
; MODIFICATION HISTORY:
;       R. Sterner, 13 Feb,1991
;-
 
	pro ll2rb, lng1, lat1, lng2, lat2, dist, azi, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' From latitude, longitude compute range, bearing.'
	  print,' ll2rb, lng0, lat0, lng1, lat1, dist, azi'
	  print,'   lng0, lat0 = long, lat of reference point (deg).    in'
	  print,'   lng1, lat1 = long, lat of point of interest (deg).  in'
	  print,'   dist = range to point point of interest (radians).  out'
	  print,'   azi = azimuth to point of interest (degrees).       out'
	  print,' Notes: A unit sphere is assumed, thus dist is in radians'
	  print,'   so to get actual distance multiply dist by radius.'
	  return
	endif
 
	polrec3d, 1., (90.-lat2)/!radeg, lng2/!radeg, x1, y1, z1
	rot_3d, 3, x1, y1, z1, -(180.-lng1)/!radeg, x2, y2, z2
	rot_3d, 2, x2, y2, z2, -(90.-lat1)/!radeg, x3, y3, z3
	recpol3d, x3, y3, z3, r, dist, ax
	azi = (360. - ax*!radeg) mod 360.
 
	return
	end

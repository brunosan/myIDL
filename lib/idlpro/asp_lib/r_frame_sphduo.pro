pro r_frame_sphduo,    lng0, lat0, az0, el0,    lng3, lat3, az3, el3
;+
;
;	procedure:  r_frame_sphduo
;
;	purpose:  translate unit vector form one local longitude,latitude
;		  frame to another local longitude,latitude frame.
;
;	author:  paul@ncar
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	r_frame_sphduo $"
	print, "	, lng0, lat0, az0, el0 $"
	print, "	, lng3, lat3, az3, el3
	print
	print, "	Translate unit vector form one local longitude,"
	print, "	latitude frame to another local longitude,latitude"
	print, "	frame."
	print
	print, "	Input:"
	print, "
	print, "		lng0	- longitude of input reference frame"
	print, "			  (right handed (increasing to right"
	print, "			  if north is up))"
	print, "		lat0	- latitude of input reference frame"
	print, "			  (positive to north)"
	print, "		az0	- azimuth of input unit vector"
	print, "			  (right handed (CCW from north))"
	print, "		el0	- elevation of input unit vector"
	print, "			  (positive to increasing az0 axis)"
	print
	print, "		lng3	- longitude of output reference frame"
	print, "			  (right handed (increasing to right"
	print, "			  if north is up))"
	print, "		lat3	- latitude of output reference frame"
	print, "			  (positive to north)"
	print
	print, "	Output:"
	print, "
	print, "		az3	- azimuth of output unit vector"
	print, "			  (right handed (CCW from north))"
	print, "		el3	- elevation of output unit vector"
	print, "			  (positive to increasing az3 axis)"
	print
	return
endif
;-
				    ;
				    ;Transform to polar frame.
				    ;Longitude definition unchanged.
				    ;
; lng1 = lng0
; lat1 = !pi/2.
  r_frame_sphtri0, lat0, az0, el0, az1, el1
				    ;
				    ;Rotate polar frame to output longitude.
				    ;Latitude definition unchanged.
				    ;
; lng2 = lng3
; lat2 = !pi/2.
  az2 = az1+lng0-lng3
  el2 = el1
 				    ;
 				    ;Transform to output frame.
 				    ;Longitude definition unchanged.
 				    ;
; lng3 = lng3
; lat3 = lat3
  r_frame_sphtri0, lat3, az2, el2, az3, el3
	
  end

pro r_frame_sun $
, year, month, day, utime $
, west_arcsec, north_arcsec $
, longitude, latitude $
, mu_value $
, right_ascen, declination, gsdt $
, b0_angle, p_angle, cen_long, radius_arcsec
;+
;
;	procedure:  r_frame_sun
;
;	purpose:  From time, hilio centric (west,north) arc seconds on sun
;		  find solar longitude and latitude.
;
;	author:  paul@ncar
;
;=============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	r_frame_sun			$"
	print, "	, year, month, day, utime 	$ ;Input"
	print, "	, west_arcsec, north_arcsec	$ ;Input"
	print, "	, longitude, latitude		$ ;Output"
	print, "	, mu_value		      [	$ ;Output"
	print, "	, right_ascen, declination    	$ ;Output"
	print, "	, gsdt, b0_angle, p_angle	$ ;Output"
	print, "	, cen_long, radius_arcsec     ]	  ;Output"
	print
	print, "	From time, hilio centric (west,north) arc seconds on"
	print, "	sun find solar longitude and latitude.
	print
	print, "	Arguments:"
	print
	print, "		   year	- year of observation"
	print, "			  (1900 added for 50 < year < 101 )"
	print, "			  (2000 added for year < 51 )"
	print, "		  month	- month of year"
	print, "		    day	- day of month"
	print, "		  utime	- universal time in hours"
	print, "	    west_arcsec	- Arc seconds helio centric west of"
	print, "			  disk center"
	print, "	   north_arcsec - Arc seconds helio centric north of"
	print, "			  disk center"
	print, "	      longitude - longitude positive west of solar"
	print, "			  line of sight meridian"
	print, "	       latitude - latitude positive north of solar"
	print, "			  equator"
	print, "	       mu_value - observation mu value"
	print, "	    right_ascen	- right ascension of disk center"
	print, "	    declination	- declination of disk center"
	print, "		   gsdt	- right ascension from central"
	print, "			  meridian"
	print, "      	       b0_angle	- b0 angle"
	print, "		p_angle - p angle"
	print, "	       cen_long - carrington longitude of disk center"
	print, "	  radius_arcsec - solar radius in arc seconds"
	return
endif
;-
				    ;
				    ;Do solar ephemeris
				    ;
r_frame_solcor $
, r_frame_julian( year, month, day, utime ) $
, right_ascen, declination, gsdt $
, b0_angle, p_angle, cen_long, radius_arcsec
				    ;
				    ;Radius of observation from disk center.
				    ;
robs = sqrt( north_arcsec*north_arcsec + west_arcsec*west_arcsec )
				    ;
				    ;Cosine of elevation of observation
				    ;from limb.
				    ;
cosobs = robs/radius_arcsec
				    ;
				    ;Observation mu value.
				    ;
mu_value = sqrt( 1.-cosobs*cosobs )
				    ;
				    ;Azimuth of observation CCW from north.
				    ;
az0 = atan( -west_arcsec, north_arcsec )
				    ;
				    ;Elevation of observation from limb.
				    ;
el0 = acos( cosobs )
				    ;
				    ;Transform unit vector to solar
				    ;to obtain longitude and latitude.
				    ;
r_frame_sphtri0, b0_angle, az0, el0, longitude, latitude
				    ;
end

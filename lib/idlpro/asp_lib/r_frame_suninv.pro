pro r_frame_suninv $
, year, month, day, utime $
, longitude, latitude $
, west_arcsec, north_arcsec $
, mu_value $
, right_ascen, declination, gsdt $
, b0_angle, p_angle, cen_long, radius_arcsec
;+
;
;	procedure:  r_frame_suninv
;
;	purpose:  From time, solar latitude, solar longitude find
;		  helio centric coordinates from disk center
;
;	author:  paul@ncar
;
;	routines:  r_frame_suninv   suninv_test
;
;=============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	r_frame_suninv			$"
	print, "	, year, month, day, utime 	$ ;Input"
	print, "	, longitude, latitude		$ ;Input"
	print, "	, west_arcsec, north_arcsec	$ ;Output"
	print, "	, mu_value		      [	$ ;Output"
	print, "	, right_ascen, declination	$ ;Output"
	print, "	, gsdt, b0_angle, p_angle	$ ;Output"
	print, "	, cen_long, radius_arcsec     ]	  ;Output"
	print
	print
	print, "	From time, solar latitude, solar longitude find"
	print, "	helio centric coordinates from disk center."
	print
	print, "	Arguments:"
	print
	print, "		   year	- year of observation"
	print, "			  (1900 added for 50 < year < 101 )"
	print, "			  (2000 added for year < 51 )"
	print, "		  month	- month of year"
	print, "		    day	- day of month"
	print, "		  utime	- universal time in hours"
	print, "	      longitude - longitude positive west of solar"
	print, "			  line of sight meridian"
	print, "	       latitude - latitude positive north of solar"
	print, "			  equator"
	print, "	    west_arcsec	- Arc seconds helio centric west of"
	print, "			  disk center"
	print, "	   north_arcsec - Arc seconds helio centric north of"
	print, "			  disk center"
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
				    ;Get solar ephemeris.
				    ;
r_frame_solcor $
, r_frame_julian( year, month, day, utime ) $
, right_ascen, declination, gsdt $
, b0_angle, p_angle, cen_long, radius_arcsec
				    ;
				    ;Find angle about disk center from
				    ;hilio centric north counter clockwise
				    ;to the solar location.
				    ;Find angle about core center from
				    ;the limb to the solar location.
				    ;
r_frame_sphtri0, b0_angle, longitude, latitude, north_ccw, above_limb
				    ;
				    ;Compute observation mu value.
				    ;
cosobs = cos( above_limb )
mu_value = sqrt( 1.-cosobs*cosobs )
				    ;
				    ;Compute arc seconds from disk center
				    ;to the observation.
				    ;
oradius = radius_arcsec*cosobs
west_arcsec  = -oradius*sin( north_ccw  )
north_arcsec =  oradius*cos( north_ccw  )
				    ;
end
;-----------------------------------------------------------------------------
;
;	procedure:  suninv_test
;
;	purpose:  diagnostic test for local_undo
;
;-----------------------------------------------------------------------------
pro suninv_test
;
;To run diagnostic:
;
;	IDL> .rnew r_frame_suninv
;	IDL> suninv_test
				    ;
rpd   = !pi/180.
dpr   = 180./!pi
				    ;
day   = 21
year  = 1992
utime = 15.5
				    ;
lon = [  55, -55, -55,  55 ]*rpd
lat = [  30,  30, -30, -30 ]*rpd
				    ;
for  month = 1,12  do begin
for  pass  = 0,3   do begin
				    ;
				    ;Convert (latitude,longitude)
				    ;to (west,north) arcseconds.
				    ;
	r_frame_suninv $
	, year, month, day, utime $
	, lon(pass), lat(pass) $
	, west_arcsec, north_arcsec $
	, mu_value
				    ;
				    ;Convert (west,north) arcseconds
				    ;to (latitude,longitude).
				    ;
	psi = 30.*rpd
	azm = 40.*rpd
	r_frame_asp $
	, psi, azm $
	, year, month, day, utime $
	, west_arcsec, north_arcsec $
	, local_incline, local_azimuth $
	, ambig_incline, ambig_azimuth $
	, mu_value $
	, longitude, latitude, carlong $
	, right_ascen, declination, gsdt $
	, b0_angle, p_angle, cen_long, radius_arcsec
				    ;
				    ;Test if in ball park.
				    ;
	if abs(lat(pass)-latitude ) gt .01 $
	or abs(lon(pass)-longitude) gt .01 then begin
				    ;
		print, 'local_undo routine did not varify'
		print, 'longitude ', lon(pass)*dpr, longitude*dpr
		print, 'latitude  ', lat(pass)*dpr, latitude*dpr
		stop
				    ;
	end
end
end
				    ;
print, 'test ok'
				    ;
end

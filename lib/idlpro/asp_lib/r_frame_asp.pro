pro r_frame_asp $
, psi, azm $
, year, month, day, utime $
, west_arcsec, north_arcsec $
, local_incline, local_azimuth $
, ambig_incline, ambig_azimuth $
, mu_value $
, longitude, latitude, carlong $
, right_ascen, declination, gsdt $
, b0_angle, p_angle, cen_long, radius_arcsec $
, parallactic, hour_angle $
, inst_az_el  = inst_az_el $
, lapalma     = lapalma
;+
;
;	procedure:  r_frame_asp
;
;	purpose:  translate magnetic field vector from telescope frame
;		  to local solar frame.
;
;	author:  paul@ncar
;
;=============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	r_frame_asp $"
	print, "	, psi, azm				$ ;Input"
	print, "	, year, month, day, utime		$ ;Input"
	print, "	, west_arcsec, north_arcsec		$ ;Input"
	print, "	, local_incline, local_azimuth	      [	$ ;Output"
	print, "	, ambig_incline, ambig_azimuth		$ ;Output"
	print, "	, mu_value				$ ;Output"
	print, "	, longitude, latitude, carlong		$ ;Output"
	print, "	, right_ascen, declination, gsdt	$ ;Output"
	print, "	, b0_angle, p_angle			$ ;Output"
	print, "	, cen_long, radius_arcsec	      	$ ;Output"
	print, "	, parallactic, hour_angle	      ]	  ;Output"
	print
	print, "	Translate magnetic field vector from observers"
	print, "	frame to local solar frame."
	print
	pause, "(return to continue)"
	print
	print, "Arguments (input):"
	print, "(all angles in radians)"
	print, "(all are scalars)"
	print
	print, "		    psi	- inclination angle of field from"
	print, "			  line-of-sight"
	print, "		    azm	- field azimuth counter clockwise"
	print, "			  plane of incidence of VTT elevation"
	print, "			  mirror"
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
	print
	pause, "(return to continue)"
	print
	print, "Arguments (output):"
	print, "(all angles in radians)"
	print, "(all are scalars)"
	print
	print, "	  local_incline - field inclination in local frame"
	print, "	  local_azimuth - field azimuth in local frame"
	print, "			  (CCW from solar west)"
	print, "	  ambig_incline - ambiguous field inclination"
	print, "	  ambig_azimuth - ambiguous field azimuth
	print, "	       mu_value - mu value of observation"
	print, "	      longitude - longitude of observation"
	print, "			  from meridian positive west"
	print, "	       latitude - latitude of observation"
	print, "			  from equator positive north"
	print, "		carlong - carrington longitude of observation"
	print, "	    right_ascen	- right ascension of disk center"
	print, "	    declination	- declination of disk center"
	print, "		   gsdt	- right ascension from central"
	print, "			  meridian"
	print, "      	       b0_angle	- b0 angle"
	print, "		p_angle - p angle"
	print, "	       cen_long - carrington longitude of disk center"
	print, "	  radius_arcsec - solar radius in arc seconds"
	print, "	    parallactic - parallactic angle CCW from earth"
	print, "			  north to telescope plus elevation"
	print, "	     hour_angle - hour angle at observatory"
	print
	pause, "(return to continue)"
	print
	print, "Keyword:"
	print
	print, "	     inst_az_el - input two valued vector with"
	print, "			  azimuth and elevation at telescope
	print, "			  site (def: use ephemeris)"
	print, "		lapalma - set if La Palma telescope"
	return
endif
;-
				    ;
dpr    = 180./!pi
rpd    = 1./dpr
halfpi = !pi/2.
				    ;
				    ;Set site latitude and longitude
				    ;
if  n_elements(lapalma) eq 0  then  lapalma = 0
if  lapalma ne 0 then begin
				    ;
				    ;La Palma on keyword.
				    ;
	earth_latitude  = (28.+45./60.+51./3600.)*rpd
	earth_longitude = (17.+53./60.+00./3600.)*rpd
				    ;
end else begin
				    ;
				    ;Sacramento Peak default.
				    ;
	earth_latitude  = 32.786*rpd
	earth_longitude = 105.82*rpd
				    ;
end
				    ;
				    ;Transform (west,north) arcseconds on
				    ;sun to solar longitude and latitude.
				    ;In the process get solar ephemeris
				    ;and mu value of observation.
				    ;
r_frame_sun $
, year, month, day, utime $
, west_arcsec, north_arcsec $
, longitude, latitude $
, mu_value $
, right_ascen, declination, gsdt $
, b0_angle, p_angle, cen_long, radius_arcsec
				    ;
				    ;
				    ;Find carrington longitude.
				    ;
carlong = cen_long+longitude
if carlong lt 0. then  carlong = carlong+2.*!pi
				    ;
				    ;Compute hour angle.
				    ;
hour_angle = gsdt-right_ascen-earth_longitude
if hour_angle lt -!pi then  hour_angle = hour_angle+2.*!pi
if hour_angle gt  !pi then  hour_angle = hour_angle-2.*!pi
				    ;
				    ;Get parallactic angle
				    ;counter clockwise from earth north.
				    ;
				    ;Note: Parallactic angle is computed
				    ;for the center of the field
				    ;of the image.  This means that the
				    ;rotation of the reference frame
				    ;in solar coordinates could be off
				    ;by about one minute, which is
				    ;irrelevent for ASP.   This
				    ;approximation should be noted for
				    ;future reference, however.
				    ;
				    ;Check if site azimuth and elevation
				    ;are given.
				    ;
if n_elements(inst_az_el) eq 2  then begin
				    ;
	siteaz = inst_az_el(0)
	siteel = inst_az_el(1)
				    ;
	r_frame_sphtri, earth_latitude $
	, siteaz, siteel $
	, siteha, sitedc, neg_parallactic
				    ;
	parallactic = -neg_parallactic
				    ;
end else begin
				    ;
	siteha = hour_angle
	sitedc = declination
				    ;
	r_frame_sphtri, earth_latitude $
	, siteha, sitedc $
	, siteaz, siteel, parallactic
				    ;
end
				    ;
				    ;Azimuth relative to plain of
				    ;incidence of elevation mirror.
				    ;
azmact = azm
				    ;
				    ;Azimuth relative to positive
				    ;elevation direction.
				    ;Rotation from plane of incidence
				    ;of elevation mirror.
				    ;
azmact = azmact+halfpi
				    ;
				    ;Azimuth relative to earth north.
				    ;
azmact = azmact+parallactic
				    ;
				    ;Azimuth relative to solar north.
				    ;
azmact = azmact-p_angle
				    ;
				    ;Transform vector to local solar
				    ;longitude latitude.
				    ;Do ambiguous case as well.
				    ;
r_frame_sphduo,        0., b0_angle,     azmact, !pi/2.-psi $
,               longitude, latitude,        az0,        el0
				    ;
r_frame_sphduo,        0., b0_angle, azmact+!pi, !pi/2.-psi $
,               longitude, latitude,        az1,        el1
				    ;
				    ;Local inclination from normal 
				    ;to surface.
				    ;
local_incline = !pi/2.-el0
ambig_incline = !pi/2.-el1
				    ;
				    ;Local azimuth CCW from solar west.
				    ;
local_azimuth = !pi/2.+az0
ambig_azimuth = !pi/2.+az1
				    ;
				    ;Put local azimuth in range -pi to pi.
				    ;
if local_azimuth lt -!pi then  local_azimuth = local_azimuth+2.*!pi
if local_azimuth lt -!pi then  local_azimuth = local_azimuth+2.*!pi
if local_azimuth gt  !pi then  local_azimuth = local_azimuth-2.*!pi
if local_azimuth gt  !pi then  local_azimuth = local_azimuth-2.*!pi
				    ;
if ambig_azimuth lt -!pi then  ambig_azimuth = ambig_azimuth+2.*!pi
if ambig_azimuth lt -!pi then  ambig_azimuth = ambig_azimuth+2.*!pi
if ambig_azimuth gt  !pi then  ambig_azimuth = ambig_azimuth-2.*!pi
if ambig_azimuth gt  !pi then  ambig_azimuth = ambig_azimuth-2.*!pi
				    ;
				    ;Diagnostic patch.
				    ;
if 0 then begin
				    ;
	print, '   longitude =', longitude*dpr
	print, '    latitude =', latitude*dpr
	print, '     p_angle =', p_angle*dpr
	print, '    b0_angle =', b0_angle*dpr
	print, ' parallactic =', parallactic*dpr
	print, '      siteaz =', siteaz*dpr
	print, '      siteel =', siteel*dpr
	print, '      siteha =', siteha*dpr
	print, '      sitedc =', sitedc*dpr
	print, ' right_ascen =', right_ascen*dpr
	print, ' declination =', declination*dpr
	print, '  hour_angle =', hour_angle*dpr
				    ;
end
				    ;
end

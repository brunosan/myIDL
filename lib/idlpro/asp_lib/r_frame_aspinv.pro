pro r_frame_aspinv $
, local_incline, local_azimuth $
, year, month, day, utime $
, west_arcsec, north_arcsec $
, psi, azm $
, mu_value $
, longitude, latitude, carlong $
, right_ascen, declination, gsdt $
, b0_angle, p_angle, cen_long, radius_arcsec $
, parallactic $
, inst_az_el  = inst_az_el $
, lapalma     = lapalma
;+
;
;	procedure:  r_frame_aspinv
;
;	purpose:  translate magnetic field vector from local solar frame
;		  to telescope frame.
;
;	author:  paul@ncar
;
;=============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	r_frame_aspinv $"
	print, "	, local_incline, local_azimuth		$ ;Input"
	print, "	, year, month, day, utime		$ ;Input"
	print, "	, west_arcsec, north_arcsec		$ ;Input"
	print, "	, psi, azm			      [	$ ;Output"
	print, "	, mu_value				$ ;Output"
	print, "	, longitude, latitude, carlong		$ ;Output"
	print, "	, right_ascen, declination, gsdt	$ ;Output"
	print, "	, b0_angle, p_angle			$ ;Output"
	print, "	, cen_long, radius_arcsec		$ ;Output"
	print, "	, parallactic			      ]	  ;Output"
	print
	print, "	Translate magnetic field vector from local solar"
	print, "	frame to observers frame."
	print
	pause, "(return to continue)"
	print
	print, "Arguments (input):"
	print, "(all angles in radians)"
	print, "(all are scalars)"
	print
	print, "	  local_incline - field inclination in local frame"
	print, "	  local_azimuth - field azimuth in local frame"
	print, "			  (CCW from solar west)"
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
	print, "		    psi	- inclination angle of field from"
	print, "			  line-of-sight"
	print, "		    azm	- field azimuth counter clockwise"
	print, "			  plane of incidence of VTT elevation"
	print, "			  mirror"
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
				    ;Field vector azimuth CCW from
				    ;solar north.
				    ;
az0 = local_azimuth-!pi/2.
				    ;
				    ;Field vector elevation from limb.
				    ;
el0 = !pi/2.-local_incline
				    ;
				    ;Transform from local longitude and
				    ;latitude to line of sight frame.
				    ;
r_frame_sphduo $
, longitude, latitude, az0,      el0 $
,        0., b0_angle, azm, el_sight
				    ;
				    ;Use inclination rather than elevation.
				    ;
psi = !pi/2.-el_sight
				    ;
				    ;Azimuth relative to earth north.
				    ;
azm = azm+p_angle
				    ;
				    ;Azimuth relative to positive elevation.
				    ;
azm = azm-parallactic
				    ;
				    ;Azimuth relative to plain of
				    ;incidence of elevation mirror.
				    ;
azm = azm-halfpi
				    ;
				    ;Put azimuth in range -pi to pi.
				    ;
if azm lt -!pi then  azm = azm+2.*!pi
if azm lt -!pi then  azm = azm+2.*!pi
if azm gt  !pi then  azm = azm-2.*!pi
if azm gt  !pi then  azm = azm-2.*!pi
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

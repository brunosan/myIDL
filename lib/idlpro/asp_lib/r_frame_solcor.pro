pro r_frame_solcor, djd, ras, decs, gsdt, bzro, p, solong, rsun
;+
;
;	procedure:  r_frame_solcor
;
;	purpose:  do solar ephemeris
;
;	authors:  unknown@somewhere  paul@ncar
;
;=============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	r_frame_solcor"
	print, "	,   julian_time 		[$ ;Input"
	print, "	,   right_ascen [, declination	[$ ;Output"
	print, "	,          gsdt [,    b0_angle	[$ ;Output"
	print, "	,       p_angle [,    cen_long	[$ ;Output"
	print, "	, radius_arcsec ]]]]]]]		   ;Output"
	print
	print, "	Do solar ephereris"
	print
	print, "Arguments:"
	print, "(all angles in radians)"
	print, "(all are scalars)"
	print
	print, "	    julian_time	- julain time in days including
	print, "			  fraction of days.
	print, "			  (Recommend double precision).
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
				    ;Set common to store answer.
				    ;
common com_solcor, savdjd $
, savras, savdecs, savgsdt, savbzro, savp, savsolong, savrsun
				    ;
				    ;If time unchanged return old answer.
				    ;
if n_elements(savdjd) eq 0 then  savdjd = -987654321D
if djd eq savdjd then begin
	ras    = savras
	decs   = savdecs
	gsdt   = savgsdt
	bzro   = savbzro
	p      = savp
	solong = savsolong
	rsun   = savrsun
return
end
				    ;
				    ;Follow unknown author.
				    ;
jd     = long(djd)
fjd    = float(djd-jd)
d      = float(djd-2415020.)
fiyr   = float(long(d/365.25))
tpi    = 2.*!pi
g      = -.026601523+.01720196977*d-1.95e-15*d*d-tpi*fiyr
xlms   = 4.881627938+.017202791266*d+3.95e-15*d*d-tpi*fiyr
obl    = .409319747-6.2179e-9*d
ecc    = .01675104-1.1444e-9*d
e      = ecc*sin(g)/(1.-ecc*cos(g))
e      = g+e-0.5*e^3
rsun   = 961.18/(1.-ecc*cos(e))
f      = d-365.25*fiyr
gsdd   = 1.739935476+(tpi*f+1.342027e-4*d)/365.25
gsdt   = gsdd+tpi*(fjd-0.5)
xlts   = xlms+2.*ecc*sin(g)+1.25*ecc*ecc*sin(2.*g)
sndc   = sin(xlts)*sin(obl)
decs   = asin(sndc)
csra   = cos(xlts)/cos(decs)
ras    = acos(csra)
if sin(xlts) lt 0. then  ras = tpi-ras
omega  = 1.297906+6.66992e-7*d
thetac = xlts-omega
bzro   = asin(.126199*sin(thetac))
p      = -atan(cos(xlts)*tan(obl))-atan(.127216*cos(thetac))
xlmm   = atan(.992005*sin(thetac),cos(thetac))
jdr    = jd-2398220
irot   = long((jdr+fjd)/25.38)
frot   = (jdr+fjd)/25.38-irot
solong = xlmm-tpi*frot+!pi-3.e-4
if solong lt 0.  then  solong = solong+tpi
if solong ge tpi then  solong = solong-tpi
				    ;
				    ;Save answer in common.
				    ;
savdjd    = djd
savras    = ras
savdecs   = decs
savgsdt   = gsdt
savbzro   = bzro
savp      = p
savsolong = solong
savrsun   = rsun
				    ;
end

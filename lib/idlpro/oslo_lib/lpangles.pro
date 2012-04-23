FUNCTION MODULO,I,J
;
; NAME:
;       MODULO
; PURPOSE:
;       Simulate the operator MOD in VMS and ANA.
; CALLING SEQUENCE:
;       Result = MODULO(I,J)
; INPUTS:
;       I,J = arrays to make I MOD J.
; OUTPUTS:
;       Result = I MOD J.
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;       None.
; RESTRICTIONS:
;       None.
; PROCEDURE:
;       Makes I MOD J as in VMS and ANA.
; MODIFICATION HISTORY:
;       Written by Roberto Luis Molowny Horas, July 1992.
;
ON_ERROR,2
        RETURN,i - j*FIX(i/j)
        END







PRO lapalmasun,iy,im,id,sday,ha,dec
;returns hour angle and declination of the sun at La Palma SSO for a set of
;times
;
;  time variable for Newcomb's folmulae:
;  fraction of Julian centuries elapsed since 1900.05 (noon 1st of January)
;  = J.D.2415020.0)
        jd=julian(iy,im,id)
        h0=(jd-2415020.0)/36525.0
        h=(jd+double(sday)/86400.D0-2415020.0)/36525.0
        hh=h*h
;  Newcomb's formulae. (page 98 Explanatory suppl. to the ephemeris)
;  mean obliquity of the ecliptic
        ehel=0.4093198-2.2703E-4*h-2.86E-8*hh
;type,'mean obliquity =',ehel
;  eccentricity of earth's orbit
        eks=0.01675104-0.0000418*h
;type,'eccent. =',eks
;  mean longitude of sun
        sml=279.6967+36000.769*h
;    sml=  (  (sml/360.0) - (fix(sml/360.0))  )*360.0
     sml = MODULO(sml,360.)
;type,'mean longitude of sun =',sml
    sml=sml*!pi/180.0
;  mean anomaly
         anm=358.4758+35999.0498*h-0.00015*hh
         anm=anm*!pi/180.0
;  true longitude of sun (sl)
         cc=(1.91946-0.00479*h)*sin(anm)+0.020*sin(2*anm)
         cc=cc*!pi/180
         sl=sml+cc
;  declination of apparent sun
        dec=asin(sin(ehel)*sin(sl))
;  right ascension of apparent sun
        ra=atan((cos(ehel)*sin(sl)),cos(sl))
;  convert ra in radians to hours
        ra=ra*24.0/(2.*!pi)
ra=ra+24.*(ra lt 0)
;  convert dec in radians to degrees
        dec=dec*360.0/(2.*!pi)
;sidereal time
;  sidereal time in Greenwich at 0 UT (Newcomb)
         sidg0=6.6461D0+2400.0513D0*h0
        sidg0 = MODULO(sidg0,24.)
;type,'sidereal time in Greenwich at 0 UT',gmt(sidg0*3600.),sidg0
;  sidereal time in Greeenwich at any instant
         sidg=(double(sday)*1.002737908D0/3600.0D0)+sidg0
;type,'computed sidereal time at Greenwich',dms(sidg%24),sidg,sidg%24
;  longitude of observatory in degrees, negative if west
        lo=-17.880
;  convert longitude of obs (degrees) to time measure and find local sidereal
;  time, longitude is positive when west
        sidl=sidg+lo*(24.0/360.0)
        ha=sidl-ra
;restrict to the -12 to +12 range
        ha = MODULO(ha+12.,24.) - 12.
        ha = MODULO(ha-12.,24.) + 12.
;type,'hour angle at Greenwich ',dms(sidg-ra)
;type,'hour angle at La Palma ',dms(ha)
end




PRO lapalma_azel,ha,dec,az,el
;computes the azel of the sun in radians given ha in hours and dec in degrees
;  latitude of obs.
        la=28.758*!dtor
dr=dec*!dtor            ;radian form of declination
hr=ha*(360.D0/24.D0)*!dtor      ;and of hour angle
;use Ken's formula from gdr.ana
s1=sin(la)*sin(dr)
c1=cos(la)*cos(dr)*cos(hr)
xq=s1+c1
xq=xq<1.0   &   xq=xq>(-1.0)
el=asin(xq)
s1=sin(dr)-sin(la)*xq
c1=cos(la)*sqrt(1.-xq*xq)
xq=s1/c1
xq=xq<1.0   &   xq=xq>(-1.0)
az=acos(xq)
;Ken's formula loses the az sign, we can restore it using the ha sign, at
;least for La Palma
az=az+(ha gt 0)*(2.*!pi-2.*az)
az=az-!pi
end






PRO IM_ROT,az,el,ra,RA1,RA2,t1,t2,t3
; Gives the image rotation as a function of telescope
; coordinates and observation table at the Swedish Solar
; Observatory, La Palma.

; Looking at the projected primary image the rotation is
; clockwise during the morning up the meridian passage
; and then counterclockwise during the afernoon.

; Input parameters: AZ  azimuth of Sun in radians
;                   EL  elevation of Sun in radians
;                        TC  table constant in radians
;                            a constant depending on which observation
;                            table is used. TC is about 48 to give
;                            the angle between the table surface
;                            and the N-S direction at the first
;                            observation table.

; Output parameter: RA  rotation angle in radians

; Adapted from Goran Hosinsky

LAT=28.758*!dtor     ;observatory latitude (La Palma)
TC=318.0*!dtor   ;table constant

; According to spherical astronomy the angle between the N-S
; great circle and the vertical great circle in an AZ-EL
; telescope varies as:

t1=((EL-LAT)/2.0)
t2=((!pi-EL-LAT)/2.0)
t3=tan(0.5*(!pi-AZ))
t3=t3<1.E20
ra1=atan(cos(t1)/cos(t2),t3)+atan(sin(t1)/sin(t2),t3)

; In the image plane the angle of the movement in Elevation
; varies as:

ra2=AZ+(atan(cos(EL),sin(EL)))+TC

RA=ra2-ra1

END




FUNCTION DIFFER,X
;
; function differ, call is D=DIFFER(X)
; returns differences between elements in the first dimension only
; 2 and 3-D arrays are handled as series of 1-D's
;
nd = SIZE(x)
nx = nd(1)
nd = nd(0)
CASE 1 OF
        nd EQ 0: RETURN,x
        nd EQ 1: dx = x(1:*) - x(0:(nx-2))
        nd EQ 2: dx = x(1:*,*) - x(0:(nx-2),*)
        nd EQ 3: dx = x(1:*,*,*) - x(0:(nx-2),*,*)
        ELSE: MESSAGE,'DIFFER is not intended for dimensions >3'
ENDCASE
RETURN,dx
END



FUNCTION LPANGLES,YEAR,MONTH,DOM,SDAY
;+
; NAME:
;	LPANGLES
;
; PURPOSE:
;	Compute field rotation angle at the Swedish Solar Vacuum
;	Telescope at the Observatorio del Roque de los Muchachos
;	on the island of La Palma.
;
; CALLING SEQUENCE:
;	Result = LPANGLES(YEAR,MONTH,DOM,SDAY)
;
; INPUTS:
;	YEAR = year (just the 2 digits please; e.g. 88, not 1988)
;
;	MONTH = the number of the month (e.g., September is 9)
;
;	DOM = the number of the day of the month (e.g. 22)
;
;	SDAY = UT seconds from midnight. It can be a vector (see examples)
;
; OUTPUT:
;	Result = returns the corresponding angle in radians.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	The hour angle and declination of the Sun at the Swedish Telescope on
;	La Palma is calculated and used to find the parallactic angle.
;
; EXAMPLES:
;	To calculate the field rotation angle of a set of 100 images taken
;	at the Swedish telescope on August 21, 1989, starting at 08:00 UT,
;	with a time interval between frames of 30 s, we do:
;
;	IDL> year = 89
;	IDL> month = 8
;	IDL> dom = 21
;	IDL> sday = 8*3600.+FINDGEN(100)*30
;	IDL> ang = LPANGLES(year,month,dom,sday)*!radeg	   ;rad. to degrees.
;
;	which provides us with a vector containing 100 angles, where
;	ang(0) = 0, i.e. images are rotated with respect to the first one.
;
; MODIFICATION HISTORY:
;	Copied from ANA, R. Molowny-Horas.
;-
ON_ERROR,2

	IF N_PARAMS(0) NE 4 THEN MESSAGE,'Inputs must be YEAR,MONTH,DOM,SDAY'

	LAPALMASUN,year,month,dom,sday,ha,dec
	LAPALMA_AZEL,ha,dec,az,el
	IM_ROT,az,el,ra,ra1,ra2,t1,t2,t3
	d = DIFFER(ra)			;take out shifts of size pi
	FOR k=1,5 DO d = d + !pi*(d LT -1.0) - !pi*(d GT 1.0)
	ra = [0,RUNSUM(d)]
	RETURN,ra

END
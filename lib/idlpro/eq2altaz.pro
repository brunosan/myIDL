pro EQ2ALTAZ,ha,dec,phi,alt,az

; OUTPUT
;  	alt: altitude in radians
;	az: azimuth in radians
; INPUT
;	ha: hour angle in radians
;	dec: declination in radians
;	phi: site latitude in radians


sinalt=sin(dec)*sin(phi)+ cos(dec)*cos(phi)*cos(ha)
alt=asin(sinalt)

sinaz=cos(dec)*sin(ha)/cos(alt)
cosaz=(cos(dec)*sin(phi)*cos(ha)-sin(dec)*cos(phi))/cos(alt)
az=atan(-sinaz,-cosaz)

return
end

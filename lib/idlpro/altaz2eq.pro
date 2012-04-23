pro ALTAZ2EQ,alt,az,phi,ha,dec

; INPUT
;  	alt: altitude in radians
;	az: azimuth in radians
;	phi: site latitude in radians
; OUTPUT
;	ha: hour angle in radians
;	dec: devlinatin in radians

sindec=sin(alt)*sin(phi)+cos(alt)*cos(phi)*cos(az)
dec=asin(sindec)

sinha= -cos(alt)*sin(az)/cos(dec)
cosha= (sin(alt)*cos(phi)-cos(alt)*sin(phi)*cos(az))/cos(dec)

ha=atan(sinha,cosha)

return
end

function mirror, rs, rp, ret
;+
;
;	function:  mirror
;
;	purpose:  compute the Mueller Matrix of a mirror
;
;	author:  paul@ncar, 10/94
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	matrix = mirror( rs, rp, ret)"
	print
	print, "	Compute the Mueller Matrix of a mirror
	print
	print, "	Arguments:"
	print, "		rs	- reflectance perpendicular to"
	print, "			  angle of incidence"
	print, "		rp	- reflectance parallel to angle of"
	print, "			  incidence"
	print, "		ret	- phase difference between rs and rp"
	print
	return, 0
endif
;-
;ret	Phase difference between rs and rp (radians); range
;       must lie between 0 and 180 deg,the latter for 0-inci-
;       dence angle.
;
;This is the cannonical form.
;Here y-axis is perpendicular to incidence plane
;and x-axis pointing towards 
;mirr normal ie  away from the mirr. surface
;This puts the fast along the x-axis.
;The coordinate system is RH with z
;along propagation.

sinret  = sin(ret)
cosret  = cos(ret)
sqrtrho = sqrt(rs*rp)

r11 = (rp+rs)/2.
r12 = (rp-rs)/2.
r33 = sqrtrho*cosret
r34 = sqrtrho*sinret

return, setmtx ( r11,  r12,   0.,   0. $
               , r12,  r11,   0.,   0. $
               ,  0.,   0.,  r33,  r34 $
               ,  0.,   0., -r34,  r33 )
end

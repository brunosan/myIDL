function vttmtx, vttaz, vttel, tblpos $
               , winret, winang       $
               , exret, exang         $
               , offout               $
               , rs, rp, ret          $
               , prirs, prirp, priret
;+
;
;	function:  vttmtx
;
;	purpose:  return the unnormalized telescope matrix for the
;		  vacuum tower telescope
;
;	author:  paul@ncar, 9/92
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 14 then begin
	print
	print, "usage:	T = vttmtx( vttaz, vttel, tblpos    $"
	print, "                     , winret, winang       $"
	print, "                     , exret, exang         $"
	print, "                     , offout               $"
	print, "                     , rs, rp, ret          $"
	print, "                     , prirs, prirp, priret )"
	print
	print, "       Return the 4x4 vacuum tower telescope matrix."
	print
	print, "       To normalize the matrix:"
	print
	print, "           T = T/T(0,0)" 
	print
	print, "       To print the matrix:"
	print
	print, "           print, transpose( T )"
	print
	return, 0
endif
;-
			;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This function returns the unnormalized telescope matrix for the
;vacuum tower telescope.   See 'usage:' above for how to normalize.
;
;Output:
;
;       vttmtx	Four by four telescope matrix.
;
;Input:		(All angles are in degrees).
;
;	vttaz   Azimuth reported by telescope.
;	vttel	Elevation reported by telescope.
;	tblpos	Table position reported by telescope.
;	winret	Retardance of entrance window.
;	winang	Angle of entrance retardance.
;	exret	Exit port retardance.
;	exang	Exit port angle.
;	offout	Polarimeter rotation on exit port.
;	rs	Azimuth & elevation mirror reflectance perpendicular to
;		plain of incidence.
;	rp	Azimuth & elevation mirror reflectance in the
;		plain of incidence.
;	ret	Phase difference between rs and rp.
;	prirs	Primary mirror reflectance perpendicular to
;		plain of incidence.
;	prirp	Primary mirror reflectance in the
;		plain of incidence.
;	priret	Phase difference between prirs and prirp.
;
;Paul Seagraves 92.09.03
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Convert degrees to radians.
			;
rpd = !pi/180.
rvttaz  = rpd*vttaz
rvttel  = rpd*vttel
rtblpos = rpd*tblpos
rwinret = rpd*winret
rwinang = rpd*winang
rexret  = rpd*exret
rexang  = rpd*exang
roffout = rpd*offout
rret    = rpd*ret
rpriret = rpd*priret
			;
			;Entrance window matrix (retarder).
			;
sd = sin( rwinret )
cd = cos( rwinret )
s  = sin( 2.*rwinang )
c  = cos( 2.*rwinang )
s2 = s*s
c2 = c*c
winmtx = setmtx(                       $
  1.,          0.,          0.,    0.  $
, 0.,    c2+s2*cd, c*s*(1.-cd), -s*sd  $
, 0., c*s*(1.-cd),    s2+c2*cd,  c*sd  $
, 0.,        s*sd,       -c*sd,    cd  )
			;
			;Exit window matrix (retarder).
			;
sd = sin( rexret )
cd = cos( rexret )
s  = sin( 2.*rexang )
c  = cos( 2.*rexang )
s2 = s*s
c2 = c*c
exmtx = setmtx(                        $
  1.,          0.,          0.,    0.  $
, 0.,    c2+s2*cd, c*s*(1.-cd), -s*sd  $
, 0., c*s*(1.-cd),    s2+c2*cd,  c*sd  $
, 0.,        s*sd,       -c*sd,    cd  )
			;
			;Azimuth and elevation mirror matrix.
			;
rt = sqrt( rs*rp )
sd = sin( rret )
cd = cos( rret )
mirmtx = setmtx(                              $
  .5*(rp+rs), .5*(rp-rs),       0.,       0.  $
, .5*(rp-rs), .5*(rp+rs),       0.,       0.  $
,         0.,         0.,    rt*cd,    rt*sd  $
,         0.,         0.,   -rt*sd,    rt*cd  )
			;
			;Primary mirror matrix.
			;
rt = sqrt( prirs*prirp )
sd = sin( rpriret )
cd = cos( rpriret )
primtx = setmtx(                                         $
  .5*(prirp+prirs), .5*(prirp-prirs),       0.,      0.  $
, .5*(prirp-prirs), .5*(prirp+prirs),       0.,      0.  $
,               0.,               0.,    rt*cd,   rt*sd  $
,               0.,               0.,   -rt*sd,   rt*cd  )
			;
			;Rotation matrix between elevation and azimuth mirrors.
			;
s = sin( 2.*(rvttel+.5*!pi) )
c = cos( 2.*(rvttel+.5*!pi) )
elmtx = setmtx(   $
  1., 0., 0., 0.  $
, 0.,  c,  s, 0.  $
, 0., -s,  c, 0.  $
, 0., 0., 0., 1.  )
			;
			;Rotation matrix between azimuth and primary mirrors.
			;
s = sin( 2.*(rtblpos-rvttaz-!pi/6.) )
c = cos( 2.*(rtblpos-rvttaz-!pi/6.) )
azmtx = setmtx(   $
  1., 0., 0., 0.  $
, 0.,  c,  s, 0.  $
, 0., -s,  c, 0.  $
, 0., 0., 0., 1.  )
			;
			;Rotation from primary mirror to polarimeter.
			;
s = sin( 2.*roffout )
c = cos( 2.*roffout )
offmtx = setmtx(  $
  1., 0., 0., 0.  $
, 0.,  c,  s, 0.  $
, 0., -s,  c, 0.  $
, 0., 0., 0., 1.  )
			;
			;Return the instrument matrix (matrix product).
			;
return, offmtx # exmtx # primtx # azmtx # mirmtx # elmtx # mirmtx # winmtx 
			;
end
			;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

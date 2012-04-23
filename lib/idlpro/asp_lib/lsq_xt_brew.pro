pro lsq_xt_brew_usage
;+
;
;	procedure:  lsq_xt_brew
;
;	purpose:  VTT instrument model calculation for lsq_xt.
;
;	author:  paul@ncar, 10/94
;
;	routines:  lsq_xt_brew_usage  lsq_xt_rot  lsq_xt_retard
;		   lsq_xt_tv
;		   lsq_xt_brew
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	lsq_xt_brew $"
	print, "	, light, offin, bias $"
	print, "	, rt0, rn0, rk0 $"
	print, "	, isrc, elev, step, ta, az, normi $"
	print, "	, ifcallin, sinlin, coslin $"
	print, "	, ifcalret, sinret, cosret $"
	print, "	, offout $"
	print, "	, winret, winang $"
	print, "	, exret, exang $"
	print, "	, azelrs, azelrp, azelret, azelmtx $"
	print, "	, primrs, primrp, primret, primmtx $"
	print, "	, tx, ty, rtda, rtd, erar, dlc, rrsm, rrdf $"
	print, "	, xmtx, gain $"
	print, "	, vecout"
	print
	print, "	VTT instrument model calculation for lsq_xt"
	print, "	Generates telescope output stokes vector vecout(4)"
	print, "	from parameter set."
	print
	print, "	Arguments (all angles in radians):"
	print
	print, "		(input)"
	print, "		light	- array of light source vectors,"
	print, "			  first dimension is 4 corresponding"
	print, "			  to stokes components;"
	print, "			  specific source picked by isrc below"
	print, "		offin	- array with one element for each"
	print, "			  light source."
	print, "			  Angles from light sources ccw to"
	print, "			  elevation mirror ref. frame."
	print, "			  For polarization device over"
	print, "			  entrance window the 'step' below"
	print, "			  will be added."
	print, "		bias	- array with one element for each"
	print, "			  light source."
	print, "			  Bias is added to i stokes component"
	print, "		rt0	- thickness mirror metallic layer as"
	print, "			  fraction of wavelength"
	print, "		rn0	- index of refraction for mirror metal"
	print, "		rk0	- index of extinction for mirror metal"
	print, "		isrc	- index to source in 'light' above"
	print, "		elev	- elevation angle of observation"
	print, "		step	- angle of polarization device"
	print, "			  over entance window"
	print, "		ta	- VTT table angle"
	print, "		az	- azimuth angle of observation"
	print, "		normi	- 1 if output vector is normalized"
	print, "		ifcallin - 1 if linear cal polarizer present"
	print, "		sinlin	- sin fast axis linear cal polarizer"
	print, "		coslin	- cos fast axis linear cal polarizer"
	print, "		ifcalret - 1 if cal retarder present"
	print, "		sinret	- sin fast axis cal retarder"
	print, "		cosret	- cos fast axis cal retarder"
	print, "		offout	- angle from exit port ccw to"
	print, "			  polarimeter"
	print, "		winret	- retardance entrance window"
	print, "		winang	- angle entrance window retardance"
	print, "		exret	- exit port retardance"
	print, "		exang	- angle exit port retardance"
	print, "		tx	- cal linear polarizer"
	print, "			  x transmittance"
	print, "		ty	- cal linear polarizer"
	print, "			  y transmittance"
	print, "		rtda	- cal linear polarizer"
	print, "		rtd	- cal linear polarizer"
	print, "		erar	- cal retarder mount error angle"
	print, "		dlc	- cal retarder retardance"
	print, "		rrsm	- cal retarder residual sum"
	print, "			  x & y transmittance"
	print, "		rrdf	- cal retarder residual difference"
	print, "			  x & y transmittance"
	print, "		xmtx	- 4x4 polarimeter matrix"
	print, "		gain	- over all gain factor"
	print
	print, "		(output)"
	print, "		azelrs	- elevation & azimuth mirror"
	print, "			  reflectance perpendicular to"
	print, "			  angle of incidence"
	print, "		azelrp	- elevation & azimuth mirror"
	print, "			  reflectance parallel to"
	print, "			  angle of incidence"
	print, "		azelret	- phase difference between"
	print, "			  azelrs and azelrp"
	print, "		azelmtx	- elevation & azimuth mirror matrix"
	print, "		primrs	- primary mirror"
	print, "			  reflectance perpendicular to"
	print, "			  angle of incidence"
	print, "		primrp	- primary mirror"
	print, "			  reflectance parallel to"
	print, "			  angle of incidence"
	print, "		primret	- phase difference between"
	print, "			  primrs and primrp"
	print, "		primmtx	- primary mirror matrix"
	print
	print, "		(input & output)"
	print, "		vecout	- stokes vector."
	print
	print, "	Keywords:"
	print, "		(none)"
	return
endif
;-
end
;-----------------------------------------------------------------------------
;
;	procedure:  lsq_xt_rot
;
;	prupose:  apply rotation to stokes vector
;
;-----------------------------------------------------------------------------
pro lsq_xt_rot, ix, angle, vec
				    ;Common to save some information.
common lsq_xt_rot_com, ixsz, savang, s, c
if n_elements(ixsz) eq 0 then begin
	ixsz = 10
	savang = fltarr(ixsz)
	s      = sin(2.*savang)
	c      = cos(2.*savang)
end
				    ;Compute sin and cos if angle changed.
if savang(ix) ne angle then begin
	savang(ix) = angle
	c(ix) = cos(2.*angle)
	s(ix) = sin(2.*angle)
end

rotq =  c(ix)*vec(1) + s(ix)*vec(2)
rotu = -s(ix)*vec(1) + c(ix)*vec(2)

vec(1) = rotq
vec(2) = rotu

end
;-----------------------------------------------------------------------------
;
;	procedure:  lsq_xt_retard
;
;	purpose: apply retardance to a stokes vector.
;
;-----------------------------------------------------------------------------
pro lsq_xt_retard, ix, delt, thet, v

				    ;Save some info in common.
common lsq_xt_retard_com, ixsz, savthet, savdelt, s, c, sd, cd
if n_elements(ixsz) eq 0 then begin
	ixsz = 10
	savthet = fltarr(ixsz)
	s       = sin(2.*savthet)
	c       = cos(2.*savthet)
	savdelt = fltarr(ixsz)
	sd      = sin(savdelt)
	cd      = cos(savdelt)
end
				    ;Compute sin's and cos's only as needed.
if delt ne savdelt(ix) or thet ne savthet(ix) then begin
	savthet(ix) = thet
	c(ix)       = cos(2.*thet)
	s(ix)       = sin(2.*thet)
	savdelt(ix) = delt
	sd(ix)      = sin(delt)
	cd(ix)      = cos(delt)
end
				    ;Rotate to fast axis.
v1   =  c(ix)*v(1) + s(ix)*v(2)
v2   = -s(ix)*v(1) + c(ix)*v(2)
				    ;Apply retardance.
vr2  =   cd(ix)*v2 + sd(ix)*v(3)
v(3) =  -sd(ix)*v2 + cd(ix)*v(3)
				    ;Rotate back to incoming frame.
v(1) =    c(ix)*v1 - s(ix)*vr2
v(2) =    s(ix)*v1 + c(ix)*vr2

end
;-----------------------------------------------------------------------------
;
;	procedure:  lsq_xt_tv
;
;	purpose:  multiply stokes vector by properties of the VTT
;
;-----------------------------------------------------------------------------
pro lsq_xt_tv $
, winret, winang $
, elmtx $
, rotel $
, azmtx $
, rotaz $
, primmtx $
, rotout $
, exret, exang $
, vecout

;This subroutine applies properties of the 
;Vacuum Tower Telescope to stokes vector vecout.
;
;variables are reals.  angles in radians
;	winret	Retardance of entrance window
;	winang	Angle of entrance retardance
;	elmtx   Matrix for elevation mirror
;	rotel	Rotation in elevation
;	azmtx   Matrix for azimuth mirror
;	rotaz	Rotation from azimuth mirror to primary mirror
;	primmtx Matrix for main mirror
;	rotout	Rotation from primary mirror to exit port
;	exret	Exit port retardance
;	exang	Exit port angle
;
;	vecout	Stokes vector (input & output).
;
;When using angles reported by the telescope...
;	rotel =   ( elevation_angle + pi/2 )
;where elevation_angle is the elevation reported by the VTT.
;	
;       rotaz = table_angle - azimuth_angle - 30.
;where table_angle and azimuth angle_angle are those reported
;by the VTT 
;
;David Elmore
;Fri Oct 31 13:14:51 MST 1986
;modified by Skumanich 03 June 1992
;modified by Skumanich 06 July 1992

				    ;Apply entrance window retardance.
lsq_xt_retard, 0, winret, winang, vecout

				    ;Multiply by elevation mirror matrix.
vecout = elmtx # vecout
				    ;Rotate to elevation angle.
lsq_xt_rot, 1, rotel, vecout
				    ;Multiply by azimuth mirror matrix.
vecout = azmtx # vecout
				    ;Rotation from Az mirror to main mirror.
lsq_xt_rot, 2, rotaz, vecout
				    ;Multiply by main mirror matrix.
vecout = primmtx # vecout
				    ;Rotation from primary mirror to
				    ;exit port
if rotout ne 0. then  lsq_xt_rot, 3, rotout, vecout

				    ;Apply exit window retardance.
lsq_xt_retard, 1, exret, exang, vecout

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_brew
;
;	purpose:  VTT instrument model calculation for lsq_xt.
;
;------------------------------------------------------------------------------
pro lsq_xt_brew $
, light, offin, bias $
, rt0, rn0, rk0 $
, isrc, elev, step, ta, az, normi $
, ifcallin, sinlin, coslin $
, ifcalret, sinret, cosret $
, offout $
, winret, winang $
, exret, exang $
, azelrs, azelrp, azelret, azelmtx $
, primrs, primrp, primret, primmtx $
, tx, ty, rtda, rtd, erar, dlc, rrsm, rrdf $
, xmtx, gain $
, vecout

dpr = 180./!pi
rpd = 1./dpr
				    ;Check number of parameters.
if n_params() eq 0 then begin
	lsq_xt_brew_usage
	return
end
				    ;Save some information in common. 
common lsq_xt_brew_com $
, pptxty,  pptuv $
, rrtxty,  rrtuv $
,   artd,   srtd,   crtd $
,   aerr,   serr,   cerr $
,  rtdsv, srtdsv, crtdsv $
,  dlcsv, sdlcsv, cdlcsv $
,  savn0,  savk0,  savt0 $
, savazelrs, savazelrp, savazelret, savazelmtx $
, savprimrs, savprimrp, savprimret, savprimmtx

				    ;Initialize common.
if n_elements(pptxty) eq 0 then begin
	pptxty= 0. &  pptuv=0. 
	rrtxty= 0. &  rrtuv=0. 
	  artd= 0. &   srtd=0.  &   crtd=1.
	  aerr= 0. &   serr=0.  &   cerr=1.
	 rtdsv= 0. & srtdsv=0.  & crtdsv=1.
	 dlcsv= 0. & sdlcsv=0.  & cdlcsv=1.
	 savn0=-1. &  savk0=-1. &  savt0=-1.
end

				    ;Compute reflectivity of mirrors
				    ;from basic constants.
if rn0 ne savn0 or rk0 ne savk0 or rt0 ne savt0 then begin

	savn0 = rn0
	savk0 = rk0
	savt0 = rt0
				    ;Calculate polarization.
	rflctvty, rt0,rn0,rk0,45.*rpd,savazelrs,savazelrp,savazelret
	rflctvty, rt0,rn0,rk0,   .022,savprimrs,savprimrp,savprimret

				    ;Form mirror matrices.
	savazelmtx = mirror( savazelrs, savazelrp, savazelret )
	savprimmtx = mirror( savprimrs, savprimrp, savprimret )
end

azelrs  = savazelrs
azelrp  = savazelrp
azelret = savazelret
azelmtx = savazelmtx
primrs  = savprimrs
primrp  = savprimrp
primret = savprimret
primmtx = savprimmtx
				    ;Set initial vector.
vecout = light(*,isrc)
				    ;Best guess for rotel 7/06/92 from Sku.
rotel  = elev+!pi/2.
				    ;Best guess for rotin 5/28/92 from Sku.
rotin  = step+offin(isrc)
				    ;Stay in mirror frame through exit
				    ;window to polarimeter.
rotout = 0.
				    ;Best guess for rotel 7/6/92 from Sku.
rotaz  = ta-az-(30.*rpd)
				    ;Input rotation.
lsq_xt_rot, 0, rotin, vecout
				    ;Multiply by telescope properties.
lsq_xt_tv $
, winret, winang $
, azelmtx $
, rotel $
, azelmtx $
, rotaz $
, primmtx $
, rotout $
, exret, exang $
, vecout
				    ;Orientation of polarimeter wrt port 
lsq_xt_rot, 4, offout, vecout
				    ;Calibration linear polarizer.
if ifcallin ne 0 then begin
				    ;Rotate to fast azis.
	rq =  coslin*vecout(1)+sinlin*vecout(2)
	ru = -sinlin*vecout(1)+coslin*vecout(2)
	vecout(1) = rq
	vecout(2) = ru
				    ;Apply linear polarization.
	if tx*ty ne pptxty then begin
		pptxty = tx*ty
		pptuv  = sqrt(pptxty)
	end
	ri = .5*((tx+ty)*vecout(0)+(tx-ty)*vecout(1))
	rq = .5*((tx-ty)*vecout(0)+(tx+ty)*vecout(1))
	vecout(0) = ri
	vecout(1) = rq
	vecout(2) = pptuv*vecout(2)
	vecout(3) = pptuv*vecout(3)
				    ;Rotate to axis of residual retardance.
	if artd ne rtda then begin
		artd = rtda
		srtd = sin(2.*rtda)
		crtd = cos(2.*rtda)
	end
	rq =  crtd*vecout(1)+srtd*vecout(2)
	ru = -srtd*vecout(1)+crtd*vecout(2)
	vecout(1) = rq
	vecout(2) = ru
				    ;Apply residual retardance.
	if rtdsv ne rtd then begin
		rtdsv = rtd
		srtdsv = sin(rtd)
		crtdsv = cos(rtd)
	end
	ru =  crtdsv*vecout(2)+srtdsv*vecout(3)
	rv = -srtdsv*vecout(2)+crtdsv*vecout(3)
	vecout(2) = ru 
	vecout(3) = rv
				    ;Rotate from axis of residual retardance
				    ;to fast axis.
	rq =  crtd*vecout(1)-srtd*vecout(2)
	ru =  srtd*vecout(1)+crtd*vecout(2)
	vecout(1) = rq
	vecout(2) = ru
				    ;Rotate to incoming frame.
	rq =  coslin*vecout(1)-sinlin*vecout(2)
	ru =  sinlin*vecout(1)+coslin*vecout(2)
	vecout(1) = rq
	vecout(2) = ru
end
				    ;Calibration retarder.
if ifcalret ne 0 then begin
				    ;Rotate to correct for mounting error.
	if aerr ne erar then begin
		aerr = erar
		serr = sin(2.*erar)
		cerr = cos(2.*erar)
	end
	rq =  cerr*vecout(1)+serr*vecout(2)
	ru = -serr*vecout(1)+cerr*vecout(2)
	vecout(1) = rq
	vecout(2) = ru
				    ;Rotate to fast axis.
	rq =  cosret*vecout(1)+sinret*vecout(2)
	ru = -sinret*vecout(1)+cosret*vecout(2)
	vecout(1) = rq
	vecout(2) = ru
				    ;Apply retardance.
	if dlcsv ne dlc then begin
		dlcsv  = dlc
		sdlcsv = sin(dlc)
		cdlcsv = cos(dlc)
	end
	ru =  cdlcsv*vecout(2)+sdlcsv*vecout(3)
	rv = -sdlcsv*vecout(2)+cdlcsv*vecout(3)
	vecout(2) = ru 
	vecout(3) = rv
				    ;Apply linear polarization.
	tmpxy = .25*(rrsm*rrsm-rrdf*rrdf)
	if tmpxy ne rrtxty then begin
		rrtxty = tmpxy
		rrtuv  = sqrt(rrtxty)
	end
	ri = .5*(rrsm*vecout(0)+rrdf*vecout(1))
	rq = .5*(rrdf*vecout(0)+rrsm*vecout(1))
	vecout(0) = ri
	vecout(1) = rq
	vecout(2) = rrtuv*vecout(2)
	vecout(3) = rrtuv*vecout(3)
				    ;Rotate from fast axis to frame with
				    ;mounting error.
	rq =  cosret*vecout(1)-sinret*vecout(2)
	ru =  sinret*vecout(1)+cosret*vecout(2)
	vecout(1) = rq
	vecout(2) = ru
				    ;Remove mounting error
				    ;(rotate to frame of incoming light).
	rq =  cerr*vecout(1)-serr*vecout(2)
	ru =  serr*vecout(1)+cerr*vecout(2)
	vecout(1) = rq
	vecout(2) = ru
end
				    ;Multiply by responce matrix.
vecout = xmtx # vecout
				    ;Multiply by gain.
vecout = gain*vecout
				    ;Subtract bias.
vecout(0) = vecout(0)-bias(isrc)
				    ;Normalize with intensity.
if normi eq 1 then  vecout=vecout/vecout(0)

end

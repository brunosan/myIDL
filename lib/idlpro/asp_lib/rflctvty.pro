pro rflctvty_usage
;+
;
;	procedure:  rflctvty
;
;	purpose:  Compute the reflectance and retardance of a metal
;		  mirror given its index of refraction, index of
;		  extinction, and thickness of metallic layer.
;
;	author:  elmore@ncar, 7/88      (mod's by paul@ncar)
;
;	routines:  rflctvty_usage   cmul   cdiv   rflctvty
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	rflctvty, t0, n0, k0, anginc, rs, rp, ret"
	print
	print, "	Compute the reflectance and retardance of a metal"
	print, "	mirror given its index of refraction, index of"
	print, "	extinction, and thickness of metallic layer."
	print
	print, "	Arguments:"
	print, "		t0	- thickness of metallic layer as"
	print, "			  fraction of wavelength"
	print, "		n0	- index of refraction for a metal"
	print, "		k0	- index of extinction for a metal"
	print, "		anginc	- angle of incidence in radians"
	print, "		rs	- reflectance perpendicular to"
	print, "			  angle of incidence"
	print, "		rp	- reflectance parallel to angle of"
	print, "			  incidence"
	print, "		ret	- phase difference between rs and rp"
	print
	print, "	This treatment follows an explanation by Egidio"
	print, "	Landi 7/29/93"
	print
	print, "	Reference: Born and Wolf,Principles of Optics,"
	print, "		   Pergamon Press,Sections 1.5 13.2 13.4"
	print, "		   of 4th Edition 1970"
	print, "	
	return
endif
;-
end
;-----------------------------------------------------------------------------
;
;	function:  cmul
;
;	purpose:  Return product of size two array used as complex numbers
;
;-----------------------------------------------------------------------------
function cmul, a, b
	c = [ a(0)*b(0)-a(1)*b(1), a(0)*b(1)+a(1)*b(0) ]
	return, [ a(0)*b(0)-a(1)*b(1), a(0)*b(1)+a(1)*b(0) ]
end
;-----------------------------------------------------------------------------
;
;	function:  cdiv
;
;	purpose:  Return quotient of size two array used as complex numbers
;
;-----------------------------------------------------------------------------
function cdiv, a, b
	return, [ a(0)*b(0)+a(1)*b(1), -a(0)*b(1)+a(1)*b(0) ] $
	       / (b(0)*b(0)+b(1)*b(1))
end
;-----------------------------------------------------------------------------
;
;	procedure:  rflctvty
;
;	purpose:  Compute the reflectance and retardance of a metal
;		  mirror given its index of refraction, index of
;		  extinction, and thickness of metallic layer.
;
;-----------------------------------------------------------------------------
pro rflctvty, t0, n0, k0, anginc, rs, rp, ret

				    ;Index of refraction of underlying
				    ;dielectric.
nu = 1.54D

dt0 = double( t0 )
dn0 = double( n0 )
dk0 = double( k0 )
danginc = double( anginc )

s = sin( danginc )
c = cos( danginc )
t = tan( danginc )

s2 = s*s
t2 = t*t

n02 = dn0*dn0
k02 = dk0*dk0

fac = sqrt( (n02 - k02 - s2)^2 + 4.*n02*k02 )

you = sqrt( .5*( fac + n02 - k02 - s2 ) )
vee = sqrt( .5*( fac - n02 + k02 + s2 ) )

cosa = sqrt( 1.-s2/(nu*nu) )

youivee  = [ you, vee ]

twoeta = ( 4. * 3.14159265358979323846D ) * dt0
tee = exp( -twoeta*vee )*[ cos( twoeta*you ), sin( twoeta*you ) ]

n0ik02 = cmul( [ dn0, dk0 ], [ dn0, dk0 ] )

rxx = cdiv( (n0ik02*c-youivee) $
          , (n0ik02*c+youivee) )

sxx = cdiv( (nu*youivee-n0ik02*cosa) $
          , (nu*youivee+n0ik02*cosa) )

ryy = cdiv( ([c,0.]-youivee) $
          , ([c,0.]+youivee) )

syy = cdiv( (youivee-[nu*cosa,0.]) $
          , (youivee+[nu*cosa,0.]) )

Rx = cdiv( (rxx+cmul(sxx,tee)), ([1.,0.]+cmul(rxx,cmul(sxx,tee))) )
Ry = cdiv( (ryy+cmul(syy,tee)), ([1.,0.]+cmul(ryy,cmul(syy,tee))) )

RR = cmul( Rx, [ Ry(0), -Ry(1) ] )

rp  = float( Rx(0)*Rx(0)+Rx(1)*Rx(1) )
rs  = float( Ry(0)*Ry(0)+Ry(1)*Ry(1) )
ret = float( atan( -RR(1), RR(0) )   )

end

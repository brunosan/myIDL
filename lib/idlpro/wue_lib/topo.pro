;+
; NAME:
;       TOPO
; PURPOSE:
;       Make a monochrome shaded relief view of a surface.
; CATEGORY:
; CALLING SEQUENCE:
;       t = topo(z, az, ax)
; INPUTS:
;       z = array of elevations to shade.                       in 
;       az = light source angle from zenith in deg (def = 45).  in 
;       ax = light source angle from x axis in deg (def = 45).  in 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: there are no true shadows. 
; MODIFICATION HISTORY:
;       R. Sterner. 19 Nov, 1987.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION TOPO, S0, AZ, AX, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Make a monochrome shaded relief view of a surface.'
	  print,' t = topo(z, az, ax)'
	  print,'   z = array of elevations to shade.                       in'
	  print,'   az = light source angle from zenith in deg (def = 45).  in'
	  print,'   ax = light source angle from x axis in deg (def = 45).  in'
	  print,' Note: there are no true shadows.'
	  return, -1
	endif
 
	NP = N_PARAMS(0)
	IF NP LT 3 THEN AX = 45.
	IF NP LT 2 THEN AZ = 45.
 
	S = FLOAT(S0)	
	NX = SHIFT(S, 1, 0) - S		; Surface normals.
	NY = SHIFT(S, 0, 1) - S
	nx(0,0) = nx(1,*)		; Copy adjacent values to
	nx(0,0) = nx(*,1)		; avoid edge effects.
;	NX = NX(1:*,1:*)		; trim edge effect.
	ny(0,0) = ny(1,*)
	ny(0,0) = ny(*,1)
;	NY = NY(1:*,1:*)
	NZ = NX*0. + 1.
	NL = SQRT(NX^2 + NY^2 + NZ^2)	; normal length.
	NX = NX/NL			; unit normal.
	NY = NY/NL
	NZ = NZ/NL
 
	POLREC3D, 1, AZ/!RADEG, AX/!RADEG, LX, LY, LZ	; light vector.
 
	R = NX*LX + NY*LY + NZ*LZ	; dot product.
	W = array(WHERE(R LT 0.0))
	if w(0) ne -1 then r(w) = 0
 
	RETURN, R
	END

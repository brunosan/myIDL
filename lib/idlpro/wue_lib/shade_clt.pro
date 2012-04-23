;+
; NAME:
;       SHADE_CLT
; PURPOSE:
;       Sets up color table used for sun_shade shaded relief displays.
; CATEGORY:
; CALLING SEQUENCE:
;       shade_clt, [ct]
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ct = optionally returned color table (3X256: r,g,b).   out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       J. Culbertson, 15 Feb, 1989.
;       re-entered by RES.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 31 Aug, 1989 --- converted to SUN.
;	R. Sterner, 26 Feb, 1991 --- Renamed from shade_colors.pro
;-
 
	PRO SHADE_CLT, CT, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Sets up color table used for sun_shade shaded '+$
	    'relief displays.'
	  print,' shade_clt, [ct]'
	  print,'   ct = optionally returned color table (3X256: r,g,b).   out'
	  return
	endif
 
	R = INTARR(256)
	G = R
	B = R
 
	FOR I = 0, 7 DO BEGIN
	  FOR J = 0, 15 DO BEGIN
	    M = 16*I + J
	    R(M) = 2*I*(J+1) - 1 > 0
	    G(M) = 16*(J+1)-1
	    B(M) = 0
	  ENDFOR
	ENDFOR
 
	FOR I = 8, 15 DO BEGIN
	  FOR J = 0, 15 DO BEGIN
	    M = 16*I + J
	    R(M) = 16*(J+1) - 1
	    G(M) = (J+1)*(30-2*I) - 1 > 0
	    B(M) = 0
	  ENDFOR
	ENDFOR
 
	R(0) = 255 & G(0) = 255 & B(0) = 255	; 0 = white.
	R(1) = 150 & G(1) = 150 & B(1) = 255	; 1 = blue.
 
	TVLCT, R, G, B
	CT = [TRANSPOSE(R), TRANSPOSE(G), TRANSPOSE(B)]
	RETURN
	END

;+
; NAME:
;       HSV2RGB
; PURPOSE:
;       Convert Hue, Saturation, and Value to Red, Green, Blue fractions.
; CATEGORY:
; CALLING SEQUENCE:
;       hsv2rgb, h, s, v, r, g, b
; INPUTS:
;       h = Hue in [0, 360) deg.                    in 
;           0 = red,   60 = yellow, 120 = green 
;         180 = cyan, 240 = blue,   300 = magenta. 
;       s = saturation (grayness) in [0,1].         in 
;       v = value (brightness) in [0,1].            in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       r =   red fraction in [0,1].                out 
;       g = green fraction in [0,1].                out 
;       b =  blue fraction in [0,1].                out 
; COMMON BLOCKS:
; NOTES:
;       Note: Works for scalars or arrays. 
; MODIFICATION HISTORY:
;       R. Sterner. 18 May, 1988.
;	R. Sterner, 27 Dec 1989 --- converted to SUN.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO HSV2RGB, H0, S0, V0, R, G, B, help=hlp
 
	NP = N_PARAMS(0)
	IF (NP LT 6) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert Hue, Saturation, and Value to Red, Green, Blue fract.'
	  PRINT,' hsv2rgb, h, s, v, r, g, b'
	  PRINT,'   h = Hue in [0, 360) deg.                    in'
	  PRINT,'       0 = red,   60 = yellow, 120 = green'
	  PRINT,'     180 = cyan, 240 = blue,   300 = magenta.'
	  PRINT,'   s = saturation (grayness) in [0,1].         in'
	  PRINT,'   v = value (brightness) in [0,1].            in'
	  PRINT,'   r =   red fraction in [0,1].                out'
	  PRINT,'   g = green fraction in [0,1].                out'
	  PRINT,'   b =  blue fraction in [0,1].                out'
	  PRINT,' Note: Works for scalars or arrays.'
	  RETURN
	ENDIF
 
	flag = isarray(h0)		; Scalar or array?
 
	H = ARRAY(FLOAT(H0))		; Force inputs to be arrays.
	S = ARRAY(FLOAT(S0))
	V = ARRAY(FLOAT(V0))
 
	IF N_ELEMENTS(H) NE N_ELEMENTS(S) THEN BEGIN
	  PRINT,' Error in hsv2rgb:'
	  PRINT,' H, S, V must have same number of elements.'
	  RETURN
	ENDIF
 
	IF N_ELEMENTS(S) NE N_ELEMENTS(V) THEN BEGIN
	  PRINT,' Error in hsv2rgb:'
	  PRINT,' h, s, v must have same number of elements.'
	  RETURN
	ENDIF
 
	IF (MIN(H) LE -360) OR (MAX(H) GT 360) THEN BEGIN
	  PRINT,' Error in hsv2rgb:'
	  PRINT,' Values for Hue must be in the range (-360, 360].'
	  PRINT,' Min, Max = ',MIN(H), MAX(H)
	  RETURN
	ENDIF
 
	IF (MIN(S) LT 0) OR (MAX(S) GT 1) THEN BEGIN
	  PRINT,' Error in hsv2rgb:'
	  PRINT,' Values for Saturation must be in the range [0, 1].'
	  PRINT,' Min, Max = ',MIN(S), MAX(S)
	  RETURN
	ENDIF
 
	IF (MIN(V) LT 0) OR (MAX(V) GT 1) THEN BEGIN
	  PRINT,' Error in hsv2rgb:'
	  PRINT,' Values for Value must be in the range [0, 1].'
	  PRINT,' Min, Max = ',MIN(V), MAX(V)
	  RETURN
	ENDIF
 
	;----------  Start with blacks, grays, whites. -------
	R = V
	G = V
	B = V
 
	;------  Have colors where saturation is non-zero. ----
	WNEZ = WHERE(S NE 0, cntnez)
 
	;--------  force hue to 0 to 360  --------
	H2 = H
	W = WHERE(H2 LT 0, count)			; Force H > 0.
	if count gt 0 then H2(W) = H2(W) + 360.	
 
	if cntnez gt 0 then H2(WNEZ) = (H2(WNEZ) MOD 360.)/60.
	I = FLTARR(N_ELEMENTS(H2)) - 1.			; Init I to -1s.
	if cntnez gt 0 then I(WNEZ) = FIX(H2(WNEZ))	; Do only non-0 values.
	F = I
	if cntnez gt 0 then F(WNEZ) = H2(WNEZ) - I(WNEZ)
	P = I
	if cntnez gt 0 then P(WNEZ) = V(WNEZ)*(1.-S(WNEZ))
	Q = I
	if cntnez gt 0 then Q(WNEZ) = V(WNEZ)*(1.-S(WNEZ)*F(WNEZ))
	T = I
	if cntnez gt 0 then T(WNEZ) = V(WNEZ)*(1.-S(WNEZ)*(1.-F(WNEZ)))
 
	;---------  I = 0, 5 = the 6 main hues  -------
	;-----  I = 0  ----------
	W = WHERE(I EQ 0, count)
	if count gt 0 then begin
	  R(W) = V(W)
	  G(W) = T(W)
	  B(W) = P(W)
	endif
 
	;-----  I = 1  ----------
	W = WHERE(I EQ 1, count)
	if count gt 0 then begin
	  R(W) = Q(W)
	  G(W) = V(W)
	  B(W) = P(W)
	endif
 
	;-----  I = 2  ----------
	W = WHERE(I EQ 2, count)
	if count gt 0 then begin
	  R(W) = P(W)
	  G(W) = V(W)
	  B(W) = T(W)
	endif
 
	;-----  I = 3  ----------
	W = WHERE(I EQ 3, count)
	if count gt 0 then begin
	  R(W) = P(W)
	  G(W) = Q(W)
	  B(W) = V(W)
	endif
 
	;-----  I = 4  ----------
	W = WHERE(I EQ 4, count)
	if count gt 0 then begin
	  R(W) = T(W)
	  G(W) = P(W)
	  B(W) = V(W)
	endif
 
	;-----  I = 5  ----------
	W = WHERE(I EQ 5, count)
	if count gt 0 then begin
	  R(W) = V(W)
	  G(W) = P(W)
	  B(W) = Q(W)
	endif
 
	if flag eq 0 then begin
	  r = r(0)
	  g = g(0)
	  b = b(0)
	endif
 
	RETURN
	END

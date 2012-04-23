;+
; NAME:
;       RGB2HSV
; PURPOSE:
;       Convert Red, Green, Blue fractions to Hue, Saturation, and Value.
; CATEGORY:
; CALLING SEQUENCE:
;       rgb2hsv,  r, g, b, h, s, v
; INPUTS:
;       r =   red fraction in [0,1].			in. 
;       g = green fraction in [0,1].			in. 
;       b =  blue fraction in [0,1].			in. 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       h = Hue in [0, 360) deg.			out. 
;           0 = red,   60 = yellow, 120 = green 
;         180 = cyan, 240 = blue,   300 = magenta. 
;       s = saturation (grayness) in [0,1].		out. 
;       v = value (brightness) in [0,1].		out. 
; COMMON BLOCKS:
; NOTES:
;       Note: Works for scalars or arrays. 
; MODIFICATION HISTORY:
;       R. Sterner. 20 May, 1988.
;	R. Sterner 27 Dec, 1989 --- converted to SUN.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO RGB2HSV, R0, G0, B0, H, S, V, help=hlp
 
	NP = N_PARAMS(0)
	IF (NP LT 6) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert Red, Green, Blue fract. to Hue, Saturation, & Value.'
	  PRINT,' rgb2hsv,  r, g, b, h, s, v'
	  PRINT,'  r =   red fraction in [0,1].			in.'
	  PRINT,'  g = green fraction in [0,1].			in.'
	  PRINT,'  b =  blue fraction in [0,1].			in.'
	  PRINT,'  h = Hue in [0, 360) deg.			out.'
	  PRINT,'      0 = red,   60 = yellow, 120 = green'
	  PRINT,'    180 = cyan, 240 = blue,   300 = magenta.'
	  PRINT,'  s = saturation (grayness) in [0,1].		out.'
	  PRINT,'  v = value (brightness) in [0,1].		out.'
	  PRINT,' Note: Works for scalars or arrays.'
	  RETURN
	ENDIF
 
	flag = isarray(r0)	; Scalars or arrays?
 
	R = ARRAY(R0)		; Force inputs to be arrays.
	G = ARRAY(G0)
	B = ARRAY(B0)
 
	IF N_ELEMENTS(R) NE N_ELEMENTS(G) THEN BEGIN
	  PRINT,' Error in rgb2hsv:'
	  PRINT,' R, G, B must have same number of elements.'
	  RETURN
	ENDIF
 
	IF N_ELEMENTS(G) NE N_ELEMENTS(B) THEN BEGIN
	  PRINT,' Error in rgb2hsv:'
	  PRINT,' R, G, B must have same number of elements.'
	  RETURN
	ENDIF
 
	IF (MIN(R) LT 0) OR (MAX(R) GT 1) THEN BEGIN
	  PRINT,' Error in rgb2hsv:'
	  PRINT,' Values for Red must be in the range [0, 1].'
	  PRINT,' Min, Max = ', MIN(R), MAX(R)
	  RETURN
	ENDIF
 
	IF (MIN(G) LT 0) OR (MAX(G) GT 1) THEN BEGIN
	  PRINT,' Error in rgb2hsv:'
	  PRINT,' Values for Green must be in the range [0, 1].'
	  PRINT,' Min, Max = ', MIN(G), MAX(G)
	  RETURN
	ENDIF
 
	IF (MIN(B) LT 0) OR (MAX(B) GT 1) THEN BEGIN
	  PRINT,' Error in rgb2hsv:'
	  PRINT,' Values for Blue must be in the range [0, 1].'
	  PRINT,' Min, Max = ', MIN(B), MAX(B)
	  RETURN
	ENDIF
 
	;----------  Get bounding values  -------
	MX = R>G>B
	MN = R<G<B
	D = MX - MN
 
	;----------  Value  ----------------
	V = MX
 
	;----------  Saturation  -----------
	Z = FLTARR(N_ELEMENTS(V))
	S = Z
	W = WHERE(MX NE 0.0, count)
	if count gt 0 then S(W) = D(W)/MX(W)
 
	;---------  Hue  -------------------
	H = Z
	RC = Z
	GC = Z
	BC = Z
	W = WHERE(D NE 0.0, count)
	if count gt 0 then begin
	  RC(W) = (MX(W) - R(W))/D(W)	; Distance of color from red.
	  GC(W) = (MX(W) - G(W))/D(W)	; Distance of color from green.
	  BC(W) = (MX(W) - B(W))/D(W)	; Distance of color from blue.
	endif
	W = WHERE(R EQ MX, count)	; Between yellow and magenta.
	if count gt 0 then H(W) = BC(W) - GC(W)
	W = WHERE(G EQ MX, count)	; Between cyan and yellow.
	if count gt 0 then H(W) = 2.0 + RC(W) - BC(W)
	W = WHERE(B EQ MX, count)	; Between magenta and cyan.
	if count gt 0 then H(W) = 4.0 + GC(W) - RC(W)
	H = H*60.0			; Convert to degrees.
	W = WHERE(H LT 0.0, count)	; Make non-negative.
	if count gt 0 then H(W) = H(W) + 360.0
 
	if flag eq 0 then begin		; Convert back to scalars.
	  h = h(0)
	  s = s(0)
	  v = v(0)
	endif
 
	RETURN
	END

;+
; NAME:
;       SUN_SHADE
; PURPOSE:
;       Make a colored shaded relief view of a surface array. See shade_colors.
; CATEGORY:
; CALLING SEQUENCE:
;       relief = sun_shade(surf, [smin, smax, azi, alt])
; INPUTS:
;       surf = Surface array.                          in
;       smin = Optional min value to use for scaling.  in
;       smax = Optional max value to use for scaling.  in
;         If not specified the array min and max are used.
;         These are useful to insure that different data
;         arrays are scaled the same.
;       azi = Optional sun azimuth (def = 135).        in
;       alt = Optional sun altitude (def = 60).        in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       relief = Shaded relief image.                  out
; COMMON BLOCKS:
; NOTES:
;       Note: Use shade_colors to get proper color table. 
; MODIFICATION HISTORY:
;       J. Culbertson, 15 Feb, 1989.
;       Re-entered by RES.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 31 Aug, 1989 --- converted to SUN.
;-
 
	FUNCTION SUN_SHADE, D, EMIN, EMAX, AZI, ALT, help=hlp
 
	NP = N_PARAMS(0)
	IF (NP lt 1) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Make a colored shaded relief view of a surface array. See shade_colors.'
	  PRINT,' relief = sun_shade(surf, [smin, smax, azi, alt])
	  PRINT,'   surf = Surface array.                          in
	  PRINT,'   smin = Optional min value to use for scaling.  in
	  PRINT,'   smax = Optional max value to use for scaling.  in
	  PRINT,'     If not specified the array min and max are used.
	  PRINT,'     These are useful to insure that different data
	  PRINT,'     arrays are scaled the same.
	  PRINT,'   azi = Optional sun azimuth (def = 135).        in
	  PRINT,'   alt = Optional sun altitude (def = 60).        in
	  PRINT,'   relief = Shaded relief image.                  out
	  print,' Note: Use shade_colors to get proper color table.'
	  RETURN, -1
	ENDIF
 
	IF NP LT 5 THEN ALT = 60
	IF NP LT 4 THEN AZI = 135
	IF NP LT 3 THEN EMAX = MAX(D)
	IF NP LT 2 THEN EMIN = MIN(D)
 
	II = (16.0/(EMAX-EMIN))*(D-EMIN)
	II = FIX(II)<15>0
 
	S = DOT(D, AZI, ALT)
	SMIN = MIN(S)
	SMAX = MAX(S)
 
	JJ = (16.0/(SMAX-SMIN))*(S-SMIN)
	JJ = FIX(JJ)<15>0
 
	R = BYTE(16*II + JJ)
	w = array(where(d eq 0))
	if w(0) ne -1 then R(W) = 1
 
	RETURN, R
	END

;+
; NAME:
;       POLY_FIT2
; PURPOSE:
;       Returns fitted Y values for each given X value.
; CATEGORY:
; CALLING SEQUENCE:
;       yfit = poly_fit2(x, y, ndeg)
; INPUTS:
;       x, y = curve points to fit.		in. 
;       ndeg = degree of polynomial to fit.	in. 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       yfit = fitted Y values for each X.	out. 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 13 Oct, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION POLY_FIT2, X, Y, NDEG, help=hlp
 
	IF (N_PARAMS(0) NE 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Returns fitted Y values for each given X value.'
	  PRINT,' yfit = poly_fit2(x, y, ndeg)'
	  PRINT,'   x, y = curve points to fit.		in.'
	  PRINT,'   ndeg = degree of polynomial to fit.	in.'
	  PRINT,'   yfit = fitted Y values for each X.	out.'
	  RETURN, -1
	ENDIF
 
	RETURN, GEN_FIT(X, [0,0,0,NDEG,TRANSPOSE(POLY_FIT(X,Y,NDEG))])
 
	END

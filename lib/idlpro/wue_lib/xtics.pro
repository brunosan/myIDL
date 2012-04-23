;+
; NAME:
;       XTICS
; PURPOSE:
;       Draw labeled tics for an X type axis.
; CATEGORY:
; CALLING SEQUENCE:
;       XTICS, X1, X2, DX, Y1, Y2, [YL, LB, SZ]
; INPUTS:
;       X1, X2, DX = tic mark start X, end X, step.    in 
;       Y1, Y2 = start and end Y of tic marks.         in 
;       YL = label Y (def = 0 means no labels).        in 
;       LB = string array of labels (def = none).      in 
;       SZ = Text size (def = 1).                      in 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 12 Sep, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;-
 
	PRO XTICS, X1, X2, DX, Y1, Y2, YL, LB0, SZ, help=hlp
 
 	NP = N_PARAMS(0)
	IF (NP LT 5) or keyword_set(hlp) THEN BEGIN
	  print,' Draw labeled tics for an X type axis.'
	  PRINT,' XTICS, X1, X2, DX, Y1, Y2, [YL, LB, SZ]
	  PRINT,'   X1, X2, DX = tic mark start X, end X, step.    in'
	  PRINT,'   Y1, Y2 = start and end Y of tic marks.         in'
	  PRINT,'   YL = label Y (def = 0 means no labels).        in'
	  PRINT,'   LB = string array of labels (def = none).      in'
	  PRINT,'   SZ = Text size (def = 1).                      in'
	  RETURN
	ENDIF
 
	IF NP LT 6 THEN YL = 0.
	IF NP LT 7 THEN LB0 = ''
	IF NP LT 8 THEN SZ = 1.
 
	LB = ARRAY(LB0)					; Force to be array.
	
	NLB = N_ELEMENTS(LB)-1				; Array size.
 
	I = 0
 
	N = FIX(.5+(X2-X1)/DX)				; Changed FOR loop to
	X = X1						; avoid roundoff error.
 
	FOR J = 0, N DO BEGIN   			; loop thru X.
	  PLOTS, [X, X], [Y1, Y2]
	  IF YL GT 0.0 THEN BEGIN			; Text.
	    T = STRTRIM(LB(I<NLB),2) & I = I + 1	; Pull text string.
	    XYOUTS, X, YL, T, align=.5, size=SZ
	  ENDIF
	  X = X + DX
	ENDFOR
 
	RETURN
 
	END

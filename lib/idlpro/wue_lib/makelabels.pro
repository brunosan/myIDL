;+
; Name: MAKELABELS.PRO
; Purpose: Make a label array.
; Category: For PLT.
; Calling sequence: LBL = MAKELABELS(VALUE_ARRAY, NDEC)
; Inputs:
;   VALUE_ARRAY = Array of values.
;   NDEC = Number of decimal places to use.
; Optional input parameters:
; Outputs:
;   LBL = String array of labels.
; Optional output parameters:
; Common blocks:
; Side effects:
; Restrictions:
; Routines used:
; Procedure:
; Modification history: R. Sterner. 7 Nov, 1988.
;	R. Sterner, 26 Feb, 1991 --- Renamed from make_labels.pro
;	Johns Hopkins University Applied Physics Laboratory.
;-

	FUNCTION MAKELABELS, V, ND,help=h

	if keyword_set(h) then begin
	  print,' Make a label array.'
	  print,' lbl = makelabels(value_array, ndec)'
	  print,'   value_array = Array of values.		in'
	  print,'   ndec = Number of decimal places to use.	in'
	  print,'   lbl = String array of labels.		out'
	  return,-1
	endif


	N = N_ELEMENTS(V)

	MX = 0
	FF = '(F20.' + STRTRIM(ND,2) + ')'
	IF ND GT 0 THEN BEGIN
	  FOR I = 0, N-1 DO BEGIN
	    MX = MX > STRLEN( STRTRIM( STRING(V(I), FF),2))
	  ENDFOR
	ENDIF ELSE BEGIN
	  FOR I = 0, N-1 DO BEGIN
	    MX = MX > STRLEN( STRTRIM( FIX(V(I)),2))
	  ENDFOR
	ENDELSE

	S = STRARR(MX, N)
	IF ND GT 0 THEN FF = '(F' + STRTRIM(MX,2) + '.' + STRTRIM(ND,2) + ')'
	IF ND EQ 0 THEN FI = '(I' + STRTRIM(MX,2) + ')'

	FOR I = 0, N-1 DO BEGIN
	  IF ND GT 0 THEN S(I) = STRING(V(I), FF)
	  IF ND EQ 0 THEN S(I) = STRING(FIX(V(I)), FI)
	ENDFOR

	RETURN, S
	END

;+
; NAME:
;       ARRAY
; PURPOSE:
;       Force given argument to be an array.
; CATEGORY:
; CALLING SEQUENCE:
;       y = array(x)
; INPUTS:
;       x = input which may be an array or scalar.      in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y = out which is an array.                      out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, JHU-APL,  28 Jan, 1986.
;       Converted to SUN 14 Aug, 1989 --- R. Sterner.
;-
 
	FUNCTION ARRAY, X, help = h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Force given argument to be an array.'
	  print,' y = array(x)'
	  print,'   x = input which may be an array or scalar.      in'
	  print,'   y = out which is an array.                      out'
	  return, -1
	endif
 
	if n_elements(x) eq 0 then begin
	  print,' Error in ARRAY: argument undefined.'
	  stop, ' Stopping in ARRAY.'
	  return, -1
	endif
	S = SIZE(X)
	IF S(0) GT 0 THEN RETURN, X	; already an array.
	N = S(S(0)+2)			; number of elements.
	TYP = DATATYPE(X)
 
	CASE TYP OF
  'STR': BEGIN
	   Y = STRARR(1)
	   Y(0) = X
	 END
  'BYT': Y = BYTARR(N) + X
  'INT': Y = INTARR(N) + X
  'LON': Y = LONARR(N) + X
  'FLO': Y = FLTARR(N) + X
  'DOU': Y = DBLARR(N) + X
  'COM': Y = COMPLEXARR(N) + X
   ELSE: RETURN, X
	ENDCASE
 
	RETURN, Y
	END

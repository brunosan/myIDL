;+
; NAME:
;       SIGN
; PURPOSE:
;       Return the mathematical sign of the argument.
; CATEGORY:
; CALLING SEQUENCE:
;       s = sign(x)
; INPUTS:
;       x = value of array of values.     in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = sign of value(s).             out 
; COMMON BLOCKS:
; NOTES:
;       Note: 
;         s = -1 for x < 0 
;         s =  0 for x = 0 
;         s =  1 for x > 0 
; MODIFICATION HISTORY:
;       R. Sterner, 7 May, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;-
 
	FUNCTION SIGN_WUE, X0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return the mathematical sign of the argument.'
	  print,' s = sign(x)'
	  print,'   x = value of array of values.     in'
	  print,'   s = sign of value(s).             out'
	  print,' Note:'
	  print,'   s = -1 for x < 0'
	  print,'   s =  0 for x = 0'
	  print,'   s =  1 for x > 0'
	  return, -1
	endif
 
	FLAG = ISARRAY(X0)		; If X is an array FLAG = 1, else 0.
	X = ARRAY(X0)			; Force X to be an array.
	S = FIX(X*0)			; Set up a sign array.
 
	W = array(WHERE(X LT 0))	; Set sign to -1 if X < 0.
	if w(0) ne -1 then S(W) = -1
 
	W = array(WHERE(X EQ 0))	; Set sign to 0 if X = 0.
	if w(0) ne -1 then S(W) = 0
 
	W = array(WHERE(X GT 0))	; Set sign to +1 if X > 0.
	if w(0) ne -1 then S(W) = 1
 
	IF FLAG EQ 0 THEN RETURN, S(0)	; Return a scalar if X was a scalar.
	IF FLAG EQ 1 THEN RETURN, S	; else return an array.
	END

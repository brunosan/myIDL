;+
; Name: NUM_DEC.PRO
; Purpose: Number of decimal places in given number.
; Category:
; Calling sequence: ND = NUM_DEC(VAL)
; Inputs: VAL = number to examine.
; Optional input parameters:
; Outputs: ND = number of decimal places in VAL.
; Optional output parameters:
; Common blocks: 
; Side effects:
; Restrictions:
; Routines used:
; Procedure:
; Modification history: R. Sterner. 15 Nov, 1988.
;	Johns Hopkins University Applied Physics Laboratory.
;-

	FUNCTION NUM_DEC, VAL,help=h
	
	if keyword_set(h) then begin
	  print,'Number of decimal places in given number.'
	  print,'ND = NUM_DEC(VAL)'
	  print,' VAL = number to examine.		in'
	  print,' ND = number of decimal places in VAL. out'
	  return,-1
	endif

	T = STRTRM2(VAL,2,'0')
	IF STRPOS(T,'.') EQ -1 THEN BEGIN
	  ND = 0
	ENDIF ELSE BEGIN
	  ND = STRLEN(T)-STRPOS(T,'.')-1
	ENDELSE

	RETURN, ND

	END

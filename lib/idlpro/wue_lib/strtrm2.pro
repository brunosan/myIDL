;+
; Name: STRTRM2.PRO
; Purpose: Trim given character (and spaces) from ends of given string.
; Category: String functions.
; Calling sequence: S2 = STRTRM2(S1,[flag],[chr])
; Inputs: S1 = String to trim.
; Optional input parameters: flag = 0: remove trailing,
;                                   1: remove leading,
;                                   2: remove both. No flag same as 0.
;                            chr = character to trim (def = spaces).
; Outputs: S2 = trimmed string.  Works just like STRTRIM.
; Side effects: Also removes spaces adjacent to trim char.
; Procedure: Uses STRESS to convert chr to spaces and trims with STRTRIM.
; Modification history:  Written by R. Sterner, 11 Jan, 1985.
;	Johns Hopkins University Applied Physics Laboratory.
;-

	FUNCTION STRTRM2,S,FX,CX,help=h  ; string, (0:trail,1:lead,2:both),char


	if (keyword_set(h)) then begin
	  print,'Trim given character (and spaces) from ends of given string.'
	  print,'S2 = STRTRM2(S1,[flag],[chr])'
	  print,'  S1 = String to trim.				in'
	  print,'  flag = 0: remove trailing			in'
	  print,'         1: remove leading'
	  print,'         2: remove both. No flag same as 0.
	  print,'  chr = character to trim (def = spaces).	in'
	  print,'S2 = trimmed string.  Works just like STRTRIM. out'
	  return,-1
	endif

	C = ' '
	F = 0
	IF N_PARAMS(0) EQ 3 THEN C = CX
	IF N_PARAMS(0) GE 2 THEN F = FX

	X = STRING([1B])	     ; set up a place saving character.
	S2 = STRTRIM(S,F)	     ; trim spaces.
	S2 = STRESS(S2,'R',0,' ',X)  ; Put a place holder in left over spaces.
	S2 = STRESS(S2,'R',0,C,' ')  ; Turn trim char into spaces.
	S2 = STRTRIM(S2,F)	     ; Trim off ends.
	S2 = STRESS(S2,'R',0,' ',C)  ; Put back whatever trim chars are left.
	S2 = STRESS(S2,'R',0,X,' ')  ; Put back desired spaces.

	RETURN, S2

	END

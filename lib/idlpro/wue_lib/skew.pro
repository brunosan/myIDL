;+
; NAME:
;       SKEW
; PURPOSE:
;       Returns the skew of an array (3rd moment/2nd moment^3/2).
; CATEGORY:
; CALLING SEQUENCE:
;       s = skew(a)
; INPUTS:
;       a = input array.    in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = skew of a.      out  
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 23 Aug, 1990
;       Johns Hopkins University Applied Physics Lab
;-
 
	FUNCTION SKEW,A, help = h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Returns the skew of an array (3rd moment/2nd moment^3/2).'
	  print,' s = skew(a)' 
	  print,'   a = input array.    in'
	  print,'   s = skew of a.      out' 
	  return, -1
	endif
 
	IF NOT ISARRAY(A) THEN BEGIN
	  PRINT,' Error in SKEW: argument must be an array.'
	  RETURN, -1
	ENDIF
	T = DATATYPE(A)
	IF T EQ 'UND' THEN BEGIN
	  PRINT,' Error in SKEW: Undefined argument.'
	  RETURN, -1
	ENDIF
	IF (T EQ 'STR') OR (T EQ 'COM') THEN BEGIN
	  PRINT,' Error in SKEW: Wrong type argument.'
	  RETURN, -1
	ENDIF
	IF (T EQ 'BYT') OR (T EQ 'INT') OR (T EQ 'LON') THEN BEGIN
	  TMP = FLOAT(A)
	ENDIF
	IF (T EQ 'FLO') OR (T EQ 'DOU') THEN BEGIN
	  TMP = A
	ENDIF
 
	MU = MEAN(TMP)
	TMP = TMP - MU		; dont lose precision.
	sd = sdev(tmp)
	if sd eq 0. then return, 0.
	S = MEAN(TMP^3)/sd^3
	RETURN,S
 
	END

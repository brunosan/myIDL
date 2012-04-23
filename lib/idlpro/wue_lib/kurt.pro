;+
; NAME:
;       KURT
; PURPOSE:
;       Returns the kurtosis of an array (4th moment/2nd moment^2).
; CATEGORY:
; CALLING SEQUENCE:
;       k = kurt(a)
; INPUTS:
;       a = input array.    in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       k = kurtosis of a.  out  
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;-
 
	FUNCTION KURT,A, help = h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Returns the kurtosis of an array (4th moment/2nd moment^2).'
	  print,' k = kurt(a)' 
	  print,'   a = input array.    in'
	  print,'   k = kurtosis of a.  out' 
	  return, -1
	endif
 
	IF NOT ISARRAY(A) THEN BEGIN
	  PRINT,' Error in KURT: argument must be an array.'
	  RETURN, -1
	ENDIF
	T = DATATYPE(A)
	IF T EQ 'UND' THEN BEGIN
	  PRINT,' Error in KURT: Undefined argument.'
	  RETURN, -1
	ENDIF
	IF (T EQ 'STR') OR (T EQ 'COM') THEN BEGIN
	  PRINT,' Error in KURT: Wrong type argument.'
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
	S = MEAN(TMP^4)/sd^4
	RETURN,S
 
	END

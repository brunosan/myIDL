;+
; NAME:
;       SDEV
; PURPOSE:
;       Returns standard deviation of an array.
; CATEGORY:
; CALLING SEQUENCE:
;       s = sdev(a)
; INPUTS:
;       a = input array.               in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = standard deviation of a.   out  
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by K. Kostoff, 1/16/85
;       Johns Hopkins University Applied Physics Laboratory.
;       Modified by B. Gotwols, R. Sterner --- 1 Oct, 1986.
;-
 
	FUNCTION SDEV,A, help = h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Returns standard deviation of an array.'
	  print,' s = sdev(a)' 
	  print,'   a = input array.               in'
	  print,'   s = standard deviation of a.   out' 
	  return, -1
	endif
 
	IF NOT ISARRAY(A) THEN BEGIN
	  PRINT,'Error in SDEV: argument must be an array.'
	  RETURN, -1
	ENDIF
	T = DATATYPE(A)
	IF T EQ 'UND' THEN BEGIN
	  PRINT,'Error in SDEV: Undefined argument.'
	  RETURN, -1
	ENDIF
	IF (T EQ 'STR') OR (T EQ 'COM') THEN BEGIN
	  PRINT,'Error in SDEV: Wrong type argument.'
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
	SD = SQRT( MEAN(TMP^2))
	RETURN,SD
 
	END

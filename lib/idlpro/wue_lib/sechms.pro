;+
; NAME:
;       SECHMS
; PURPOSE:
;       Seconds after midnight to h, m, s, numbers and strings.
; CATEGORY:
; CALLING SEQUENCE:
;       SECHMS, SEC, H, [M, S, SH, SM, SS]
; INPUTS:
;       SEC = seconds after midnight.           in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       H, M, S = Hrs, Min, Sec as numbers.     out
;       SH, SM, SS = Hrs, Min, Sec as strings   out
;             (with leading 0s where needed).
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 17 Nov, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO SECHMS, SEC, H, M, S, SH, SM, SS, help=hlp
 
	IF (keyword_set(hlp)) or (N_PARAMS(0) LT 2) THEN BEGIN
	  PRINT,' Seconds after midnight to h, m, s, numbers and strings.'
	  PRINT,' SECHMS, SEC, H, [M, S, SH, SM, SS]
	  PRINT,'   SEC = seconds after midnight.            in
	  PRINT,'   H, M, S = Hrs, Min, Sec as numbers.      out
	  PRINT,'   SH, SM, SS = Hrs, Min, Sec as strings    out
	  PRINT,'         (with leading 0s where needed).
	  RETURN
	ENDIF
 
	T = SEC
	H = LONG(T/3600)
	T = T - 3600*H
	M = LONG(T/60)
	T = T - 60*M
	S = T
 
	SH = STRTRIM(STRING(H),2)
	IF H LT 10 THEN SH = '0'+SH
	SM = STRTRIM(STRING(M),2)
	IF M LT 10 THEN SM = '0'+SM
	SS = STRTRIM(STRING(S),2)
	IF S LT 10 THEN SS = '0'+SS
 
	RETURN
 
	END

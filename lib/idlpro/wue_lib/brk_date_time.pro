;+
; NAME:
;       BRK_DATE_TIME
; PURPOSE:
;       Break a date and time string into separate date and time.
; CATEGORY:
; CALLING SEQUENCE:
;       brk_date_time, txt, date, time
; INPUTS:
;       txt = Input date and time string.               in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       date = returned date string, null if no date.   out 
;       time = returned time string, null if no time.   out 
; COMMON BLOCKS:
; NOTES:
;       Note: works for systime: brk_date_time, systime(), dt, tm 
; MODIFICATION HISTORY:
;       R. Sterner. 21 Nov, 1988.
;       RES 18 Sep, 1989 --- converted to SUN.
;-
 
	PRO BRK_DATE_TIME, TXT, DT, TM, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Break a date and time string into separate date and time.'
	  PRINT,' brk_date_time, txt, date, time
	  PRINT,'   txt = Input date and time string.               in'
	  PRINT,'   date = returned date string, null if no date.   out'
	  PRINT,'   time = returned time string, null if no time.   out'
	  print,' Note: works for systime: brk_date_time, systime(), dt, tm'
	  RETURN
	ENDIF
 
	DT = ''
	TM = ''
 
	TXT = STRUPCASE(TXT)
	IF TXT EQ 'NOW' THEN TXT = systime()
	IF TXT EQ '' THEN RETURN
	FOR I = 0, NWRDS(TXT)-1 DO BEGIN
	  TM = GETWRD(TXT, I)
	  IF STRPOS(TM,':') GT -1 THEN BEGIN
	    DT = STRTRIM(STRESS(TXT, 'D', 1, TM),2)
	    RETURN
	  ENDIF
	ENDFOR
 
	TM = ''
	DT = STRTRIM(TXT,2)
	RETURN
 
	END

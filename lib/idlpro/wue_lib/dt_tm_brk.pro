;+
; NAME:
;       DT_TM_BRK
; PURPOSE:
;       Break a date and time string into separate date and time.
; CATEGORY:
; CALLING SEQUENCE:
;       dt_tm_brk, txt, date, time
; INPUTS:
;       txt = Input date and time string.               in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       date = returned date string, null if no date.   out 
;       time = returned time string, null if no time.   out 
; COMMON BLOCKS:
; NOTES:
;       Note: works for systime: dt_tm_brk, systime(), dt, tm 
; MODIFICATION HISTORY:
;       R. Sterner. 21 Nov, 1988.
;       RES 18 Sep, 1989 --- converted to SUN.
;	R. Sterner, 26 Feb, 1991 --- renamed from brk_date_time.pro
;	R. Sterner, 26 Feb, 1991 --- renamed from brk_dt_tm.pro
;-
 
	PRO DT_TM_BRK, TXT, DT, TM, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Break a date and time string into separate date and time.'
	  PRINT,' dt_tm_brk, txt, date, time
	  PRINT,'   txt = Input date and time string.               in'
	  PRINT,'   date = returned date string, null if no date.   out'
	  PRINT,'   time = returned time string, null if no time.   out'
	  print,' Note: works for systime: dt_tm_brk, systime(), dt, tm'
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

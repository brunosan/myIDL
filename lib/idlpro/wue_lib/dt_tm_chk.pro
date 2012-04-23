;+
; Name: DT_TM_CHK.PRO
; Purpose: Check date & time string that both parts exist
;    & are valid.
; Category: Time, Calendar.
; Calling sequence: STATUS = DT_TM_CHK(TXT)
; Inputs: TXT = Input data and time string.
; Outputs: STATUS = 1 if ok (true), 0 if error (false).
; Optional output parameters:
; Common blocks:
; Side effects:
; Restrictions:
; Routines used: BRK_DATE_TIME.
; Procedure:
; Modification history:
;	R. Sterner. 13 Apr, 1989.
;	R. Sterner, 26 Feb, 1991 --- renamed from chk_date_time.pro
;	R. Sterner, 27 Feb, 1991 --- renamed from chk_dt_tm.pro
;-

	FUNCTION DT_TM_CHK, TXT, help=h

	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Check date & time string that both parts exist & are valid.'
	  print,' status = dt_tm_chk(txt)'
	  print,'   txt = Input data and time string.             in'
	  print,'   status = 1 if ok (true), 0 if error (false).  out'
 	  return,-1
	endif

	DT_TM_BRK, TXT, DT, TM	; Separate date and time.
	IF DT EQ '' THEN RETURN, 0	; No date, error.
	IF TM EQ '' THEN RETURN, 0	; No time, error.
	DATE2YMD, DT, Y, M, D		; Break date into y,m,d.
	IF Y LT 0 THEN RETURN, 0	; Bad year, error.
	IF M LT 1 THEN RETURN, 0	; bad month, error.
	IF M GT 12 THEN RETURN, 0	; bad month, error.
	IF D LT 1 THEN RETURN, 0	; bad monthday, error.
	MDAYS = MONTHDAYS(Y,0)		; Allowed monthdays.
	IF D GT MDAYS(M) THEN RETURN, 0	; bad monthday, error.
	
	RETURN, 1			; ok.

	END

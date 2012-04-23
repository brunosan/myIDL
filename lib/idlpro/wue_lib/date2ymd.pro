;+
; NAME:
;       DATE2YMD
; PURPOSE:
;       Date text string to the numbers year, month, day.
; CATEGORY:
; CALLING SEQUENCE:
;       date2ymd,date,y,m,d
; INPUTS:
;       date = date string.		in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       y = year number.		out 
;       m = month number.		out 
;       d = day number.		out 
; COMMON BLOCKS:
; NOTES:
;       Notes: The format of the date is flexible except that the month
;         must be month name. 
;         Dashes, commas, periods, or slashes are allowed.
;         Some examples: 23 sep, 1985        sep 23 1985      1985 Sep 23
;         23/SEP/85   23-SEP-1985   85-SEP-23   23 September, 1985.
;         Doesn't check if month day is valid. Doesn't 
;         change year number (like 86 does not change to 1986).
;         Dates may have only 2 numeric values, year and day. 
;         If both year and day values are < 31 then day is assumed first. 
;         systime() can be handled directly: date2ymd,systime(),y,m,d
;         For invalid dates y, m and d are all set to -1. 
; MODIFICATION HISTORY:
;       Written by R. Sterner, 29 Oct, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       25-Nov-1986 --- changed to REPCHR.
;       RES 18 Sep, 1989 --- converted to SUN.
;-
 
	PRO DATE2YMD,DATE,Y,M,D, help=hlp
 
	IF (N_PARAMS(0) LT 4) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Date text string to the numbers year, month, day.'
	  PRINT,' date2ymd,date,y,m,d
	  PRINT,'   date = date string.		in'
	  PRINT,'   y = year number.		out'
	  PRINT,'   m = month number.		out'
	  PRINT,'   d = day number.		out'
	PRINT,' Notes: The format of the date is flexible except that the'
	  PRINT,'   month must be month name.'
	  PRINT,'   Dashes, commas, periods, or slashes are allowed.
	  PRINT,'   Some examples: 23 sep, 1985     sep 23 1985   1985 Sep 23'
	  PRINT,'   23/SEP/85   23-SEP-1985   85-SEP-23   23 September, 1985.'
	  PRINT,"   Doesn't check if month day is valid. Doesn't"
	  PRINT,'   change year number (like 86 does not change to 1986).'
	  print,'   Dates may have only 2 numeric values, year and day. If'
	  print,'   both year & day values are < 31 then day is assumed first.'
	  PRINT,'   systime() can be handled: date2ymd,systime(),y,m,d
	  print,'   For invalid dates y, m and d are all set to -1.'
	  RETURN
	ENDIF
 
	;----  Get just date part of string  -----
	dt_tm_brk, date, dt, tmp
 
	;----  Edit out punctuation  -------
	DT = REPCHR(DT,'-')  	; from DT replace all - by space.
	DT = REPCHR(DT,'/')    	; from DT replace all / by space.
	DT = REPCHR(DT,',')	; from DT replace all , by space.
	DT = REPCHR(DT,'.')	; from DT replace all . by space.
 
	;----  Want 1 monthname and 2 numbers. Start counts at 0.  -----------
	nmn = 0			; Number of month names found is 0.
	nnm = 0			; Number of numbers found is 0.
	nums = [0]		; Start numbers array.
 
	;----  Loop through words in text string  -------------
	for iw = 0, nwrds(dt)-1 do begin
	  wd = strupcase(getwrd(dt,iw))	; Get word as upper case.
	  ;---- check if month name  -------
	  txt = strmid(wd,0,3)		; Check only first 3 letters.
	  I = STRPOS('JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC',txt)  ; find month.
	  if i ge 0 then begin		; Found month name.
	    M = 1 + I/3			; month number.
	    nmn = nmn + 1		; Count month name.
	    goto, skip			; Skip over number test.
	  endif
	  ;----  Check for a number  -------
	  if isnumber(wd) then begin
	    nnm = nnm + 1		; Count number.
	    nums = [nums,wd+0]		; Store it.
	  endif
skip:
	endfor
 
	;----  Test for only 1 month name  -------
	if nmn ne 1 then begin		; Must be exactly 1 month name.
	  y = -1
	  m = -1
	  d = -1
	  return
	endif
 
	;----  Look for y and m -----
	if nnm ne 2 then begin		; Must be exactly 2 numeric items.
	  y = -1
	  m = -1
	  d = -1
	  return
	endif
	nums = nums(1:*)		; Trim off leading 0.
	if max(nums) gt 31 then begin	; Assume a number > 31 is the year.
	  y = max(nums)
	  d = min(nums)
	  return
	endif
	if min(nums) eq 0 then begin	; Allow a year of 0 (but not a day).
	  y = min(nums)
	  d = max(nums)
	  return
	endif				; Both < 31, assume day was first.
	d = nums(0)
	y = nums(1)
	return
 
	END

;+
; NAME:
;       DT_TM_MAK
; PURPOSE:
;       Set up a time and date string from reference JD and offset.
; CATEGORY:
; CALLING SEQUENCE:
;       s = dt_tm_mak(jd0, [sec])
; INPUTS:
;       jd0 = Julian Date of a reference date (0:00 hr).  in
;       sec = Seconds since JD0 at 0:00.                  in
; KEYWORD PARAMETERS:
;       Keywords:
;         FORMAT = format string.  Allows output date to be customized.
;         The default format string is 'y$ n$ d$ h$:m$:s$'
;            The following substitutions take place in the format string:
;         Y$ = 4 digit year.
;         y$ = 2 digit year.
;         N$ = full month name.
;         n$ = 3 letter month name.
;         d$ = day of month number.
;         W$ = full weekday name.
;         w$ = 3 letter week day name.
;	  h$ = hour.
;	  m$ = minute.
;	  s$ = second.
;         @  = Carriage Return.
;         !  = Line feed.
; OUTPUTS:
;       S = resulting string.                             out
; COMMON BLOCKS:
; NOTES:
;       Notes: Some examples: 'h$:m$:s$' -> 09:12:04,
;         'd$ n$ Y$' -> 12 Jan 1991, 'd$D h$h' -> 3D 2h, ...
; MODIFICATION HISTORY:
;       R. Sterner.  17 Nov, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES  20 Apr, 1989 --- 2 digit year.
;       R. Sterner, 26 Feb, 1991 --- Renamed from time_date_str.pro
;       R. Sterner, 27 Feb, 1991 --- Renamed from tm_dt_str.pro
;       R. Sterner, 28 Feb, 1991 --- changed format.
;-
 
	FUNCTION DT_TM_MAK, JD0, SEC, format=FRMT, help=h
 
	IF (N_PARAMS(0) LT 1) or (keyword_set(h)) THEN BEGIN
	  PRINT,' Set up a time and date string from reference JD and offset.
	  PRINT,' s = dt_tm_mak(jd0, [sec])
	  PRINT,'   jd0 = Julian Date of a reference date (0:00 hr).  in'
	  PRINT,'   sec = Seconds since JD0 at 0:00.                  in'
	  PRINT,'   S = resulting string.                             out'
          print,' Keywords:'
          print,'   FORMAT = format string.  Allows output date to be '+$
            'customized.'
          print,"   The default format string is 'y$ n$ d$ h$:m$:s$'"
          print,'      The following substitutions take place in the '+$
            'format string:'
          print,'   Y$ = 4 digit year.'
          print,'   y$ = 2 digit year.'
          print,'   N$ = full month name.'
          print,'   n$ = 3 letter month name.'
          print,'   d$ = day of month number.'
          print,'   W$ = full weekday name.'
          print,'   w$ = 3 letter week day name.'
	  print,'   h$ = hour.'
	  print,'   m$ = minute.'
	  print,'   s$ = second.'
	  PRINT,'   @  = Carriage Return.'
	  PRINT,'   !  = Line feed.'
	  print," Notes: Some examples: 'h$:m$:s$' -> 09:12:04,"
	  print,"   'd$ n$ Y$' -> 12 Jan 1991, 'd$D h$h' -> 3D 2h, ..."
	  RETURN, -1
	ENDIF
 
	if n_params(0) lt 2 then sec = 0.	; Default seconds are 0.
 
        ;-----  format string  ------
        fmt = 'y$ n$ d$ h$:m$:s$'		; Default format.
        if keyword_set(frmt) then fmt = frmt	; Use given format.
 
        ;-----  Get all the allowed parts  -----
	days = sec/86400d0			; Seconds to days
	rem = long(sec) mod 86400		;   and left over seconds.
	jd2ymd, jd0+long(days), y, m, d		; Find Yr, Mon, Day.
        yu = strtrim(Y,2)			; 4 Digit year.
        yl = strtrim(fix(y-100*fix(y/100)),2)	; 2 digit year.
        mnames = monthnames()			; List of names.
        mu = mnames(m)				; Long month name.
        ml = strmid(mu,0,3)			; 3 letter month name.
        dl = strtrim(d,2)			; Day of month.
        wu = weekday(y,m,d)			; Long weekday name.
        wl = strmid(wu,0,3)			; 3 letter weekday name.
 
	sechms, rem, h, m, s, hh, mm, ss	; Find Hr, Min, Sec.
	ii = strtrim(string(days,format='(f20.2)'),2)
 
	;------  Replacements  -------
	out = fmt
	out = stress(out, 'R', 0, 'I$', ii)	; Time interval in days.
	out = stress(out, 'R', 0, 'Y$', yu)	; 4 digit year.
	out = stress(out, 'R', 0, 'y$', yl)	; 2 digit year.
	out = stress(out, 'R', 0, 'N$', mu)	; Long month name.
	out = stress(out, 'R', 0, 'n$', ml)	; 3 letter month name.
	out = stress(out, 'R', 0, 'W$', wu)	; Long weekday name.
	out = stress(out, 'R', 0, 'w$', wl)	; 3 letter weekday name.
	out = stress(out, 'R', 0, 'd$', dl)	; Day of month.
	out = stress(out, 'R', 0, 'h$', hh)	; Hour.
	out = stress(out, 'R', 0, 'm$', mm)	; Minute.
	out = stress(out, 'R', 0, 's$', ss)	; Second.
	out = repchr(out, '@', string(13B))	; <CR>
	out = repchr(out, '!', string(10B))	; <LF>
 
	RETURN, OUT
	END

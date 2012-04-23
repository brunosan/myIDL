;+
; NAME:
;       DN2DATE
; PURPOSE:
;       Convert year and day of the year to a date string.
; CATEGORY:
; CALLING SEQUENCE:
;       date = dn2date(Year, dn)
; INPUTS:
;       Year = year.                      in 
;       dn = day of the year.             in 
; KEYWORD PARAMETERS:
;       Keywords:  
;         FORMAT = format string.  (see YMD2DATE). 
; OUTPUTS:
;       date = returned date string.      out 
;              (like 86-APR-25).
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,    25 APR, 1986.
;       Johns Hopkins University Applied Physics Laboratory
;-
 
	FUNCTION DN2DATE, YR, DN, help=hlp, format=frmt
 
	IF (N_PARAMS(0) LT 2) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Convert year and day of the year to a date string.'
	  PRINT,' date = dn2date(Year, dn)'
	  PRINT,'   Year = year.                      in'
	  PRINT,'   dn = day of the year.             in'
	  PRINT,'   date = returned date string.      out'
	  PRINT,'          (like 86-APR-25).
	  print,' Keywords:' 
	  print,'   FORMAT = format string.  (see YMD2DATE).'
	  RETURN, -1
	ENDIF
 
	YDN2MD,YR,DN,M,D
	IF M lt 0 THEN BEGIN
	  PRINT,'Error in month in DN2DATE.'
	  M = 0
	ENDIF
	return, ymd2date(yr,m,d,format=frmt)
 
	END

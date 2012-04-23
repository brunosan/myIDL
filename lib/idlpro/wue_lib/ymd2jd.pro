;+
; NAME:
;       YMD2JD
; PURPOSE:
;       From Year, Month, and Day compute Julian Day number.
; CATEGORY:
; CALLING SEQUENCE:
;       jd = ymd2jd(y,m,d)
; INPUTS:
;       y = Year (like 1987).                    in 
;       m = month (like 7 for July).             in 
;       d = month day (like 23).                 in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       jd = Julian Day number (like 2447000).   out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  23 June, 1985 --- converted from FORTRAN.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;-
 
	FUNCTION YMD2JD, IY, IM, ID, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' From Year, Month, and Day compute Julian Day number.'
	  PRINT,' jd = ymd2jd(y,m,d)'
	  PRINT,'   y = Year (like 1987).                    in'
	  PRINT,'   m = month (like 7 for July).             in'
	  PRINT,'   d = month day (like 23).                 in'
	  PRINT,'   jd = Julian Day number (like 2447000).   out'
	  RETURN, -1
	ENDIF
 
	Y = LONG(IY)
	M = LONG(IM)
	D = LONG(ID)
	JD = 367*Y-7*(Y+(M+9)/12)/4-3*((Y+(M-9)/7)/100+1)/4 $
             +275*M/9+D+1721029
 
	RETURN, JD
 
	END

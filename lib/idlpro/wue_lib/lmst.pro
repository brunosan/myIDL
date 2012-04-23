;+
; NAME:
;       LMST
; PURPOSE:
;       Give local mean sidereal time.
; CATEGORY:
; CALLING SEQUENCE:
;       st = lmst( jd, ut, lng)
; INPUTS:
;       jd = Julian Day (starting at noon).         in 
;       ut = Universal time as fraction of day.     in 
;       lng = observer longitude (deg).             in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       st = sidereal time as fraction of day.      out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  16 Sep, 1986.
;       R. Sterner, 15 Jan, 1991 --- converted to V2.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION LMST, JD, UT, LNG, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Give local mean sidereal time.'
	  print,' st = lmst( jd, ut, long)'
	  print,'   jd = Julian Day (starting at noon).         in'
	  print,'   ut = Universal time as fraction of day.     in'
	  print,'   long = observer longitude (deg, East is +). in'
	  print,'   st = sidereal time as fraction of day.      out'
	  return, -1
	endif
 
	SOL2SID = 1.0027379093D0	; solar to sidereal rate.
	T0 = 6D0/24. + 38D0/1440. + 45.836D0/86400.	; 0 pt sidereal time.
 
	DLONG = -LNG/360.D0	; time diff from Greenwich.
	TDAYS = JD - 2415020.5	; days since noon Jan 0, 1986.
	T = T0 + (SOL2SID - 1.0)*TDAYS + SOL2SID*UT - DLONG
	RETURN, T - FLOOR(T)	; only want fraction.
	END

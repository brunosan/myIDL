;+
; NAME:
;       TNAXES
; PURPOSE:
;       Find nice time axis tics.
; CATEGORY:
; CALLING SEQUENCE:
;       tnaxes, xmn, xmx, nx, mjx1, mjx2, xinc, [mnx2, mnx2, xinc2]
; INPUTS:
;       xmn, xmx = Axis min and max in sec.          in
;       nx = Desired number of axis tics.            in
; KEYWORD PARAMETERS:
;       Keywords:
;	  FORM=form  returns a suggested format, suitable
;	    for use in formatting time axis labels.
;	    Ex: h$:m$:s$, h$:m$, d$
; OUTPUTS:
;       mjx1 = first major tic position in sec.      out
;       mjx2 = last major tic position in sec.       out
;       xinc = Suggested major tic spacing in sec.   out
;       mnx1 = first minor tic position in sec.      out
;       mnx2 = last minor tic position in sec.       out
;       xinc2 = suggested minor tic spacing in sec.  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 18 Nov, 1988.
;       R. Sterner, 22 Feb, 1991 --- converted to IDL V2.
;       R. Sterner, 25 Feb, 1991 --- added minor ticks.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO TNAXES, DX0,DX1,NX, mjx1,mjx2,xi, mnx1, mnx2, xi2, $
	  help=hlp, form=form
 
	IF (N_PARAMS(0) LT 6) or (keyword_set(hlp)) THEN BEGIN
	  PRINT,' Find nice time axis tics.'
	  PRINT,' tnaxes, xmn, xmx, nx, mjx1, mjx2, xinc, [mnx2, mnx2, xinc2]
	  PRINT,'   xmn, xmx = Axis min and max in sec.          in'
	  PRINT,'   nx = Desired number of axis tics.            in'
	  PRINT,'   mjx1 = first major tic position in sec.      out'
	  PRINT,'   mjx2 = last major tic position in sec.       out'
	  PRINT,'   xinc = Suggested major tic spacing in sec.   out'
	  PRINT,'   mnx1 = first minor tic position in sec.      out'
	  PRINT,'   mnx2 = last minor tic position in sec.       out'
	  print,'   xinc2 = suggested minor tic spacing in sec.  out'
	  print,' Keywords:'
	  print,'   FORM=form  returns a suggested format, suitable'
	  print,'     for use in formatting time axis labels.'
	  print,'     Ex: h$:m$:s$, h$:m$, d$'
	  RETURN
	ENDIF
 
	DX = DOUBLE(DX1 - DX0)	; Axis range.
 
	IF DX GT 0 THEN BEGIN	;Forward axis.
	  X0 = DOUBLE(DX0)
	  X1 = DOUBLE(DX1)
	ENDIF ELSE BEGIN	; Reverse axis.
	  X0 = DOUBLE(DX1)
	  X1 = DOUBLE(DX0)
	ENDELSE
 
	XINC = (X1-X0)/NX	; Approx. inc size.
 
	;------------  Less than 1 sec (error)  -------------------
	IF XINC LT 1. THEN BEGIN	; < 1 sec.
	  PRINT,'Error in TNAXES: Time axis tic spacings<1 sec not recommended'
	  STOP
	ENDIF
	;------------  1 sec to 1 min  -----------------
	IF XINC LT 60. THEN BEGIN	; XINC in sec < 1 min.
	  XI = 60.
	  xi2 = 15.
	  IF XINC LT 42.4 THEN begin XI = 30. & xi2 = 10. & endif
	  IF XINC LT 21.2 THEN begin XI = 15. & xi2 = 5.  & endif
	  IF XINC LT 12.2 THEN begin XI = 10. & xi2 = 2.  & endif
	  IF XINC LT 7.1  THEN begin XI = 5.  & xi2 = 1.  & endif
	  IF XINC LT 3.2  THEN begin XI = 2.  & xi2 = 0.5 & endif
	  IF XINC LT 1.4  THEN begin XI = 1.  & xi2 = 0.2 & endif
	  FORM = 'h$:m$:s$'
	  if xi gt 30. then form = 'h$:m$'
	  GOTO, DONE
	ENDIF
	;------------  1 min to 1 hr  -------------------
	XINC = XINC/60.
	IF XINC LT 60. THEN BEGIN	; XINC in min < 1 hr.
	  XI = 60.
	  xi2 = 15.
	  IF XINC LT 42.4 THEN begin XI = 30. & xi2 = 10. & endif
	  IF XINC LT 21.2 THEN begin XI = 15. & xi2 = 5.  & endif
	  IF XINC LT 12.2 THEN begin XI = 10. & xi2 = 2.  & endif
	  IF XINC LT 7.1  THEN begin XI = 5.  & xi2 = 1.  & endif
	  IF XINC LT 3.2  THEN begin XI = 2.  & xi2 = 0.5 & endif
	  IF XINC LT 1.4  THEN begin XI = 1.  & xi2 = 0.2 & endif
	  FORM = 'h$:m$'
	  XI = XI*60.	; want step in sec.
	  xi2 = xi2*60.
	  GOTO, DONE
	ENDIF
	;-------------  1 hr to 1 day  -----------------
	XINC = XINC/60.
	IF XINC LT 24. THEN BEGIN	; XINC in hr < 1 day.
	  XI = 24.
	  xi2 = 6.
	  IF XINC LT 17  THEN begin XI = 12. & xi2 = 3.   & endif
	  IF XINC LT 8.5 THEN begin XI = 6.  & xi2 = 2.   & endif
	  IF XINC LT 4.9 THEN begin XI = 4.  & xi2 = 1.   & endif
	  IF XINC LT 2.8 THEN begin XI = 2.  & xi2 = 0.5  & endif
	  IF XINC LT 1.4 THEN begin XI = 1.  & xi2 = 0.25 & endif
	  FORM = 'h$:m$'
	  if xi gt 4 then form = 'h$:m$@d$'
	  if xi gt 12. then form = 'I$'
	  XI = XI*3600.	; want step in sec.
	  xi2 = xi2*3600.
	  GOTO, DONE
	ENDIF
	;---------------  greater then 1 day  -----------------
	XINC = XINC/24.		; XINC is in days.
	P = ALOG10(XINC)	; Scale to 1 to 10.
	IF P LT 0 THEN P = P-1.
	P = FIX(P)
	POW = 10.^P
	XI = XINC/POW
	XINC = XI
	;------ Set increment to a nice value -----------
	XI = 10.			; Filter scaled increment
	xi2 = 2.
	IF XINC LT 7.07 THEN begin XI = 5.   & xi2 = 1.   & endif
	IF XINC LT 3.5  THEN begin XI = 2.5  & xi2 = 0.5  & endif
	IF XINC LT 2.24 THEN begin XI = 2.   & xi2 = 0.5  & endif
	IF XINC LT 1.4  THEN begin XI = 1.   & xi2 = 0.25 & endif
	IF XI GE 10. THEN BEGIN
	  XI = 1.
	  P = P + 1.
	  POW = POW*10.
	ENDIF
	XI = 86400*XI*POW	; XI = true increment.
	xi2 = 86400.*xi2*pow
	FORM = 'I$'
 
DONE:	IF DX LE 0. THEN begin XI = -XI & xi2 = -xi2 & endif
	INRANGE, XI, DX0, DX1, mjx1, mjx2
	INRANGE, XI2, DX0, DX1, mnx1, mnx2
 
	RETURN
 
	END

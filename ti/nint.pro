;+
; NAME:
;       NINT
; PURPOSE:
;       returns nearest integer of real-value x
;*CATEGORY:            @CAT-# 19@
;       Mathematical Functions (General)
; CALLING SEQUENCE:
;       n = NINT(x [,/LONG | ,/AUTO])
; INPUTS:
;       x = real value or array ; values must be -2^31 <= x <= 2^31
; OPTIONAL KEYWORD INPUT:
;       /AUTO  If set and non-zero, and /LONG is NOT set, result will be
;              INTEGER when |x| >= 32767.5, else result will be LONG;
;              if x is an array, result will be LONG, if at least one
;              element of x exceeds the INTEGER-limit.
;       /LONG  If set and non-zero, then the result of NINT
;              is of type LONG in any case. /LONG overules /AUTO !
;              (Nearest long integer is also returned from NLONG (KIS_LIB)
;              or from ROUND (IDL- Routine Vers. 3.1) 
;       Default if neither /LONG nor /AUTO is set: result will be INTEGER.
; OUTPUTS:
;       result  next integer (single value or integer-array)
;              Type is INTEGER if neither /LONG nor /AUTO is set;
;              WARNING: if |x| > 32767.5, (-)32761 will be returned!
;              Type is LONG ,independ. on x, if /LONG is set.
;              Type is either INTEGER or LONG , if /AUTO (but not /long)
;              is set , depending on x.
;              If /LONG or /AUTO is set and |x| >= 2.^31 -0.5, NINT will
;              issue an error message and will not do the conversion.
; NOTE:  IDL routine ROUND returns LONG-integer in any case and is faster 
;              than NINT(x,/LONG) but is VERY SLOW when x exceeds the
;              LONG-limit.
;        KIS_LIB routine NLONG does the same as ROUND, is only a bit slower
;              than ROUND and does not call ROUND.
; PROCEDURE:
;       Calls IDL routines ROUND and FIX
; MODIFICATION HISTORY:
;       nlte, 1990-01-05
;       nlte, 1992-05-06 : faster code, no indices 
;       nlte, 1993-08-04 : keyword /LONG
;       nlte, 1997-01-24 : calls IDL procedures ROUND, FIX (faster),
;                          overflow check, keyword /AUTO for automatic LONG
;                          if overflow for INTEGER (obtained from hoba's
;                          KNINT).
;                          
;-
FUNCTION NINT,x,long=long,auto=auto
on_error,2
if n_elements(x) lt 1 then message,'argument undefined'
;
lng= keyword_set(long)
if not lng and not keyword_set(auto) then return,fix(round(x)) ; type INTEGER
                                                               ; in any case
; fix(x+float(x ge 0)-0.5)  ; this expression was used in NINT-version
                            ; 1992-05-06
mx=max(abs(x))
chki=mx ge 32767.5
if chki then begin  
   lng=1
   chkl=mx*1.d0 ge (2.d0^31 -0.5d0)
   if chkl then message,'conversion impossible'  
endif
if lng then return,round(x) else $
            return,fix(round(x))
end



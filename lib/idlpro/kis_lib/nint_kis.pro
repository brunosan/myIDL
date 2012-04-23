;+
; NAME:
;	NINT
; PURPOSE:
;	returns next SHORT integer of real-value x
;*CATEGORY:            @CAT-# 19@
;	Mathematical Functions (General)
; CALLING SEQUENCE:
;	n = NINT(x)
; INPUTS:
;	x = real value or vector; values must be -32767 <= x <= 32767
;	                          (use NLONG if |x| larger).
; OUTPUTS:
;	next short integer (single value or integer-array);
; PROCEDURE:
;	
; MODIFICATION HISTORY:
;	nlte, 1990-01-05
;	nlte, 1992-05-06 : faster code, no indices 
;-
FUNCTION NINT,x
on_error,1
if n_elements(x) lt 1 then message,'argument undefined'
;
return,fix(x+float(x ge 0)-0.5)
end

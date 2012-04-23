;+
; NAME:
;	NLONG
; PURPOSE:
;	returns next LONG integer of real-value x
;*CATEGORY:            @CAT-# 19@
;	Mathematical Functions (General)
; CALLING SEQUENCE:
;	n = NLONG(x)
; INPUTS:
;	x = real value or vector; values must be:  |x| <= 2.14748e+9
; OUTPUTS:
;	next short integer (single value or integer-array);
; PROCEDURE:
;	
; MODIFICATION HISTORY:
;	nlte, 1992-05-06
;-
FUNCTION NLONG,x
on_error,1
if n_elements(x) lt 1 then message,'argument undefined'
;
return,long(x+float(x ge 0)-0.5)
end

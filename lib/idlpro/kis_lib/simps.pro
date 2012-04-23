FUNCTION simps,f
;+
; NAME:
;	SIMPS
; PURPOSE:
;	Returns [f(0)+4*f(1)+2*f(2)+4*f(3)+...+4*f(n-1)+f(n)]/3
;	        = Simpson-integral of **vector** f if sampled equidistant
;		  with stepwidth =1.
;       (See also function "SIMPSON" in "USER_LIB" which returns
;	 the value of a definite integral of a ** function ** (user-
;	 written code accepting 1 argument)
;*CATEGORY:            @CAT-#  9@
;	Integration
; CALLING SEQUENCE:
;	sum = SIMPS(f)
; INPUTS:
;	f : 1-dim array of function values; size: >= 3, should be
;	    odd if f(n) contributes significantly to the result.
; OUTPUTS:
;	sum : value of Simpson-sum.
; SIDE EFFECTS:
;	none
; RESTRICTIONS:
;	none
; PROCEDURE:
;	straight foreward
; MODIFICATION HISTORY:
;	nlte, 1990-03-17 
;	nlte, 1992-07-13 name changed from SIMPSON to SIMPS to avoid 
;	                 conflict with IDL-USER_LIB.
;-
on_error,1
n=n_elements(f)
if n lt 3 then message,'F less than 3 values'
;
n=n-1
n=(n/2)*2
s=f(0)+f(n)+2.*total(f(2+2*indgen(n/2-1)))+4.*total(f(1+2*indgen(n/2)))
s=s/3.
return,s
end

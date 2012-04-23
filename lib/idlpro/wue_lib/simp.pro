;+
; NAME:
;       SIMP
; PURPOSE:
;       Does Simpson numerical integration on an array of y values.
; CATEGORY:
; CALLING SEQUENCE:
;       i = simp(y, h)
; INPUTS:
;       y = array of y values of function.                 in 
;       h = separation between evenly spaced x values.     in  
; KEYWORD PARAMETERS:
; OUTPUTS:
;       i = value of integral.                             out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 19 Dec, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION SIMP,Y,H, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Does Simpson numerical integration on an array of y values.'
	  print,' i = simp(y, h)' 
	  print,'   y = array of y values of function.                 in'
	  print,'   h = separation between evenly spaced x values.     in' 
	  print,'   i = value of integral.                             out'
	  return, -1
	endif
 
	LAST = N_ELEMENTS(Y) - 1   ; index of last element in Y vector.
	IF (LAST MOD 2) EQ 0 THEN N = LAST ELSE N = LAST - 1  ; force even.
 
	W = 4. - 2.*(INDGEN(N-1) MOD 2)
	I = H/3.*TOTAL([1.,W,1.]*Y(0:N))
 
	IF (LAST GT N) THEN I = I + (Y(LAST-1)+Y(LAST))*H/2.
	RETURN,I
	END

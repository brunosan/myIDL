;+
; NAME:
;       PRINT_FACT
; PURPOSE:
;       Print prime factors found by the factor routine.
; CATEGORY:
; CALLING SEQUENCE:
;       print_fact, p, n
; INPUTS:
;       p = prime factors.          in 
;       n = number of each factor.  in 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner  4 Oct, 1988.
;       RES 25 Oct, 1990 --- converted to IDL V2.
;	R. Sterner, 26 Feb, 1991 --- Renamed from print_factors.pro
;-
 
	PRO PRINT_FACT, P, N, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Print prime factors found by the factor routine.'
	  print,' print_fact, p, n'
	  print,'   p = prime factors.          in'
	  print,'   n = number of each factor.  in'
	  return
	endif
 
	W = WHERE(N GT 0)
	PP = LONG(P(W))
	NN = LONG(N(W))
	t = 1L
	for i = 0, n_elements(pp)-1 do t = t * pp(i)^nn(i)
	PRINT,'    '+spc(strlen(strtrim(t,2))),NN
	PRINT,strtrim(t,2),' = ',PP
	RETURN
	END

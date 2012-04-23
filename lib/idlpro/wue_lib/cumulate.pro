;+
; NAME:
;       CUMULATE
; PURPOSE:
;       Array with the cumulative sum of an array.  Integrate an array.
; CATEGORY:
; CALLING SEQUENCE:
;       out = cumulate(in)
; INPUTS:
;       in = input array.             in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = cumulative sum of in.   out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,  20 June, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION CUMULATE,IN, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Array with the cumulative sum of an array.  Integrate.'
	  print,' out = cumulate(in)'
	  print,'   in = input array.             in'
	  print,'   out = cumulative sum of in.   out'
	  return, -1
	endif
 
	OUT = IN
	OUT(0) = IN(0)
	N = N_ELEMENTS(IN)
	IF N EQ 1 THEN RETURN, OUT
 
	FOR I = 1, N-1 DO BEGIN
	  OUT(I) = OUT(I-1) + IN(I)
	ENDFOR
 
	RETURN, OUT
 
	END

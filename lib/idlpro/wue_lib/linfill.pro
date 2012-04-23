;+
; NAME:
;       LINFILL
; PURPOSE:
;       Fill gaps in array data using linear interpolation.
; CATEGORY:
; CALLING SEQUENCE:
;       LINFILL,A,I1,I2
; INPUTS:
;       A = array to operate on.                         in 
;       I1 = index in A of last good value before gap.   in 
;       I2 = index in A of first good value after gap.   in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       A = updated array.                               out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,  6 Mar, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO LINFILL,A,I1,I2, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Fill gaps in array data using linear interpolation.
	  print,' LINFILL,A,I1,I2
	  print,'   A = array to operate on.                         in'
	  print,'   I1 = index in A of last good value before gap.   in'
	  print,'   I2 = index in A of first good value after gap.   in'
	  print,'   A = updated array.                               out'
	  return
	endif
 
	V1 = A(I1)
	V2 = A(I2)
 
	SC = (V2-V1)/(I2-I1)
 
	FOR I = I1+1, I2-1 DO A(I) = (I-I1)*SC + V1
 
	RETURN
 
	END

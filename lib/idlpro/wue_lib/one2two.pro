;+
; NAME:
;       ONE2TWO
; PURPOSE:
;       Convert from 1-d indices to 2-d indices.
; CATEGORY:
; CALLING SEQUENCE:
;       one2two, in, arr, ix, iy
; INPUTS:
;       in = 1-d indices (may be a scalar).  in 
;       arr = array to use (for size only).  in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       ix, iy = equivalent 2-d indices.     out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 25 May, 1986.
;       Johns Hopkins Applied Physics Lab.
;       R. Sterner, 19 Nov, 1989 --- converted to SUN.
;-
 
	PRO one2two, IN, ARR, INX, INY, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Convert from 1-d indices to 2-d indices.'
	  print,' one2two, in, arr, ix, iy'
	  print,'   in = 1-d indices (may be a scalar).  in'
	  print,'   arr = array to use (for size only).  in'
	  print,'   ix, iy = equivalent 2-d indices.     out'
	  return
	endif
 
	S = SIZE(ARR)
	IF S(0) NE 2 THEN BEGIN
	  PRINT,' Error in one2two: Array must be 2-d.'
	  RETURN
	ENDIF
 
	NX = S(1)
	NY = S(2)
	INX = IN MOD NX
	INY = IN/NX
 
	RETURN
 
	END

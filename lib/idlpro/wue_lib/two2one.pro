;+
; NAME:
;       TWO2ONE
; PURPOSE:
;       Convert from 2-d indices to 1-d indices.
; CATEGORY:
; CALLING SEQUENCE:
;       two2one, ix, iy, arr, in
; INPUTS:
;       ix, iy = 2-d indices.               in 
;       arr = array to use (for size only). in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       in = equivalent 1-d indices.        out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 7 May, 1986.
;       Johns Hopkins Applied Physics Lab.
;       R. Sterner, 19 Nov, 1989 --- converted to SUN
;-
 
	pro two2one, INX, INY, ARR, in, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Convert from 2-d indices to 1-d indices.'	
	  print,' two2one, ix, iy, arr, in'
	  print,'   ix, iy = 2-d indices.               in'
	  print,'   arr = array to use (for size only). in'
	  print,'   in = equivalent 1-d indices.        out'
	  return
	endif
 
	S = SIZE(ARR)
	IF S(0) NE 2 THEN BEGIN
	  PRINT,'Error in two2one: Array must be 2-d.'
	  RETURN
	ENDIF
 
	in = LONG(.5+INY)*S(1) + LONG(.5+INX)
	return
 
	END

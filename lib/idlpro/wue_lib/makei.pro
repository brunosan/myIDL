;+
; NAME:
;       MAKEI
; PURPOSE:
;	Make a long array with given start and end values and step size.
; CATEGORY:
; CALLING SEQUENCE:
;       in = makei(lo, hi, step)
; INPUTS:
;       lo, hi = array start and end values.       in 
;       step = distance beteen values.             in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       in = resulting index array.                out 
; COMMON BLOCKS:
; NOTES:
;       Note: good for subsampling an array. 
; MODIFICATION HISTORY:
;       Ray Sterner,  14 Dec, 1984.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;-
 
	FUNCTION MAKEI,LO,HI,ST, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Make a long array with given start and end '+$
	    'values and step size.'
	  print,' in = makei(lo, hi, step)'
	  print,'   lo, hi = array start and end values.       in'
	  print,'   step = distance beteen values.             in'
	  print,'   in = resulting index array.                out'
	  print,' Note: good for subsampling an array.'
	  return, -1
	endif
 
	RETURN,LONG(LO)+LONG(ST)*LINDGEN(1+(LONG(HI)-LONG(LO))/LONG(ST))
	END

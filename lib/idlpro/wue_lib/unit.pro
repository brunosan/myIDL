;+
; NAME:
;       UNIT
; PURPOSE:
;       Returns unit vector along given vector.
; CATEGORY:
; CALLING SEQUENCE:
;       u = unit(v)
; INPUTS:
;       v = vector: [vx,vy,vz].               in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       u = unit vector along v: [ux,uy,uz].  out
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  24 Aug, 1986.
;       R. Sterner, 14 Feb, 1991 --- converted to IDL V2.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION UNIT, V, help=hlp
 
	if (n_params(0) lt 0) or keyword_set(hlp) then begin
	  print,' Returns unit vector along given vector.'
	  print,' u = unit(v)'
	  print,'   v = vector: [vx,vy,vz].               in'
	  print,'   u = unit vector along v: [ux,uy,uz].  out'
	  return, -1
	endif
 
	return, v/sqrt(total(v^2))
 
	end

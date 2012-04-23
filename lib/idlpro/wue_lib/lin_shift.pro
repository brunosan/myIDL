;+
; NAME:
;	LIN_SHIFT
; PURPOSE:
;	Shift a vector by non-integral number of pixels
;	using linear interpolation.
; CATEGORY:
;	data processing
; CALLING SEQUENCE:
;	out=lin_shift(data,shift)
; INPUTS:
;	data : 1-dim array of numerical type containing unshifted data
;	shift: shift value
; OUTPUTS:
;	out : shifted data
; RESTRICTIONS:
;	only for 1 dimensional arrays
;	data is assumed to be periodic
; PROCEDURE:
;	straight forward.
; MODIFICATION HISTORY:
;	Written, A. Welz, Univ. Wuerzburg, Germany, March 1992
;-
function lin_shift,a,d
on_error,2

if (size(reform(a)))(0) ne 1 then begin
   print,'LIN_SHIFT: first input parameter must be a 1-dimensional array'
   return,a
endif
if n_elements(d) ne 1 then begin
   print,'LIN_SHIFT: second input parameter must be a numerical scalar'
   return,a
endif

if d lt 0. then id=fix(d)-1 else id=fix(d)
fd=d-float(id)
b=shift(reform(a),id)

return,(1.-fd)*b + fd*shift(b,1)

end

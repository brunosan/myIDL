;
;+
; NAME:
;	WPISHIFT
; PURPOSE:
;	SHIFT WITH WEIGHTEND PARABOLIC INTERPOLATION
; CATEGORY:
;	ARRAY MANIPULATION
; CALLING SEQUENCE:
;	FSHIFT = WPISHIFT(FOLD,XSHIFT)
; INPUTS:
;	FOLD   = UNSHIFTED VECTOR
;	XSHIFT = SHIFTVALUE
; OUTPUTS:
;	FSHIFT = SHIFTED VECTOR
; RESTRICTIONS:
;	ABCISSA VALUES MUST BE EQUIDISTANED
; HISTORY:
;	WRITTEN FEB 1992 BY ELMAR KOSSACK
;-
function wpishift,fold,xshift
;
on_error,2
xs=xshift
nx=n_elements(fold)
fo=fltarr(nx+2)
fo(1:nx)=fold
fo(1:nx)=shift(fold,fix(xs))
fo(0)=fo(nx)
fo(nx+1)=fo(1)
;
xo=findgen(nx+2)-fix(xs)-1.
xn=findgen(nx+1)-xs-1.
fn=wpint(xo,fo,xn,/nc,xstart=0)
;
return,fn(1:nx)
end


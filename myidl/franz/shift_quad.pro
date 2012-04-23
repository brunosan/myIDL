function shift_quad,im,dx,dy
;+
; NAME:         shift_quad
; PURPOSE:      Remap image by quadratic interpolation
; CATEGORY:
; CALLING SEQUENCE:
;       In = shift_quad(im,dx,dy)
; INPUTS:
;       Im	= Image to be shifted
;	Dx	= Shift in X-direction
;	Dy	= Shift in Y-direction
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       In
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; MODIFICATION HISTORY:
;       Z. Yi, UiO, June, 1992.
;-
on_error,2

in=shift(im,rfix(dx),rfix(dy))
dx=dx-rfix(dx)	&	dy=dy-rfix(dy)
C=shift(in,1)/2.-in+shift(in,-1)/2.
E=shift(in,0,1)/2.-in+shift(in,0,-1)/2.
D=(SHIFT(IN,0,1)-SHIFT(IN,0,-1))/2.
B=(SHIFT(IN,1)-SHIFT(IN,-1))/2.
z=shift(in,1,1)-shift(in,1,-1)-shift(in,-1,1)+shift(in,-1,-1)
in=IN+B*DX+C*DX*DX+D*DY+E*DY*DY+dx*dy*z/4.

c=0 & d=0 & e=0 & b=0 & z=0

return,IN
END


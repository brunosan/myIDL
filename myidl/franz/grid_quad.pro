function grid_quad,im,X,Y
;===================================================
; NAME:         grid_quad
; PURPOSE:      Remap IM with a set of reference points by 
;		using quadratic interpolation
; CATEGORY:
; CALLING SEQUENCE:
;       Z=grid_quad(im,x,y)
; INPUTS:
;       IM  = Input array
;       X   = X-coordinates of reference points
;       Y   = Y-coordinates of reference points
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       Z
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; MODIFICATION HISTORY:
; Z. Yi, UiO, July 8, 1992
;===================================================

on_error,2
d=size(im)-1

u=rfix(x)
v=rfix(y)

x=x-u	&	y=y-v

in=im(u,v)
c=.5*(shift(im,-1,0)-shift(im,1,0))
in=in+c(u,v)*x
c=.5*(shift(im,0,-1)-shift(im,0,1))
in=in+c(u,v)*y
c=.5*(shift(im,-1,0)+shift(im,1,0))-im
in=in+c(u,v)*x*x
c=.5*(shift(im,0,-1)+shift(im,0,1))-im
in=in+c(u,v)*y*y
c=.25*(shift(im,1,1)-shift(im,1,-1)-shift(im,-1,1)+shift(im,-1,-1))
in=in+c(u,v)*x*y

c=where(u lt 0 or u gt d(1) or v lt 0 or v gt d(2),n)
if n ne 0 then in(c)=mean(im)
u=0 & v=0 & c=0

return,in
end




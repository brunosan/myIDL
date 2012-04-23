function rotation,im,ang,rad=rad,quad=quad,bicub=bicub,spline=spline,cross=cross,xc=xc,yc=yc
;==========================================================================
; NAME:         ROTATION
; PURPOSE:      Rotate IM by different interpolation
; CATEGORY:
; CALLING SEQUENCE:
;       In = ROTation(IM,ang,[/rad,/quad,/bicub,/spline,xc=xc,yc=yc])
; INPUTS:
;       Im	= Image to be rotated
;	ang	= Angle 
; KEYWORD PARAMETERS:
;       rad 	= if set:  ang in radius
;		  else  ang in degree
;	quad	= if set:  by quadratic interpolation
;	bicub	= if set:  by bicubic interpolation
;	spline	= if set:  by spline interpolation
;	poly	= if set:  by 5-point interpolation
;		  defaut:  by bilinear interpolation
;	Xc	= X-coordinate of rotating center 
;	Xc	= Y-coordinate of rotating center 
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
;===========================================================================

on_error,2
d=size(im)	&	x=d(1)	&	y=d(2)

if n_elements(xc) le 0 then xc=(x-1)/2.
if n_elements(yc) le 0 then yc=(y-1)/2.

u=lindgen(x,y)
v=u/x-xc 	&	u=u mod x-yc

if n_elements(rad) le 0 then th=ang*!dtor else th=ang

x1=(u*cos(th)-v*sin(th)+xc)>0<(x-1)
y1=(u*sin(th)+v*cos(th)+yc)>0<(y-1)


case 1 of
	keyword_set(quad):   return,grid_quad(im,x1,y1)
	keyword_set(bicub):  return,grid_bicubic(im,x1,y1)
	keyword_set(spline): return,grid_spline(im,x1,y1)
	keyword_set(cross):   return,grid_5p(im,x1,y1)
	else:                return,interpolate(im,x1,y1)
	endcase

end



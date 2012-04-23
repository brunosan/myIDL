function convolution,In,kernel
;+
; NAME:         convolution
; PURPOSE:      Convolute 2D-image by 1D-vector kernel in
;		x- and y-direction
; CATEGORY:
; CALLING SEQUENCE:
;       IM=convolotion(in,kernel)
; INPUTS:
;       In   	= Input 2D image
;       Kernel  = Kernel
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;	Concoluted image
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; MODIFICATION HISTORY:
;       Zhang Yi, May, 1992, UiO
;-
	on_error,2

	kernel=float(kernel)
	sz=size(in)
        s=size(kernel)/2
 	u=fltarr(sz(1)+2*s(1)+1,sz(2)+2*s(1)+1)
	
	u(s(1):s(1)+sz(1)-1,s(1):s(1)+sz(2)-1)=in

	dum=rotate(in,5)

	u(s(1)+sz(1):*,s(1):s(1)+sz(2)-1)=dum(0:s(1),*)
        u(0:s(1)-1,s(1):s(1)+sz(2)-1)=dum(sz(1)-s(1):*,*)

        u(0:s(1)-1,0:s(1)-1)=dum(sz(1)-s(1):*,sz(2)-s(1):*)
        u(sz(1)+s(1):*,0:s(1)-1)=dum(0:s(1),sz(2)-s(1):*)
        u(sz(1)+s(1):*,sz(2)+s(1):*)=dum(0:s(1),0:s(1))
        u(0:s(1)-1,sz(2)+s(1):*)=dum(sz(1)-s(1):*,0:s(1))
	
	dum=rotate(in,7)
	u(s(1):s(1)+sz(1)-1,s(1)+sz(2):*)=dum(*,0:s(1))
	u(s(1):s(1)+sz(1)-1,0:s(1)-1)=dum(*,sz(2)-s(1):*)
	dum=0

	u=convol(u,kernel,total(kernel))
	u=rotate(u,1)
	u=convol(u,kernel,total(kernel))
	u=rotate(u,3)
	u=u(s(1):s(1)+sz(1)-1,s(1):s(1)+sz(2)-1)	

	return,u
	end
	







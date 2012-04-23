function convol_1d,In,kernel,Nth
;+
; NAME:         CONVOL_1D
;
; PURPOSE:      Convolute 1-3D array by a 1D-vector kernel in
;		x-, y-, or z-direction
;
; CATEGORY:
;
; CALLING SEQUENCE:
;       IM=convol_1D(in, kernel [,Nth] )
;
; INPUTS:
;       In   	= input 1-3D array
;       Kernel  = a 1D-vector or a scalar. If Kernel is a number, it
;		  is assumed to be the width of the boxcar window of smooth. 
; 
; OPTIONAL INPUT:
;	Nth	= The Nth (1-3) dimension along which the convolution is
;		  performed. 
;
; KEYWORD PARAMETERS:
	None
;
; OUTPUTS:
;	Convoluted array
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;
; PROCEDURE:
;	Straghtforward
;
; MODIFICATION HISTORY:
;       Z. Yi, May, 1993, UiO
;-
	on_error,2

	if n_elements(kernel) eq 1 then kernel=intarr(kernel)+1
	sz=size(in)
	if n_elements(Nth) le 0 then dim=0
;====== 1D ======
case 1 of
sz(0) eq 1: begin
	sz=n_elements(in)
        s=size(kernel)/2
 	u=fltarr(sz+2*s(1)+1)
	
	u(s(1):s(1)+sz-1)=in

	u(s(1)+sz:*)=in(0:s(1))
        u(0:s(1)-1) =in(sz-s(1):*)

	u=convol(u,kernel,total(kernel))
	u=u(s(1):s(1)+sz-1)
	end
;====== 2D (X) ======
((sz(0) eq 2) and (Nth eq 1)): begin
	kernel=float(kernel)
	sz=size(in)
        s=size(kernel)/2
 	u=fltarr(sz(1)+2*s(1)+1,sz(2))
	u(s(1):s(1)+sz(1)-1,0:*)=in
	dum=rotate(in,5)
	u(s(1)+sz(1):*,0:*)=dum(0:s(1),*)
        u(0:s(1)-1,0:*)=dum(sz(1)-s(1):*,*)
	u=convol(u,kernel,total(kernel))
	u=u(s(1):s(1)+sz(1)-1,*)	
	end

;====== 2D (Y) ======
((sz(0) eq 2) and (Nth eq 2)): begin
	kernel=float(kernel)
	sz=size(in)
        s=size(kernel)/2
 	u=fltarr(sz(1),sz(2)+2*s(1)+1)
	
	u(0:*,s(1):s(1)+sz(2)-1)=in

	dum=rotate(in,5)
	dum=rotate(in,7)
	u(0:*,s(1)+sz(2):*)=dum(*,0:s(1))
	u(0:*,0:s(1)-1)=dum(*,sz(2)-s(1):*)
	dum=0

;	u=convol(u,kernel,total(kernel))
	u=rotate(u,1)
	u=convol(u,kernel,total(kernel))
	u=rotate(u,3)
	u=u(*,s(1):s(1)+sz(2)-1)	
	end

;====== 3D (X) ======
((sz(0) eq 3) and (Nth eq 1)): begin
	u=in
	for k=0,sz(3)-1 do u(0:*,0:*,k)=convol_1d(reform(in(*,*,k),sz(1),$
		sz(2)),kernel,dim=1)
	end

;====== 3D (Y) ======
((sz(0) eq 3) and (Nth eq 2)): begin
	u=in
	for k=0,sz(3)-1 do u(0:*,0:*,k)=convol_1d(reform(in(*,*,k),sz(1),$
		sz(2)),kernel,dim=2)
	end

;====== 3D (Z) ======
((sz(0) eq 3) and (Nth eq 3)): begin
	u=in
	for k=0,sz(1)-1 do u(k,0:*,0:*)=convol_1d(reform(in(k,*,*),sz(2),$
		sz(3)),kernel,dim=2)
	end
else: begin
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
	end
endcase

	return,u
	end
	










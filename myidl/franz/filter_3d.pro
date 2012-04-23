function FILTER_3d,vp,s_scl,t_scl
;+
; NAME:		FILTER_3D
; PURPOSE:	SUBSONIC WAVE FILTER
; CATEGORY:
; CALLING SEQUENCE:
;	RESULT = FILTER_3D(VP,S_SCL,T_SCL)
; INPUTS:
;	VP =		LIMITED PHASE SPEED IN KM/S
;	S_SCL =		KM/PIXEL
;	T_SCL =		S/DT
; OUTPUTS:
;	TIME SERIES IMAGES AFTER FILTERED
; COMMON BLOCKS:
;	IMAGE		TIME SERIES IMAGES TO BE FILTERED
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE;
;
; MODIFICATION HISTORY:
;	Z. YI, June, 1992,	UiO
;-

common image,im
on_error,2

	s = size(im)

        fx = LINDGEN(s(1),s(2))
        fy = fx / s(1)
        fy = fy / FLOAT(s(2))  
        fx = fx MOD s(1)
        fx = fx / FLOAT(s(1))

	dum = rotate(fx,2)
        fx(s(1)/2,0) = -dum(s(1)/2:*,*)
	dum = rotate(fy,2)
        fy(0,s(2)/2) = -dum(*,s(2)/2:*)
	fs =vp*sqrt(fx*fx+fy*fy)/s_scl  & fx=0 & fy=0

	ft=fltarr(s(3))
	ft(0)=findgen(s(3)-1)
	ft(s(3)-1)=s(3)
        ft = ft/s(3)/t_scl
	dum =rotate(ft,2)

	ft(s(3)/2) = dum(s(3)/2:*)
	f=fft(im,-1)
	im=0
	for k=0,s(3)-1 do begin
	 f(0,0,k)=f(*,*,k)*( fs ge ft(k) )
	 endfor

	
	fs=0	&	ft=0	& dum=0
	f=float(fft(f,1))

	return,f
	end




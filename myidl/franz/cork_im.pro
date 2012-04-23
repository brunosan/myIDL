function cork_im,fx,fy,x0,y0,scl,zm=zm,axscl=axscl
;+
; NAME:
;       CORK_IM
; PURPOSE:
;       Output a movie of "cork" map overlie on series of images IM.
; CALLING SEQUENCE:
;       CMAP=CORK_IM(FX,FY,SCL=SCL,[zm=zm,symsize=symsize])
; INPUTS:
;       FX = 2-D arrays with the X components of the velocity vector, 
;		in unit pixel/dt
;       FY = 2-D arrays with the Y components of the velocity vector, 
;		in unit pixel/dt
;	X0  = X_coordinate of the lower-left cork.
;	Y0  = Y_coordinate of the lower-left cork. 
;       SCL = Scale between IM and FX, FY
; INPUT KER_BOARD parameter:
;       ZM    	= Zoom scale
;	AXSCL	= Scale of axis
; COMMON BLOCK:
;	IMAGE,IM     IM = time series of images
; OUTPUTS:
;	CMAP  = "cork" maps overlie on IM
; MODIFICATION HISTORY:
;       Z. Yi, UiO, Oct. 1992
;-
	common image,im
	on_error,2

	if n_elements(zm)  le 0 then zm=1

	XMAP=FX/Scl	&	YMAP=FY/Scl  	; Change scale

ST1:
	;Input and out. First make two cork arrays for loop #0 :

	sz=size(fx) & dx=sz(1) & dy=sz(2) & sz=0

	s=size(im)  

	x=lindgen(dx,dy)
	y=x/dx   &  x=x mod dx
	x=fix(x) &  y=fix(y)

	READ,'STEPSIZE(dt)=  ',STEP
	READ,'NSTEPS=  ',NSTEP

	map=bytarr(s(1),s(2),nstep,/nozero)
	!x.style=1 & !y.style=1 &  !p.charsize=.00001   

	im=bytscl(im)  &  tv0,zoom(im(*,*,0),zm)

        plot,[0,s(1)]*axscl,[0,s(2)]*axscl,/noerase,/nodata,xst=1,yst=1
	for p=-1,1 do begin
	 plots,(scl*x+x0+p)*axscl,(scl*y+y0)*axscl,psym=3
         plots,(scl*x+x0)*axscl,(scl*y+y0+p)*axscl,psym=3
	endfor
	map(0,0,0)=zoom(tvrd(0,0,s(1)*zm,s(2)*zm),-zm)

	for i=1,nstep-1 do begin

 	 x=x+interpolate(xmap,x,y)*step
	 y=y+interpolate(ymap,x,y)*step

	 x=x>0<(dx-1)	&	 y=y>0<(dy-1)
	 tv,zoom(im(*,*,i),zm)
        plot,[0,s(1)]*axscl,[0,s(2)]*axscl,/noerase,/nodata,xst=1,yst=1
	for p=-1,1 do begin
	 plots,(scl*x+x0+p)*axscl,(scl*y+y0)*axscl,psym=3
         plots,(scl*x+x0)*axscl,(scl*y+y0+p)*axscl,psym=3
	endfor
	 map(0,0,i)=zoom(tvrd(0,0,s(1)*zm,s(2)*zm),-zm)

	endfor

	x=0 & y=0

	s=''
	READ,'STOP OR NOT ? ',s
	IF( (s NE 'Y') AND (s NE 'y') ) THEN GOTO,ST1
	return,map

	end










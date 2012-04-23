pro corkonim,fx,fy,scl,x0,y0,color=color,axscl=axscl,ayscl=ayscl,csize=csize
;+
; NAME:
;       CORKONIM
;
; PURPOSE:
;       Output a movie of "cork" map overlie on a single image of a time
;	series of images IM.
;
; CALLING SEQUENCE:
;       CORKONIM,FX,FY,SCL,X0,Y0,[COLOR=, AXSCL=, AYSCL=, CSIZE=]
;
; INPUTS:
;       FX = 2-D arrays with the X components of the velocity vector, 
;		in unit pixel/dt
;       FY = 2-D arrays with the Y components of the velocity vector, 
;		in unit pixel/dt
;	SCL= Scalling factor between IM and FX, FY
;	X0 = X_coordinate of the lower-left cork.
;	Y0 = Y_coordinate of the lower-left cork. 
;
; INPUT KER_BOARD parameter:
;	COLOR =	Color of corks, 1-255
;	AXSCL    = Scaling factor of X-Axis
;	AySCL    = Scaling factor of Y-Axis
;	CSIZE = Size of corks
;
; COMMON BLOCK:
;	IMAGE,IM,MAP 
;		IM   = the input image or a time series of images.
;		       If IM is a single image, the procedure will ask you
;		       giving the number of running steps, otherwise the 
;		       running step is equal to the frame number of the series.
;		MAP  = outputted "cork" maps overlie on IM
;
; MODIFICATION HISTORY: 
;       Z. Yi,  1992
;- 

	on_error,2
	common image,im,map
	
	if n_elements(ax)  le 0 then ax=1
	if n_elements(ay)  le 0 then ay=1
	if n_elements(csize)  le 0 then csize=2
	
	XMAP=FX/Scl	&	YMAP=FY/Scl  	; Change scale

ST1:
	;Input and out. First make two cork arrays for loop #0 :

	sz=size(fx) & dx=sz(1) & dy=sz(2) 

	s=size(im)  
	x=lindgen(dx,dy)
	y=x/dx   &  x=x mod dx
	x=fix(x) &  y=fix(y)
	if n_elements(color) le 0 then color=255

	READ,'STEPSIZE(dt)=  ',STEP
	if s(0) eq 2 then READ,'NSTEPS=  ',NSTEP else NSTEP=s(3)

	map=bytarr(s(1),s(2),nstep,/nozero)
	!x.style=1 & !y.style=1 &  !p.charsize=.00001   
	
	if color eq 255 then im(0,0)=max(im)+(max(im)-min(im))*.25 $
		else im(0,0)=min(im)-(max(im)-min(im))*.25	

	im=bytscl(im)  
	if s(0) eq 2 then tv0,im else tv0,im(*,*,0)
	!p.color=color

        plot,[0,s(1)]*ax,[0,s(2)]*ay,/noerase,/nodata,xst=1,yst=1
	for p=-csize,csize do begin
 	   plots,(scl*x+x0+p)*ax,(scl*y+y0)*ay,psym=3
	   plots,(scl*x+x0)  *ax,(scl*y+y0+p)*ay,psym=3
	endfor
	map(0,0,0)=tvrd(0,0,s(1),s(2))

	for i=1,nstep-1 do begin

	  x=x+interpolate(xmap,x,y)*step
	  y=y+interpolate(ymap,x,y)*step

	  x=x>0<(dx-1)	&	 y=y>0<(dy-1)
 	  if s(0) eq 2 then tv,im else tv,im(*,*,i)

	  plot,[0,s(1)]*.25,[0,s(2)]*.25,/noerase,/nodata,xst=1,yst=1
	  for p=-csize,csize do begin
 	  	plots,(scl*x+x0+p)*.25,(scl*y+y0)*.25,psym=3
	  	plots,(scl*x+x0)*.25,(scl*y+y0+p)*.25,psym=3
	  endfor
	  map(0,0,i)=tvrd(0,0,s(1),s(2))
	endfor

	x=0 & y=0
	!p.color=255

	s=''
	READ,'STOP OR NOT ? ',s
	IF( (s NE 'Y') AND (s NE 'y') ) THEN GOTO,ST1

	end














pro corkmap,fx,fy,xcork,ycork,scl,axscl=axscl,xtit=xtit,ytit=ytit,tit=tit,x0,y0
;+
; NAME:
;       CORKMAP
; PURPOSE:
;       Computes a "cork" map from a given flowmap fx,fy.
; CALLING SEQUENCE:
;       CORKMAP,FX,FY,XCORK,YCORK,SCL=SCL,AXSCL=AXSCL
; INPUTS:
;       FX = 2-D arrays with the X components of the velocity vector, in pixel/dt
;       FY = 2-D arrays with the Y components of the velocity vector, in pixel/dt
;       SCL   = Scale between image and FX, FY
; INPUT KER_BOARD parameter:
;	AXSCL = Scale of axis
; OUTPUTS:
;       XCORK = X position of corkmap
;       YCORK = Y position of corkmap
; MODIFICATION HISTORY:
;       Zhang Yi
;	August, 1990
;-

	on_error,2

	if n_elements(tit) gt 0 then !p.title=tit else 	!P.TITLE=''
	if n_elements(xtit) gt 0 then !x.title=xtit else !x.TITLE='!6Pixel
	if n_elements(ytit) gt 0 then !y.title=ytit else !y.TITLE='!6Pixel
	if n_elements(x0) gt 0 then x0=x0 else x0=0
	if n_elements(y0) gt 0 then y0=y0 else y0=0

	
	XMAP=FX/Scl	&	YMAP=FY/Scl  ; flow in pixel/dt

ST1:
	;Input and out. First make two cork arrays for loop #0 :

	sz=size(fx) & dx=sz(1) & dy=sz(2) & sz=0
	


	xcork=lindgen(dx,dy)
	ycork=fix( xcork/dx )  &  xcork=fix( xcork mod dx )

	READ,'STEPSIZE (dt) =  ',STEP
	READ,'NSTEPS=  ',NSTEPS

	for i=1,nsteps-1 do begin
	 xcork=xcork+interpolate(xmap,xcork,ycork)*step
	 ycork=ycork+interpolate(ymap,xcork,ycork)*step

	 xcork=xcork>0<(dx-1)
	 ycork=ycork>0<(dy-1)
	endfor

	PLOT,x0+Xcork*axscl,y0+Ycork*axscl,PSYM=3,xst=1,yst=1
	 
	IF(NSTEPS LE 99) THEN NP=STRING(NSTEPS,'(I2)') ELSE NP=STRING(NSTEPS,'(I3)')

	!X.TICKS=6	&	!Y.TICKS=6

a=''
READ,'STOP OR NOT ? ',a
IF( (A NE 'Y') AND (A NE 'y') ) THEN GOTO,ST1

xmap=0 & ymap=0

end


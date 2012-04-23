pro circ,x,y,scl,col=col,dev=dev
;=======================================================================
; NAME:         CIRC
; PURPOSE:      Plots "circle" on coordinates (x,y)
; CATEGORY:
; CALLING SEQUENCE:
;       Circ,x,y,scl=scl
; INPUTS:
;       X	= X-coordinates (array)
;       Y	= Y-coordinates (the same as X)
; KEYWORD PARAMETERS:
;       Scl 	= size of circle
; OUTPUTS:
;       
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; MODIFICATION HISTORY:
;       Zhang Yi, May, 1992.
;=============================================================
	on_error,2

	n=n_elements(x)
	rx=scl*(findgen(101)*.01-.5)

	r=.25*scl*scl     

        if keyword_set(col) then begin
	for k=0,n-1 do begin
	 plots,x(k)+rx,y(k)+sqrt(r-rx*rx),col=col,/dev,lines=0,thick=1
	 plots,x(k)+rx,y(k)-sqrt(r-rx*rx),col=col,/dev
	 empty
	endfor
	endif else begin
	for k=0,n-1 do begin
	 plots,x(k)+rx,y(k)+sqrt(r-rx*rx)
	 plots,x(k)+rx,y(k)-sqrt(r-rx*rx)
	endfor
	endelse

	end


function DEF_CIRC,IM,para=para
;+
; NAME:
;	DEF_CIRC
;
; PURPOSE:
;	Using cursor to define a circular region
;
; CALLING SEQUENCE:
;	RESULT = DEF_CIRC([IM , PARA = PARA])
;
; OPTIONAL INPUTS:
;	IM = 2D ARRAY 
;
; INPUT KERWORD parameter:
;	PARA = Coordinate of the center and the radius of defined circle
;
; OUTPUTS:
;	RESULT = vector of subscripts of points inside the region
;
; MODIFICATION HISTORY:
;       Z. Yi, 1993
;-

	ON_ERROR,2
        Xs=!d.x_vsize     &     Ys=!d.y_vsize
	if n_elements(im) le 0 then im=tvrd(0,0,xs,ys)
        plot,[0,xs],[0,ys],xst=1,yst=1,charsize=.000001,/noerase,/nodata
	
	IF N_ELEMENTS(para) GT 0 THEN BEGIN
	     	X0=PARA(0) & Y0=PARA(1)
		TVCRS,X0,Y0
	ENDIF ELSE CURSOR,X0,Y0,1,/DEV
	
        wait,.2 &       CURSOR,X1,Y1,1,/DEV
        R=SQRT((X1-X0)^2+(Y1-Y0)^2)
	para=[x0,y0,r]
        CIRC,X0,Y0,2*R
        plots,[x0,x0],[y0,y0],psym=1
        X=LINDGEN(XS,YS)        & Y=X/XS-Y0     &       X=(X MOD XS)-X0
        X=SQRT(X^2+Y^2) &       Y=0
        COOR=WHERE(X LE R)
        X=STDEV(IM(COOR),M)
        f="($,i3,2X,i3,2x,F6.2,2x,F8.1,2x,F8.3,1x,f7.4,a)"
        PRINT,'X0    Y0      R      AREA          VALUE       '
        PRINT,FORM=F,FIX(X0),FIX(Y0),R,!PI*R^2,M,X,string("15b)
	print,''
	X=0 

	return,coor
        END










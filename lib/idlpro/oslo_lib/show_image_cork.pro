PRO SHOW_IMAGE_CORK , A , CX , CY , X , Y , TOP = top , MINa = mina , $
	MAXa = maxa , SYMBOL = symbol
;+
; NAME:
;	SHOW_IMAGE_CORK
;
; PURPOSE:
;	Overplot a "cork" map to an image.
;
; CALLING SEQUENCE:
;	SHOW_IMAGE_CORK , A , VX , VY , X , Y , TOP = top , MINa = mina , 
;		MAXa = maxa , SYMBOL = symbol
;
; INPUTS:
;	A = the two dimensional array to display.
;
;	CX,CY = the coordinates of the cork field. It doesn't need to
;		have the same dimensions that A.
;
;	X,Y = vectors containing the values for the X and Y axis.
;		The coordinates CX,CY must be contained within the
;		interval delimited by X,Y.
;
; OPTIONAL INPUTS:
;
;	TOP = maximum value of the scaled result. Default is 255
;
;	MINa = minimum value of A to be considered. Default is minimum
;		of array A.
;
;	MAXa = maximum value of A to be considered. Default is maximum
;		of array A.
;
;	SYMBOL = symbol to draw the cork. Default is 2, an asterisk.
;
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	The currently selected display is affected.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	If the device has scalable pixels, then the image is written over
;	the plot window.
;
; MODIFICATION HISTORY:
;	Written by Roberto Molowny Horas, July 1992.
;	New keywords added, April 1994, RMH
;-
;
ON_ERROR,2

	sz = SIZE(a)			;Size of image.
	IF sz(0) LT 2 THEN MESSAGE,'Parameter not 2D'
	IF N_PARAMS(0) LT 5 THEN MESSAGE,'Wrong number of input parameters'

	IF N_ELEMENTS(top) EQ 0 THEN top = 255
	IF N_ELEMENTS(maxa) EQ 0 THEN maxa = MAX(a)
	IF N_ELEMENTS(mina) EQ 0 THEN mina = MIN(a)
	IF N_ELEMENTS(symbol) EQ 0 THEN symbol = 2

	PLOT,x,y,/nodata,xstyle=4,ystyle=4,$	;Set window for PLOT.
		xtitle='',ytitle='',title=''

	px = !x.window * !d.x_vsize	;Size of window in device units.
	py = !y.window * !d.y_vsize
	swx = px(1) - px(0)		;Size in X in device units.
	swy = py(1) - py(0)		;Size in Y.
	six = FLOAT(sz(1))		;Image sizes.
	siy = FLOAT(sz(2))
	aspi = six / siy		;Image aspect ratio.
	aspw = swx / swy		;Window aspect ratio.
	f = aspi / aspw			;Ratio of aspect ratios.
	IF (!d.flags AND 1) NE 0 THEN BEGIN		;Scalable pixels.
		IF f GE 1. THEN swy = swy /f ELSE swx = swx * f	;Adj.wnd.size.
		TV,BYTSCL(a,TOP=top,MAX=maxa,MIN=mina),$
			px(0),py(0),xsize=swx,ysize=swy,/device
	ENDIF ELSE BEGIN
		IF F GE 1. THEN swy = swy / f ELSE swx = swx * f
		dumb = POLY_2D(FLOAT(a),[[0,0],[six/swx,0]],$
			[[0,siy/swy],[0,0]],1,swx,swy)
		TV,BYTSCL(dumb,TOP=top,MAX=maxa,MIN=mina),px(0),py(0)
	ENDELSE

	pos = [px(0),py(0),px(0)+swx,py(0)+swy]	;Position vector.

	PLOT,x,y,/nodata,/noeras,/xst,/yst,$	;Plots the axis.
		position=pos,/device,xrange=[MIN(x),MAX(x)],yrange=[MIN(y),MAX(y)]
	OPLOT,cx,cy,psym=symbol			;Plots the corks.

END
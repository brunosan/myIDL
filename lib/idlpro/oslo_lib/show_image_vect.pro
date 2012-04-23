PRO SHOW_IMAGE_VECT , A , VX , VY , X , Y , TOP = top , MINa = mina , $
	MAXa = maxa , LENGTH=length
;+
; NAME:
;	SHOW_IMAGE_VECT
;
; PURPOSE:
;	Overplot a horizontal velocity field to an image.
;
; CALLING SEQUENCE:
;	SHOW_IMAGE_VECT , A , VX , VY , X , Y , TOP = top , MINa = mina , 
;		MAXa = maxa , LENGTH=length
;
; INPUTS:
;	A = the two dimensional array to display.
;
;	VX,VY = the horizontal velocity field to overplot. It doesn't need to
;		have the same dimensions that A.
;
; OPTIONAL INPUTS:
;	X,Y = vectors containing the values for the X and Y axis.
;		The dimensions must coincide with VX and VY dimensions.
;
;	TOP = maximum value of the scaled result. Default is 199
;
;	MINa = minimum value of A to be considered. Default is minimum
;		of array A.
;
;	MAXa = maximum value of A to be considered. Default is maximum
;		of array A.
;
;	LENGTH = length factor. The default is 1.0 (see VELOVECT).
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
;	Size of arrays VX,VY must be small.
;
; PROCEDURE:
;	If the device has scalable pixels, then the image is written over
;	the plot window.
;
; EXAMPLE; EXAMPLE:
;	Let Vx,Vy be a flow field in km/s. To show the vector field superposed
;	on an image A, we will do:
;
;	IDL> SHOW_IMAGE_VECT,A,Vx,Vy,x,y,length=2
;
;	where x,y are the axis, in any units. The length of the vector in this
;	example is twice that of a "cell", i.e. twice the distance between
;	[x(i),y(i)] and [x(i+1),y(i+1)]. The length of a vector corresponding
;	to 1 km/s is then given by = 2./MAX(SQRT(vx^2+vy^2))*D, where D is
;	the length of the cell, D = SQRT((x(i+1)-x(i))^2+(y(i+1)-y(i))^2).
;	This can be plotted with PLOT_ARROW. Remember that when using devices
;	with scalable pixels (e.g. PostScript), we should use the option /DATA
;	of PLOT_ARROW for the arrow to be plotted in the right place.
;
; MODIFICATION HISTORY:
;	Written by Roberto Molowny Horas, July 1992.
;	New keywords added, April 1994, RMH
;-
;
ON_ERROR,2

	sz = SIZE(a)					;Size of image.
	IF sz(0) LT 2 THEN MESSAGE,'Parameter not 2D'
	IF N_PARAMS(0) LT 5 THEN MESSAGE,'Wrong number of parameters'

	IF N_ELEMENTS(top) EQ 0 THEN top = 255
	IF N_ELEMENTS(maxa) EQ 0 THEN maxa = MAX(a)
	IF N_ELEMENTS(mina) EQ 0 THEN mina = MIN(a)
	IF N_ELEMENTS(length) EQ 0 THEN length = 1	;Parameter for VELOVECT.

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
	IF (!d.flags AND 1) NE 0 THEN BEGIN
		IF f GE 1. THEN swy = swy /f ELSE swx = swx * f	;Adj.wnd.size.
		TV,BYTSCL(a,TOP=top,MAX=maxa,MIN=mina),$
			px(0),py(0),xsize=swx,ysize=swy,/device
	ENDIF ELSE BEGIN
		IF F GE 1. THEN swy = swy / f ELSE swx = swx * f
		dumb = POLY_2D(FLOAT(a),[[0,0],[six/swx,0]],$
			[[0,siy/swy],[0,0]],1,swx,swy)
		TV,BYTSCL(dumb,TOP=top,MAX=maxa,MIN=mina),px(0),py(0)
	ENDELSE

	pos = [px(0),py(0),px(0)+swx,py(0)+swy]		;Position vector.

	VELOVECT,vx,vy,x,y,length=length,/noerase,$	;Shows the velocity vectors.
		position=pos,/device

END
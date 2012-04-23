PRO PLOT_ARROW,X,Y,LENGTH,ANGLE, DATA = data , NORMAL = normal , THICK = thick , $
	LINESTYLE = linestyle
;+
; NAME:
;	PLOT_ARROW
;
; PURPOSE:
;	Plot one arrow on screen.
;
; CALLING SEQUENCE:
;	PLOT_ARROW,X,Y,LENGTH , [ ANGLE , DATA = , NORMAL = , THICK = , LINESTYLE = ]
;
; INPUTS:
;	X, Y = starting points of the vector.
;
;	LENGTH = length of the vector.
;
; OPTIONAL INPUTS:
;	ANGLE = angle of the vector, degrees counterclockwise, referred to the
;		horizontal.
;
;	DATA = if set, inputs are given in data coordinates.
;
;	NORMAL = if set, inputs are given in normal coordinates.
;		Default is device coordinates.
;
;	THICK = thickness of the vector.
;
;	LINESTYLE = line style to draw the vector. Default is 1 (=solid).
;
; OUTPUTS:
;	A vector drawn on graphic screen.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	A vector is plotted on screen.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Straightforward. Procedure PLOTS is used.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, January 1992.
;-
;
ON_ERROR,2

	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of input parameters'

	IF N_ELEMENTS(thick) EQ 0 THEN thick = 1
	IF N_ELEMENTS(angle) EQ 0 THEN angle = 0.
	IF N_ELEMENTS(linestyle) EQ 0 THEN linestyle = 0

	r = .3
	head = 22.5 * !dtor
	st = r * SIN(head)
	ct = r * COS(head)
	dx = length*COS(angle*!dtor)
	dy = length*SIN(angle*!dtor)
	cx = [x,x+dx,x+dx-(ct*dx-st*dy),x+dx,x+dx-(ct*dx+st*dy)]
	cy = [y,y+dy,y+dy-(st*dx+ct*dy),y+dy,y+dy-(-st*dx+ct*dy)]

	CASE 1 OF
		KEYWORD_SET(data): PLOTS,cx,cy,/data,thick=thick,linestyle=linestyle
		KEYWORD_SET(normal): PLOTS,cx,cy,/normal,thick=thick,linestyle=linestyle
		ELSE: PLOTS,cx,cy,/device,thick=thick,linestyle=linestyle
	ENDCASE

END

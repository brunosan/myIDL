;
;+
;
; NAME:
;	AXIS_INV
; PURPOSE:
; 	Draws an axis with inverse scaling
; CALLING SEQUENCE:
;	AXIS_INV ,BTICKV=BTICKV,YAXIS=YAXIS | XAXIS=XAXIS [MIN,MAX,TICKNAME=TICKNAME
;				     ,STICKV=STICKV,TITLE=TITLE,CHARSIZE=CHARSIZE ]
; INPUTS:
;	none.
; OPTIONAL INPUT PARAMETERS:
;	MIN = left (or lower) value, if not defined, value is taken from BTICKV
;	MAX = right or (upper) value, if not defined, value is taken from BTICKV
; KEYWORDS: 
;	XAXIS = 0 draws an axis under the plot window, with tick marks going up
;	XAXIS = 1 draws an axis over the plot window, with tick marks going down
;	YAXIS = 0 draws an axis at the left of the plot window, with tick marks
;			 to the right
;	YAXIS = 1 draws an axis at the right of the plot window, with tick marks
;			 to the left
;	BTICKV = Vector containing values of big ticks 
;
;	following Keywords are optional
;
;	STICKV = Vector containing values of small ticks 
;	TICKNAME = Vector containing strings to be plotted at big ticks
;			   (by default: integer values of big ticks)
;	TITLE = Axistitle
;	CHARSIZE = see plot-procedure
; OUTPUTS:
;	None.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	Overplot is produced.
; PROCEDURE:
;	Plots an axis with inverse scaling.
; RESTRICTIONS:
;	BTICKV must at least be defined!
;	There must be one of the Keywords XAXIS or YAXIS
; MODIFICATION HISTORY:
;	 Written by Juergen Hofmann, 5.3.1992
;	 Last modification: 13.5.1992
;
;-
;
FUNCTION SIG_ABS,X
if X ge 0 then return,0.
return,abs(x)
end

PRO AXIS_INV,MIN,MAX,XAXIS=XAXIS,YAXIS=YAXIS,BTICKV=BTICKV,STICKV=STICKV,TICKNAME=TICKNAME,TITLE=TITLE,CHARSIZE=CHARSIZE,YORIENTATION=YORIENTATION

	on_error,2                      ;Return to caller if an error occurs

	;check parameters

	if (n_elements(xaxis) eq 0 and n_elements(yaxis) eq 0)  or $
	   (n_elements(xaxis) ne 0 and n_elements(yaxis) ne 0) then begin 
		print, 'axis_inv: you must specify one of the two keywords XAXIS, YAXIS'
		return
	endif

	if n_elements(btickv) eq 0 then begin
		print, 'axis_inv: Dont know which ticks to plot!'
		print, 'axis_inv: tell me! (BTICKV)'
		return
	endif

	;
	; Now we can begin ..
	;

	x0=!p.clip(0)                   ;Device coordinates of clipping window
	x1=!p.clip(2)					;(should be equal to plotting window)
	y0=!p.clip(1)
	y1=!p.clip(3)



	if n_elements(xaxis) ne 0 then begin           ;specify axis

			if xaxis eq 0 then begin
				xx=[x0,x1]
				yy=[y0,y0]
				dir=1
			endif else begin
				xx=[x0,x1]
				yy=[y1,y1]
				dir=-1
			endelse

			posmin=x0
			posmax=x1
	endif

	if n_elements(yaxis) ne 0 then begin

			if yaxis eq 0 then begin
				xx=[x0,x0]
				yy=[y0,y1]
				dir=1
			endif else begin
				xx=[x1,x1]
				yy=[y0,y1]
				dir=-1
			endelse

			posmin=y0
			posmax=y1
	endif



;
;	Make big ticks and their labels
;

	ticks=btickv
	ticknr=n_elements(btickv)

	if n_elements(min) eq 0 then min=ticks(0)        ;is min and max specified?
	if n_elements(max) eq 0 then max=ticks(ticknr-1)

                 							;now evaluate position of ticks

	pos=fltarr(ticknr)
	pos=posmax-(1./ticks-1./max)/(1./min-1./max)*(posmax-posmin)

							;plot axis at specified position
	plots,xx,yy,/device

											;do some calculations for
											;position of labels
											;and plot them 

	if n_elements(tickname) eq 0 then begin
		tickname=strarr(ticknr)
		for i=0,ticknr-1 do	tickname(i)=strn(fix(ticks(i)))
		endif
		

	if n_elements(charsize) eq 0 then begin
		if !p.charsize eq 0 then charsize=1. else charsize=!p.charsize
		endif 

	ticklen=!p.ticklen*(posmax-posmin)*charsize
	tick_y_size=!d.y_ch_size*charsize
	tick_x_size=!d.x_ch_size*charsize

	if n_elements(xaxis) ne 0 then begin

;	X-Axis

	if dir eq -1 then tick_size=sig_abs(ticklen)+tick_y_size/2 $
		else tick_size=-sig_abs(ticklen)-tick_y_size*1.5

		for i=0,ticknr-1 do begin
			plots,[pos(i),pos(i)],[yy(0),yy(1)+dir*ticklen],/device
			xyouts,pos(i),yy(1)+tick_size,tickname(i),/device,alignment=.5,charsize=charsize
			endfor

	endif else begin

; 	Y-Axis, first and last labels have other positions if they are at the edge
;	of the axis:

		if n_params() eq 0 then begin

		i=0       ;first label
			plots,[xx(0),xx(1)+dir*ticklen],[pos(i),pos(i)],/device
			xyouts,xx(1)-tick_x_size*dir/2-dir*sig_abs(ticklen),pos(i),tickname(i),/device,alignment=(dir+1)/2,charsize=charsize

		for i=1,ticknr-2 do begin
			plots,[xx(0),xx(1)+dir*ticklen],[pos(i),pos(i)],/device
			xyouts,xx(1)-tick_x_size*dir/2-dir*sig_abs(ticklen),pos(i)-tick_y_size/2.,tickname(i),/device,alignment=(dir+1)/2,charsize=charsize
			endfor

		i=ticknr-1  ;last label
			plots,[xx(0),xx(1)+dir*ticklen],[pos(i),pos(i)],/device
			xyouts,xx(1)-tick_x_size*dir/2-dir*sig_abs(ticklen),pos(i)-tick_y_size/1.5,tickname(i),/device,alignment=(dir+1)/2,charsize=charsize

		endif else begin

		for i=0,ticknr-1 do begin
			plots,[xx(0),xx(1)+dir*ticklen],[pos(i),pos(i)],/device
			xyouts,xx(1)-tick_x_size*dir/2-dir*sig_abs(ticklen),pos(i)-tick_y_size/2.,tickname(i),/device,alignment=(dir+1)/2,charsize=charsize
			endfor
		
		endelse

	endelse


;
;Now do all the same for small ticks
;

	ticknr=n_elements(stickv)

	if ticknr ne 0 then begin

		ticks=stickv

							;evaluate position of ticks

		pos=fltarr(ticknr)
		pos=posmax-(1./ticks-1./max)/(1./min-1./max)*(posmax-posmin)

										;do some calculations for
										;position of small ticks

		if n_elements(xaxis) ne 0 then begin

			for i=0,ticknr-1 do begin
				plots,[pos(i),pos(i)],[yy(0),yy(1)+dir*ticklen/2.],/device
				endfor

		endif else begin

			for i=0,ticknr-1 do begin
				plots,[xx(0),xx(1)+dir*ticklen/2.],[pos(i),pos(i)],/device
				endfor

		endelse

	endif

	if n_elements(title) ne 0 then begin

;
;	Make axistitle
;

	string=title
	length=strlen(string)

	if n_elements(yaxis) ne 0 then begin
		
		yorientation=90*dir

		xyouts,xx(1)-dir*sig_abs(ticklen)-dir*(max(strlen(tickname))+1.5)*tick_x_size,(y1+y0)/2.,string,/device,orientation=yorientation,alignment=0.5,charsize=charsize

	endif else begin

		xyouts,(x1+x0)/2.,yy(1)-dir*sig_abs(ticklen)-dir*tick_y_size*(1.75+(dir+1)/2),string,/device,alignment=0.5,charsize=charsize
	
	endelse

	endif

end


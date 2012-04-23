Pro Errplot_X, Y, Left, Right, Width = width
;+
; NAME:
;	ERRPLOT_X
; PURPOSE:
;	Overplot error bars over a previously drawn plot.
; CATEGORY:
;	J6 - plotting, graphics, one dimensional.
; CALLING SEQUENCE:
;	ERRPLOT, Y, Low, High	;to specify abscissae
; INPUTS:
;	Left = vector of left estimates, = to data - error.
;	Right = right estimate, = to data + error.
; OPTIONAL INPUT PARAMETERS:
;	Y = vector containing ordinate
; KEYWORD Parameters:
;	Width = width of bars, default = 1% of plot width.
; OUTPUTS:
;	None.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	Overplot is produced.
; RESTRICTIONS:
;	Logarithmic restriction removed.
; PROCEDURE:
;	Error bars are drawn for each element.
;	To plot versus a vector of ordinate:
;		PLOT,X,Y		;Plot data.
;		ERRPLOT,Y,X-ERR,X+ERR	;Overplot error estimates.
; MODIFICATION HISTORY:
;	DMS, RSI, June, 1983.
;	Joe Zawodney, LASP, Univ of Colo., March, 1986. Removed logarithmic
;		restriction.
;	DMS, March, 1989.  Modified for Unix IDL.
;-
	on_error,2                      ;Return to caller if an error occurs
		up = right
		down = left
		yy = y

	if n_elements(width) eq 0 then width = .01 ;Default width
	width = width/2		;Centered
;
	n = n_elements(up) < n_elements(down) < n_elements(yy) ;# of pnts
	xxmin = min(!x.crange)	;X range
	xxmax = max(!x.crange)
	yymax = max(!y.crange)  ;Y range
	yymin = min(!y.crange)

	if !y.type eq 0 then begin	;Test for y linear
		;Linear in y
		wid =  (yymax - yymin) * width ;bars = .01 of plot wide.
	    endif else begin		;Logarithmic y
		yymax = 10.^yymax
		yymin = 10.^yymin
		wid  = (yymax/yymin)* width  ;bars = .01 of plot wide
	    endelse
;
	for i=0,n-1 do begin	;do each point.
		yyy = yy(i)	;y value
		if (yyy ge yymin) and (yyy le yymax) then begin
			plots,[down(i),down(i),down(i),up(i),up(i),up(i)],$
			      [yyy-wid,yyy+wid,yyy,yyy,yyy-wid,yyy+wid]
			endif
		endfor
	return
end


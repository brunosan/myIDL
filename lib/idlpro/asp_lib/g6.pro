pro g6, y1, y2, y3, y4, y5, y6, ps=ps
;+
;
;	function:  g6
;
;	purpose:  Graph 6 arrays to PostScript or X Windows.  This is a
;		  fairly general routine, but requires editing for your
;		  specific file.
;
;	author:  rob@ncar, 4/93
;
;	usage:	1. set 'fileps' for your output file name
;		2. set plot specifics below (label info.)
;		3. run g6 on your arrays (with optional PostScript flag)
;
;==============================================================================

if n_params() ne 6 then begin
	print
	print, "usage:  g6, y1, y2, y3, y4, y5, y6 [, /ps]"
	print
	print, "	Graph 6 arrays to PS or X -- invokes graph6 for Rob."
	print, "	(This file must be edited to be used.)"
	print
	return
endif
;-

;	Set output file for PostScript option.
;------------------------------------------------------------------------------
fileps = 'g6.ps'
;------------------------------------------------------------------------------
;	Set plot specifics.
;------------------------------------------------------------------------------
title = 'ASP June 1992'
xtitle = 'Scan Number'

;ytitle = 'Azimuth'
;xkey = 0.2
;ykey = 0.8

;ytitle = 'Elevation'
;xkey = 0.65
;ykey = 0.35

ytitle = 'Table Position'
xkey = 0.67
ykey = 0.65

subtitle = ''
xfirst = 0
;xfirst = 1
;xfirst = 3
label1 = '6/17 Op. 07'
label2 = '6/17 Op. 18'
label3 = '6/18 Op. 19'
label4 = '6/18 Op. 22'
label5 = '6/19 Op. 07'
label6 = '6/19 Op. 09'
up = 0
;ticks = 1
ticks = 0
;------------------------------------------------------------------------------
;
;	YOU DON'T NEED TO CHANGE ANYTHING BELOW THIS LINE.
;
;------------------------------------------------------------------------------
;
;	Graph it.
;
if keyword_set(ps) then begin
	graph6, y1, y2, y3, y4, y5, y6, $
		fileps=fileps, title=title, xtitle=xtitle, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, up=up, $
		label1=label1, label2=label2, label3=label3, label4=label4, $
		label5=label5, label6=label6, $
		xkey=xkey, ykey=ykey, ticks=ticks, /ps
endif else begin
	graph6, y1, y2, y3, y4, y5, y6, $
		fileps=fileps, title=title, xtitle=xtitle, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, up=up, $
		label1=label1, label2=label2, label3=label3, label4=label4, $
		label5=label5, label6=label6, $
		xkey=xkey, ykey=ykey, ticks=ticks
endelse

end

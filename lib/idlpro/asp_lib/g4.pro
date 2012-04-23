pro g4, y1, y2, y3, y4, ps=ps
;+
;
;	function:  g4
;
;	purpose:  Graph 4 arrays to PostScript or X Windows.  This is a
;		  fairly general routine, but requires editing for your
;		  specific file.
;
;	author:  rob@ncar, 1/92
;
;	usage:	1. set 'fileps' for your output file name
;		2. set plot specifics below (label info.)
;		3. run g4 on your arrays (with optional PostScript flag)
;
;==============================================================================

if n_params() ne 4 then begin
	print
	print, "usage:  g4, y1, y2, y3, y4 [, /ps]"
	print
	print, "	Graph 4 arrays to PS or X -- invokes graph4 for Rob."
	print, "	(This file must be edited to be used.)"
	print
	return
endif
;-

;	Set output file for PostScript option.
;------------------------------------------------------------------------------
fileps = 'g4.ps'
;------------------------------------------------------------------------------
;	Set plot specifics.
;------------------------------------------------------------------------------
;title = 'Mean Intensity Values of Flats for 91.12.15_630_A'
;title = 'RMS Values of Flats for 91.12.15_630_A'
title = 'Raw Values in Row 100'
;xtitle = 'Operation'
xtitle = 'Column'
;ytitle = 'Mean Values'
ytitle = 'Raw Value'
;ytitle = 'RMS Value'
subtitle = ''
;xfirst = 1
;xfirst = 3
;label1 = 'A'
;label2 = 'B'
;label3 = 'C'
;label4 = 'A'
label1 = 'Dark'
label2 = '80 micron'
label3 = '300 micron'
label4 = 'No Slit'
up = 0
xkey = 0.2
ykey = 0.8
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
	graph4, y1, y2, y3, y4, fileps=fileps, title=title, xtitle=xtitle, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, up=up, $
		label1=label1, label2=label2, label3=label3, label4=label4, $
		xkey=xkey, ykey=ykey, ticks=ticks, /ps
endif else begin
	graph4, y1, y2, y3, y4, fileps=fileps, title=title, xtitle=xtitle, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, up=up, $
		label1=label1, label2=label2, label3=label3, label4=label4, $
		xkey=xkey, ykey=ykey, ticks=ticks
endelse

end

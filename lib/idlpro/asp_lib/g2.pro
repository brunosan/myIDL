pro g2, y1, y2, ppp=ppp
;+
;
;	function:  g2
;
;	purpose:  Graph 2 arrays to PostScript or X Windows.  This is a
;		  fairly general routine, but requires editing for your
;		  specific file.
;
;	author:  rob@ncar, 8/92
;
;	usage:	1. set 'fileps' for your output file name
;		2. set plot specifics below (label info.)
;		3. run g2 on your arrays (with optional PostScript flag, ppp)
;
;==============================================================================

if n_params() ne 2 then begin
	print
	print, "usage:  g2, y1, y2 [, /ppp]"
	print
	print, "	Graph 2 arrays to PS or X -- invokes graph2 for Rob."
	print, "	(This file must be edited to be used.)"
	print
	return
endif
;-

;	Set output file for PostScript option.
;------------------------------------------------------------------------------
fileps = 'g7.ps'
;------------------------------------------------------------------------------
;	Set plot specifics.
;------------------------------------------------------------------------------
;title = 'Operation 2,  3/25/92,  Fe,  Camera A,  Sku''s X&T,  Fixed n0'
;title = 'Operation 2,  3/25/92,  Fe,  Camera A,  Sku''s X&T'
;title = 'Operation 2,  3/25/92,  Fe,  Camera A,  Old X&T'
;title = 'Operation 30,  3/24/92,  6149,  Camera A,  X.29, T.30 (ret=0)'
title = 'Operation 48,  3/24/92,  6149,  Camera A,  X.29, T.all'
xtitle = 'Scan Number'
ytitle = 'Mean Values'
;subtitle = '(91.12.15_630_A)'
xfirst = 0
label1 = 'Kq'
label2 = 'Ku'
;up = 0
xkey = 0.5
ykey = 0.3
;ticks = 1
ticks = 0
yrange = [0, 0]
yrange = [-.008, .004]
;psym = -6
psym = 0
;------------------------------------------------------------------------------
;
;	YOU DON'T NEED TO CHANGE ANYTHING BELOW THIS LINE.
;
;------------------------------------------------------------------------------
;
;	Graph it.
;
if keyword_set(ppp) then begin
	graph2, y1, y2, fileps=fileps, title=title, xtitle=xtitle, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, up=up, $
		label1=label1, label2=label2, yrange=yrange, $
		xkey=xkey, ykey=ykey, ticks=ticks, psym=psym, /ppp
endif else begin
	graph2, y1, y2, fileps=fileps, title=title, xtitle=xtitle, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, up=up, $
		label1=label1, label2=label2, yrange=yrange, $
		xkey=xkey, ykey=ykey, ticks=ticks, psym=psym
endelse

end

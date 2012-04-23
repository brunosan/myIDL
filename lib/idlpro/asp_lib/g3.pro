pro g3, y1, y2, y3, ppp=ppp
;+
;
;	function:  g3
;
;	purpose:  Graph 3 arrays to PostScript or X Windows.  This is a
;		  fairly general routine, but requires editing for your
;		  specific file.
;
;	author:  rob@ncar, 1/92
;
;	usage:	1. set 'fileps' for your output file name
;		2. set plot specifics below (label info.)
;		3. run g3 on your arrays (with optional PostScript flag, ppp)
;
;==============================================================================

if n_params() ne 3 then begin
	print
	print, "usage:  g3, y1, y2, y3 [, /ppp]"
	print
	print, "	Graph 3 arrays to PS or X -- invokes graph3 for Rob."
	print, "	(This file must be edited to be used.)"
	print
	return
endif
;-

;	Set output file for PostScript option.
;------------------------------------------------------------------------------
fileps = 'g2.ps'
;------------------------------------------------------------------------------
;	Set plot specifics.
;------------------------------------------------------------------------------
;title = 'Mean Values Per Channel of Dark Scan for Operation 8'
;title = 'Normalized Mean Values of Dark Scan for Operation 8'
;title = 'Normalized Mean Values of 300 Micron Slit for Operation 8'
;title = 'Mean Values Per Channel of 80 Micron Slit for Operation 8'
;title = 'Mean Values Per Channel Per Operation of Darks'
;title = 'Normalized Mean Values Per Operation of Darks'
;title = 'Mean Values Per Channel Per Operation for 80 Micron Slits '
;title = 'Normalized Mean Values Per Operation for 80 Micron Slits'
;title = 'Operation 2,  3/25/92,  Fe,  Camera A,  Old X&T'
;title = 'Operation 2,  3/25/92,  Fe,  Camera A,  Sku''s X&T'
;title = 'Operation 2,  3/25/92,  Fe,  Camera A,  Sku''s X&T,  Fixed n0'
title = 'Operation 48,  3/24/92,  6149,  Camera A,  X.29'
xtitle = 'Scan Number'
;xtitle = 'Operation'
ytitle = 'Mean Values'
;subtitle = '(91.12.15_630_A)'
;xfirst = 2
xfirst = 0
label1 = 'T.wn0'
label2 = 'T.all'
label3 = 'T.ex0'
;label1 = 'Kq'
;label2 = 'Ku'
;label3 = 'Kv'
;label1 = 'Channel A'
;label2 = 'Channel B'
;label3 = 'Channel C'
;label1 = 'Dark'
;label2 = '80 micron'
;label3 = '300 micron'
;up = 0
xkey = 0.5
ykey = 0.9
;xkey = 0.2
;ykey = 0.5
;ticks = 1
ticks = 0
yrange = [-.008, .008]
yrange = [0, 0]
;yrange = [-.004, .006]
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
	graph3, y1, y2, y3, fileps=fileps, title=title, xtitle=xtitle, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, up=up, $
		label1=label1, label2=label2, label3=label3, yrange=yrange, $
		xkey=xkey, ykey=ykey, ticks=ticks, psym=psym, /ppp
endif else begin
	graph3, y1, y2, y3, fileps=fileps, title=title, xtitle=xtitle, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, up=up, $
		label1=label1, label2=label2, label3=label3, yrange=yrange, $
		xkey=xkey, ykey=ykey, ticks=ticks, psym=psym
endelse

end

pro g1, y, ps=ps
;+
;
;	function:  g1
;
;	purpose:  Graph an array to PostScript or X Windows.  This is a
;		  fairly general routine, but requires editing for your
;		  specific file.
;
;	author:  rob@ncar, 1/92
;
;	usage:	1. set 'fileps' for your output file name
;		2. set plot specifics below (label info.)
;		3. run g1 on your array (with optional PostScript flag)
;
;==============================================================================

if n_params() ne 1 then begin
	print
	print, "usage:  g1, y [, /ps]"
	print
	print, "	Graph an array to PS or X -- invokes graph1 for Rob."
	print, "	(This file must be edited to be used.)"
	print
	return
endif
;-

;	Set output file for PostScript option.
;------------------------------------------------------------------------------
fileps = 'g1.ps'
;------------------------------------------------------------------------------
;	Set plot specifics.
;------------------------------------------------------------------------------
;
;	means(0:8)
;
;title = 'Column 100'
;title = 'Raw Values in Row 100 for Dark'
;title = 'Raw Values in Column 100 for 300 Micron Slit'
;title = 'Mean Intensity Values of Flats for 91.12.15_630_A'
;title = 'Mean Intensity Values of 91.12.15_630_A for Darks'
;title = 'Mean Intensity Values of 91.12.15_630_A for 80 Micron Slits'
;title = 'Mean Intensity Values of 91.12.15_630_A for 300 Micron Slits'
;title = 'Mean Intensity Values of 91.12.15_630_A for No Slits'
;title = 'Operation 2,  3/25/92,  Fe,  Camera A,  Old X&T'
;title = 'Operation 2,  3/25/92,  Fe,  Camera A,  Paul''s X&T'
;title = 'Operation 30,  3/24/92,  6149,  Camera A,  X.29, T.30 (ret=0)'
title = 'Operation 48,  3/24/92,  6149,  Camera A,  X.29,  T.ex0,  no rgb corr'

;xtitle = 'Operation'
;xtitle = 'Row'
xtitle = 'Scan Number'

;ytitle = 'Mean Values'
;ytitle = 'Raw Values'
ytitle = 'Mean Kv'

;subtitle = '(flats)'
;subtitle = ''
xfirst = 0
;xfirst = 1
;xfirst = 2
ticks = 0
point_sym = 0
;point_sym = -6
;
;	y = rms_dk(0:7)
;
;title='RMS Values of Darks (FLATs)'
;title='RMS Values for 80 Micron Slit (FLATs)'
;title='RMS Values for 300 Micron Slit (FLATs)'
;title='RMS Values for No Slit (FLATs)'
;xtitle='Operation'
;ytitle='RMS Value'
;subtitle='91.12.15_630_A'
;xfirst = 3
yrange = [0, 0]
yrange = [-.004, .006]
;
;------------------------------------------------------------------------------
;
;	YOU DON'T NEED TO CHANGE ANYTHING BELOW THIS LINE.
;
;------------------------------------------------------------------------------
;
;	Graph it.
;
if keyword_set(ps) then begin
	graph1, y, fileps=fileps, title=title, xtitle=xtitle, yrange=yrange, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, $
		ticks=ticks, point_sym=point_sym, /ps
endif else begin
	graph1, y, fileps=fileps, title=title, xtitle=xtitle, yrange=yrange, $
		ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, $
		ticks=ticks, point_sym=point_sym
endelse

end

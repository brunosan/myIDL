pro plot_m4, a1, a2, a3, a4, $
	title=title, t1=t1, t2=t2, t3=t3, t4=t4, $
	yr1=yr1, yr2=yr2, yr3=yr3, yr4=yr4, $
	fileps=fileps, ps=ps, noverb=noverb
;+
;
;	procedure:  plot_m4
;
;	purpose:  plot 3 or 4 graphs on one output (X or PostScript)
;
;	author:  rob@ncar, 12/92
;
;	ex: plot_m4,x,x,x,x,title=t,t1='Ki',t2='Kq',t3='Ku',t4='Kv'
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() ne 3) and (n_params() ne 4) then begin
	print
	print, "usage:  plot_m4, a1, a2, a3 [, a4]"
	print
	print, "	Plot 3 or 4 graphs on one output (X or PostScript)."
	print
	print, "	Arguments"
	print, "		a1-a4    - input arrays"
	print
	print, "	Keywords"
	print, "		title	 - title of X window or PS plot"
	print, "			   (defs=let IDL choose for X;"
	print, "			    no title for PS plot)"
	print, "		t1-t4	 - individual plot titles"
	print, "			   (defs='Graph 1', 'Graph 2', ...)"
	print, "		yr1-yr4	 - ranges for Y axes"
	print, "			   (defs=let IDL use the data ranges)"
	print
	print, "		ps	 - if set, output to PostScript file"
	print, "			   (def=X Windows)"
	print, "		fileps	 - PostScript file (def=plot_m4.ps)"
	print, "		noverb	 - if set, do not print verbose info"
	print
	print
	print, "   ex:  plot_m4, aa, bb, cc, t1='red', yr1=[0,200], /ps"
	print
	return
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
do_verb = true
if keyword_set(noverb) then do_verb = false
if n_elements(t1) eq 0 then t1 = 'Graph 1'
if n_elements(t2) eq 0 then t2 = 'Graph 2'
if n_elements(t3) eq 0 then t3 = 'Graph 3'
if n_elements(t4) eq 0 then t4 = 'Graph 4'
;
;	Set PostScript- or X-specific parameters.
;
if keyword_set(ps) then begin				; ----- PS -----
	old_font = !p.font	; save old font info
	!p.font = 0		; select hardware font
	plot_ps = true
	if n_elements(fileps) eq 0 then fileps = 'plot_m4.ps'
	set_plot, 'ps'
	xlen_dev = 8.0		; dimensions of entire plot in inches
	ylen_dev = 8.0
	xoffset = (8.5 - xlen_dev) / 2.0
	yoffset = (11.0 - ylen_dev) / 2.0
	device, file=fileps, /inches, xsize=xlen_dev, ysize=ylen_dev, $
		xoffset=xoffset, yoffset=yoffset, /portrait, $
		/times, /bold
;;		/zapfdingbats
;;		/zapfchancery
;;		/schoolbook, /bold
;;		/palatino, /bold
;;		/bkman
;;		/times, /bold
;;		/courier, /bold
;;		/helvetica, /bold
	xthick = 2.0		; thickness of X axes
	ythick = 2.0		; thickness of Y axes
	lthick = 2.0		; thickness of plot lines
	cthick = 2.0		; thickness of plot characters
	pcthick = 3.0		; thickness of PostScript title characters
	csize = 1.1		; size of plot title characters
	pcsize = 1.7		; size of PostScript title characters

endif else begin					; ----- X11 -----
	plot_ps = false
	if n_elements(title) eq 0 then begin
		window, /free
	endif else begin
		window, /free, title=title
	endelse
	xthick = 1.0		; thickness of X axes
	ythick = 1.0		; thickness of Y axes
	lthick = 1.0		; thickness of plot lines
	cthick = 1.0		; thickness of characters
	csize = 1.3		; size of plot title characters
endelse
;
;	Plot.
;
!p.multi = [0, 2, 2, 0, 0]	; set to plot 2 rows x 2 columns
;
if n_elements(yr1) ne 0 then begin
	plot, a1, title=t1, yrange=yr1, charthick=cthick, thick=lthick, $
		xthick=xthick, ythick=ythick, charsize=csize
endif else begin
	plot, a1, title=t1, charthick=cthick, thick=lthick, $
		xthick=xthick, ythick=ythick, charsize=csize
endelse
;
if n_elements(yr2) ne 0 then begin
	plot, a2, title=t2, yrange=yr2, charthick=cthick, thick=lthick, $
		xthick=xthick, ythick=ythick, charsize=csize
endif else begin
	plot, a2, title=t2, charthick=cthick, thick=lthick, $
		xthick=xthick, ythick=ythick, charsize=csize
endelse
;
if n_elements(yr3) ne 0 then begin
	plot, a3, title=t3, yrange=yr3, charthick=cthick, thick=lthick, $
		xthick=xthick, ythick=ythick, charsize=csize
endif else begin
	plot, a3, title=t3, charthick=cthick, thick=lthick, $
		xthick=xthick, ythick=ythick, charsize=csize
endelse
;
if n_params() eq 4 then begin
	if n_elements(yr4) ne 0 then begin
		plot, a4, title=t4, yrange=yr4, charthick=cthick, $
			thick=lthick, xthick=xthick, ythick=ythick, $
			charsize=csize
	endif else begin
		plot, a4, title=t4, charthick=cthick, thick=lthick, $
			xthick=xthick, ythick=ythick, charsize=csize
	endelse
endif
;
!p.multi = 0			; reset to 1 plot per page
;
;	Close PS device and restore X Windows.
;
if plot_ps then begin
	if n_elements(title) ne 0 then $
		xyouts, 0.5, 1.0, title, /norm, align=0.5, $
			charsize=pcsize, charthick=pcthick
	if do_verb then begin
		print
		print, '	Plot to file ' + stringit(fileps)
		print
	endif
	device, /close_file
	set_plot, 'x'
	!p.font = old_font	; restore font setting
endif
;
;	Done.
;
end

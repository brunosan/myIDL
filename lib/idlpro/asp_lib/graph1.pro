pro graph1, y, ps=ps, fileps=fileps, title=title, xtitle=xtitle, $
	ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, ticks=ticks, $
	point_sym=point_sym, yrange=yrange, _extra=e
;+
;
;	procedure:  graph1
;
;	purpose:  Graph an array to X Windows or PostScript file.
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() lt 1 then begin
	print
	print, "usage:  graph1, y"
	print
	print, "	Graph an array to X Windows or a PostScript file."
	print
	print, "	Arguments"
	print, "	       y	- Y array to plot"
	print
	print, "	Keywords"
	print, "	      ps	- if set, output to PostScript file"
	print, "		          (else output to X Windows)"
	print, "	      fileps	- PostScript file (def = graph1.ps)"
	print, "	      title	- main title"
	print, "	      xtitle	- X-axis title"
	print, "	      ytitle	- Y-axis title"
	print, "	      subtitle	- title under xtitle"
	print, "	      xfirst	- first X value (def = 1)"
	print, "	      ticks	- if set, tick on each x value"
	print, "	      point_sym	- point symbol (def = no symbol)"
	print, "	      yrange	- Y-axis range (def = IDL decides)"
	print
	print, " note:  Keyword inheritance has been implemented, thus"
	print, "        any valid PLOT keyword is now permitted."
	print
	return
endif
;-
;
;	Set variables.
;
true = 1
false = 0
plot_ps = false
if keyword_set(ps) then plot_ps = true
numx = n_elements(y)
if n_elements(fileps) eq 0 then fileps = 'graph1.ps'
if n_elements(title) eq 0 then title = ''
if n_elements(xtitle) eq 0 then xtitle = ''
if n_elements(ytitle) eq 0 then ytitle = ''
if n_elements(subtitle) eq 0 then subtitle = ''
if n_elements(xfirst) eq 0 then xfirst = 1
xticks = 0
if keyword_set(ticks) then xticks = numx - 1
if n_elements(point_sym) eq 0 then point_sym = 0
if n_elements(yrange) eq 0 then yrange = [0, 0]
;
;	Set up for PostScript.
;
if plot_ps then begin
	set_plot, 'ps'
	device, filename=fileps
endif
;
;	Set x array.
;
x = indgen(numx) + xfirst
;
;	Plot array.
;
if (yrange(0) eq 0) and (yrange(1) eq 0) then begin
	plot, x, y, /ynoz, title=title, xstyle=1, $
		xtitle=xtitle, ytitle=ytitle, _extra=e, $
		subtitle=subtitle, xminor=-1, xticks=xticks, psym=point_sym
endif else begin
	plot, x, y, /ynoz, title=title, xstyle=1, $
		xtitle=xtitle, ytitle=ytitle, $
		subtitle=subtitle, xminor=-1, xticks=xticks, psym=point_sym, $
		ystyle=1, yrange=yrange, _extra=e
endelse
;
;	Close PS device and restore X Windows.
;
if plot_ps then begin
	print
	print, '	Plot to file ' + stringit(fileps)
	print
	device, /close_file
	set_plot, 'x'
endif
;
;	Done.
;
end

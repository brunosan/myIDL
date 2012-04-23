pro graph3, y1, y2, y3, ppp=ppp, fileps=fileps, title=title, $
	xtitle=xtitle, ytitle=ytitle, subtitle=subtitle, xfirst=xfirst, $
	label1=label1, label2=label2, label3=label3, up=up, $
	xkey=xkey, ykey=ykey, ticks=ticks, yrange=yrange, psym=psym, _extra=e
;+
;
;	procedure:  graph3
;
;	purpose:  Graph 3 arrays.
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 3 then begin
	print
	print, "usage:  graph3, y1, y2, y3"
	print
	print, "	Graph three arrays on one plot."
	print
	print, "	Arguments"
	print, "	    y1-y3	- Y arrays to plot"
	print
	print, "	Keywords"
	print, "	    fileps	- PostScript file (def = graph3.ps)"
	print, "	    title	- main title"
	print, "	    xtitle	- X-axis title"
	print, "	    ytitle	- Y-axis title"
	print, "	    subtitle	- title under xtitle"
	print, "	    xfirst	- first X value (def = 1)"
	print, "	    label1	- label for 1st curve (def = curve 1)"
	print, "	    label2	- label for 2nd curve (def = curve 2)"
	print, "	    label3	- label for 3rd curve (def = curve 3)"
	print, "	    xkey	- X location of key left corner (NDC)"
	print, "	    ykey	- Y location of key left corner (NDC)"
	print, "	    ticks	- if set, tick on each x value"
	print, "	    yrange	- Y-axis range (def = IDL decides)"
	print, "	    psym	- IDL plot symbol (def = none)"
	print, "	     ppp	- if set, output to PostScript file"
	print, "		          (else output to X Windows)"
	print, "	      up	- if set, plot key up from xkey,ykey"
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
if keyword_set(ppp) then plot_ps = true
numx = n_elements(y1)
if n_elements(fileps) eq 0 then fileps = 'graph3.ps'
if n_elements(title) eq 0 then title = ''
if n_elements(xtitle) eq 0 then xtitle = ''
if n_elements(ytitle) eq 0 then ytitle = ''
if n_elements(subtitle) eq 0 then subtitle = ''
if n_elements(xfirst) eq 0 then xfirst = 1
if n_elements(label1) eq 0 then label1 = 'curve 1'
if n_elements(label2) eq 0 then label2 = 'curve 2'
if n_elements(label3) eq 0 then label3 = 'curve 3'
key_dir = -1
if keyword_set(up) then key_dir = 1
if n_elements(xkey) eq 0 then xkey = 0.5
if n_elements(ykey) eq 0 then ykey = 0.6
xticks = 0
if keyword_set(ticks) then xticks = numx - 1
if n_elements(yrange) eq 0 then yrange = [0, 0]
if n_elements(psym) eq 0 then psym = 0
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
;	Get max and min values of all y arrays.
;
ymin = min([y1, y2, y3], max=ymax)
;
;	Scale plot to include full range of y's, unless yrange specified.
;
y = y1
y(0) = ymin
y(1) = ymax

if (yrange(0) eq 0) and (yrange(1) eq 0) then begin
	plot, x, y, /ynoz, title=title, xstyle=1, $
		xtitle=xtitle, ytitle=ytitle, $
		subtitle=subtitle, /nodata, xminor=-1, xticks=xticks, _extra=e
endif else begin
	plot, x, y, /ynoz, title=title, xstyle=1, $
		xtitle=xtitle, ytitle=ytitle, $
		subtitle=subtitle, /nodata, xminor=-1, xticks=xticks, $
		ystyle=1, yrange=yrange, _extra=e
endelse
;
;	Plot arrays.
;
oplot, x, y1, line=0, psym=psym
oplot, x, y2, line=1, psym=psym
oplot, x, y3, line=2, psym=psym
;
;	Plot key.
;
del_ykey = 0.03
x_line_len = 0.1
xl1 = xkey + 0.15
xl2 = xl1 + x_line_len
ychar = .005
;
xyouts, xkey, ykey, label1, /normal
yl = ykey + ychar
plots, [xl1, xl2], [yl, yl], line=0, /normal
;
ykey = ykey + (key_dir *  del_ykey)
xyouts, xkey, ykey, label2, /normal
yl = ykey + ychar
plots, [xl1, xl2], [yl, yl], line=1, /normal
;
ykey = ykey + (key_dir *  del_ykey)
xyouts, xkey, ykey, label3, /normal
yl = ykey + ychar
plots, [xl1, xl2], [yl, yl], line=2, /normal
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

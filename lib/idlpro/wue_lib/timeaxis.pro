;+
; NAME:
;       TIMEAXIS
; PURPOSE:
;       Plot a time axis.
; CATEGORY:
; CALLING SEQUENCE:
;       timeaxis, [t]
; INPUTS:
;       t = optional array of seconds after midnight.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         JD=jd   Set Julian Day number of reference date.
;         FORM=f  Set axis label format string, over-rides default.
;           do help,dt_tm_mak(/help) to get formats.
;           For multi-line labels use @ as line delimiter.
;         NTICKS=n  Set approximate number of desired ticks (def=6).
;         TITLE=txt Time axis title (def=none).
;         TRANGE=[tmin,tmax] Set specified time range.
;         YVALUE=Y  Y coordinate of time axis (def=bottom).
;         TICKLEN=t Set tick length as % of yrange (def=5).
;         LABELOFFSET=off Set label Y offset as % yrange (def=0).
;           Allows label vertical position adjustment.
;         DY=d  Set line spacing factor for multiline labels (def=1).
;         COLOR=c   Axis color.
;         SIZE=s    Axis text size.
;         MAJOR=g   Linestyle for an optional major tick grid.
;         MINOR=g2  Linestyle for an optional minor tick grid.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: To use do the following:
;         plot, t, y, xstyle=4
;         timeaxis
;         If no arguments are given to TIMEAXIS then an
;         axis will be drawn based on the last plot, if any.
;         Try DY=1.5 for PS fonts.
; MODIFICATION HISTORY:
;       R. Sterner, 25 Feb, 1991
;-
 
	pro timeaxis, t, jd=jd, form=form, nticks=nticks, $
	  yvalue=yvalue, trange=trange, color=color, size=size, $
	  help=hlp, ticklen=ticklen, labeloffset=laboff, dy=dy, $
	  title=title, major=grid, minor=grid2
 
	if keyword_set(hlp) then begin
help:	  print,' Plot a time axis.'
	  print,' timeaxis, [t]'
	  print,'   t = optional array of seconds after midnight.  in'
	  print,' Keywords:'
	  print,'   JD=jd   Set Julian Day number of reference date.'
	  print,'   FORM=f  Set axis label format string, over-rides default.'
	  print,'     do help,dt_tm_mak(/help) to get formats.'
	  print,'     For multi-line labels use @ as line delimiter.'
	  print,'   NTICKS=n  Set approximate number of desired ticks (def=6).'
	  print,'   TITLE=txt Time axis title (def=none).'
	  print,'   TRANGE=[tmin,tmax] Set specified time range.'
	  print,'   YVALUE=Y  Y coordinate of time axis (def=bottom).'
	  print,'   TICKLEN=t Set tick length as % of yrange (def=5).'
	  print,'   LABELOFFSET=off Set label Y offset as % yrange (def=0).'
	  print,'     Allows label vertical position adjustment.'
	  print,'   DY=d  Set line spacing factor for multiline labels (def=1).'
	  print,'   COLOR=c   Axis color.'
	  print,'   SIZE=s    Axis text size.'
	  print,'   MAJOR=g   Linestyle for an optional major tick grid.'
	  print,'   MINOR=g2  Linestyle for an optional minor tick grid.'
	  print,' Notes: To use do the following:'
	  print,'   plot, t, y, xstyle=4'
	  print,'   timeaxis'
	  print,'   If no arguments are given to TIMEAXIS then an'
	  print,'   axis will be drawn based on the last plot, if any.'
	  print,'   Try DY=1.5 for PS fonts.'
	  return
	endif
 
	cr = string(13b)			; Carriage Return.
 
	;------  Find time range  -------------
	if n_params(0) ge 1 then begin		; First try from given array.
	  xmn = min(t)
	  xmx = max(t)
	endif
	if n_elements(trange) ne 0 then begin	; Over-ride with range.
	  xmn = trange(0)
	  xmx = trange(1)
	endif
 
	if n_elements(xmn) eq 0 then begin	; Use last plot range.
	  xmn = !x.crange(0)
	  xmx = !x.crange(1)
 	endif
 
	if (xmn + xmx) eq 0 then goto, help
 
	;--------  Find axis numbers  -----------
	if n_elements(nticks) eq 0 then nticks=6	; Number of ticks.
	tnaxes, xmn, xmx, nticks, tt1, tt2, dtt, $	; Axis numbers.
	  t1, t2, dt, form=frm
	if n_elements(form) eq 0 then form = frm	; Label format.
	v = makex( tt1, tt2, dtt)			; Labeled ticks array.
	v2 = makex(t1, t2, dt)				; Minor ticks array.
	;--------  Make axis labels  ------------
	lab = time_label(v, form, jd=jd)
 
	;--------  Tick length  ---------------
	yrange = !y.crange(1) - !y.crange(0)		; Y data range.
	if n_elements(ticklen) eq 0 then ticklen = 3.	; Labeled tick length.
	oneperc = yrange/100.				; 1%.
	tickl = ticklen*oneperc				; Tick in data coord.
	
	;-------  Axis y position  ------------
	yv = !y.crange(0)				; Lower x axis y value.
	if n_elements(yvalue) ne 0 then begin
	  yv = yvalue
	endif
 
	mxlines = 1
	;-------  Plot axis  ------------------
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(size) eq 0 then size = 1.
	if n_elements(laboff) eq 0 then laboff = 0.
	if n_elements(dy) eq 0 then dy = 1.
	plots, !x.crange, [yv, yv], color=color
	for i = 0, n_elements(v)-1 do begin	; Major (Labeled) ticks.
	  plots, [v(i),v(i)], [yv,yv+tickl], color=color
	  xprint, /init, v(i) ,yv-laboff*oneperc, /data, $
	    size=size, dy=dy, yspace=ysp
	  xprint,' '
	  labtxt = lab(i)
	  for j = 0, 5 do begin
	    txt = getwrd(labtxt, j, delim=cr)
	    if txt eq '' then goto, skip
	    mxlines = mxlines > (j+1)
	    xprint, txt, align=.5, color=color
	  endfor
skip:
	endfor
	for i = 0, n_elements(v2)-1 do begin	; Minor ticks.
	  plots, [v2(i),v2(i)], [yv,yv+tickl/2.], color=color
	endfor
 
	;-------  Top axis  -------------
	if n_elements(yvalue) eq 0 then begin
	  plots, !x.crange, [0,0]+!y.crange(1), color=color
	  for i = 0, n_elements(v)-1 do begin
	    plots, [v(i),v(i)], [0,-tickl]+!y.crange(1), color=color
	  endfor
	  for i = 0, n_elements(v2)-1 do begin	; Minor ticks.
	    plots, [v2(i),v2(i)], [0,-tickl/2.]+!y.crange(1), color=color
	  endfor
	endif
 
	;------------  Title  ---------------
	if n_elements(title) ne 0 then begin
	  tx = total(!x.crange)/2.
	  ybase = yv
	  if tickl lt 0 then ybase = yv + tickl
	  ty = (ybase-laboff*oneperc-ysp/2.) < ybase
	  xprint,/init,tx,ty,/data,size=size,dy=dy
	  xprint,' '
	  if laboff ge 0 then for i = 1, mxlines do xprint,' '
	  xprint, title, align=.5, color=color
	endif
 
	;-------------  Grids  ----------------
	if n_elements(grid) ne 0 then begin		; Major grid.
	  for i = 0, n_elements(v)-1 do begin
	    ver, v(i), color=color, linestyle=grid
	  endfor
	endif
	if n_elements(grid2) ne 0 then begin		; Minor grid.
	  for i = 0, n_elements(v2)-1 do begin
	    if (v2(i) mod dtt) ne 0 then begin
	      ver, v2(i), color=color, linestyle=grid2
	    endif
	  endfor
	endif
 
 
 
	return
	end

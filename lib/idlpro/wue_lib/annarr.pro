;+
; NAME:
;       ANNARR
; PURPOSE:
;       Interactively draw arrows on the screen with mouse. Annotate.
; CATEGORY:
; CALLING SEQUENCE:
;       annarr
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords: 
;         COLOR=c arrow outline color (def=255). 
;           Make same as FILL for no outline. 
;         THICK=t arrow outline thickness (def=0). 
;         LINESTYLE=s arrow outline line style (def=0). 
;         FILL=f set arrow fill color (0-255, def = -1 = no fill). 
;         LENGTH=l  Arrow head length in % plot width (def = 3). 
;         WIDTH=w  Arrow head width in % plot width (def = 2). 
;         SHAFT=s  Arrow shaft width in % plot width (def = 1). 
; OUTPUTS:
; COMMON BLOCKS:
;       ann_com
; NOTES:
;       Notes: One of the graphics annotation tools. 
;         Results of these tools may be saved, recalled, 
;         and repeated later. 
;         Do annhlp for more info on the annotate tools. 
; MODIFICATION HISTORY:
;       R. Sterner, 21 Sep, 1990
;-
 
	pro annarr, help=hlp, color=color, linestyle=linestyle, thick=thick, $
	  fill=fill, length=alen0, width=awid0, shaft=ash0
 
	common ann_com, x, y, pen, clr, sty, thk, ntxt, tx, ty, tc, ts, ta, $
	  tt, txt, onechar, pfx, pfy, pfpen, pfclr, pfthk, pfsty, pffc
	; Annotation tool common: --------------------------------------------
	; Lines: x,y = arrays of x,y coordinates.  Pen = pen code.           |
	;        clr = line color, sty = line style, thk = line thickness.   |
	; Text:  tx,ty = text position.  tc,ts,ta = text color, size, angle. |
	;        tt = thickness.  txt = text strings.  ntxt = # text strings.|
	;        onechar = norm. size of 1 char on original device.          |
	; Polyfill: pfx,pfy = polyfill points, pfpen = polyfill pen code,    |
	;        pfclr,pfthk,pfsty = polyfill outline color, thick, style,   |
	;        pffc = polyfill fill color.                                 |
	;---------------------------------------------------------------------
 
	if keyword_set(hlp) then begin
	  print,' Interactively draw arrows on screen with mouse. Annotate.'
	  print,' annarr'
	  print,'   Left button - draw temporary arrow.'
	  print,'   Middle button - draw permanent arrow.'
	  print,'   Right button - quit.'
	  print,' Keywords:'
	  print,'   COLOR=c arrow outline color (def=255).'
	  print,'     Make same as FILL for no outline.'
	  print,'   THICK=t arrow outline thickness (def=0).'
	  print,'   LINESTYLE=s arrow outline line style (def=0).'
	  print,'   FILL=f set arrow fill color (0-255, def = -1 = no fill).'
	  print,'   LENGTH=l  Arrow head length in % plot width (def = 3).'
	  print,'   WIDTH=w  Arrow head width in % plot width (def = 2).'
	  print,'   SHAFT=s  Arrow shaft width in % plot width (def = 1).'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.'
	  print,'   Do annhlp for more info on the annotate tools.'
	  return
	endif
 
	;---------  Make sure parameters set  ---------
	if n_elements(alen0) eq 0 then alen0 = 3.0
	if n_elements(awid0) eq 0 then awid0 = 2.0
	if n_elements(ash0) eq 0 then ash0 = 1.0
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(linestyle) eq 0 then linestyle = !p.linestyle
	if n_elements(thick) eq 0 then thick = !p.thick
	if n_elements(fill) eq 0 then fill = -1
	if n_elements(x) eq 0 then annres		; Reset memory arrays.
	m = 0
	alen = alen0/100.
	awid2 = awid0/100./2.
	ash2 = ash0/100./2.
	;  Arrows have a problem in normalized coordinates.  A length of 1 unit
	;  will in general be different in X and Y.  This may be handled easily
	;  by converting to an isotropic coordinate system, computing the arrow,
	;  then converted back to norm. to plot.  The factor ff is the x to y
	;  shape ratio that does this conversion.
	ff = float(!d.x_size)/float(!d.y_size)	; Fudge fact to cor norm coord.
 
	print,' '
	print,' Use mouse to position arrow.'
	print,' Left button - position arrow.'
	print,' Middle button - draw arrow.'
	print,' Right button - quit.'
	print,' '
 
loop:	cursor, x0, y0, 1, /norm
	x0 = x0*ff				; Correct norm coord.
	wait, .2
 
	;-----------  Temporary arrow  ---------
	if !err eq 1 then begin
	  device, set_graphics=6		; Set XOR.
	  if m eq 2 then begin			; New temp arrow.
	    plots, xp/ff, yp, /norm		; Erase old temp arrow.
	    m = 0				; Reset endpoint flag.
	  endif
	  if m eq 0 then begin			; First endpoint.
	    x1 = x0
	    y1 = y0
	    plots, [x1,x1]/ff, [y1,y1], /norm	; Plot endpoint.
	  endif
	  if m eq 1 then begin			; Have both endpoints.
	    x2 = x0						; ARROW POINT.
	    y2 = y0
	    plots, [x1,x1]/ff, [y1,y1], /norm	; Plot one.
	    dx = x2 - x1  & dy = y2 - y1	; Set up arrow.
	    m1 = sqrt(dx^2 + dy^2)>.1
	    u1x = dx/m1  & u1y = dy/m1		; Unit vector along arrow.
	    u2x = -u1y  & u2y = u1x		; Unit vector across arrow.
	    x2b = x2 - alen*u1x  & y2b = y2 - alen*u1y	  ; Midpt back of head.
	    hx1 = x2b + ash2*u2x  & hy1 = y2b + ash2*u2y     ; ARROW HEAD BACK.
	    hx2 = x2b - ash2*u2x  & hy2 = y2b - ash2*u2y     ; ARROW HEAD BACK.
	    hx3 = x2b + awid2*u2x  & hy3 = y2b + awid2*u2y   ; ARROW HEAD BACK.
	    hx4 = x2b - awid2*u2x  & hy4 = y2b - awid2*u2y   ; ARROW HEAD BACK.
	    tx1 = x1 + ash2*u2x  & ty1 = y1 + ash2*u2y	     ; ARROW TAIL.
	    tx2 = x1 - ash2*u2x  & ty2 = y1 - ash2*u2y	     ; ARROW TAIL.
	    xp = [tx1, hx1, hx3, x2, hx4, hx2, tx2, tx1]
	    yp = [ty1, hy1, hy3, y2, hy4, hy2, ty2, ty1]
	    plots, xp/ff, yp, /norm		; Plot temp arrow.
	  endif
	  m = m + 1
	endif
 
	;--------  Permanent arrow  ------------
	if !err  eq 2 then begin
	  if m eq 2 then begin			; Have both endpoints.
	    plots, xp/ff, yp, /norm		; Erase temp arrow.
	    device, set_graphics=3		; Set CPY, plot perm arrow.
	    if fill ne -1 then polyfill, /norm, xp/ff, yp, color=fill
	    plots, xp/ff, yp, /norm, color=color, linestyle=linestyle, $
	      thick=thick
	    pfx = [pfx,xp/ff]			; Add arrow to memory.
	    pfy = [pfy,yp]
	    pfpen = [pfpen, 0,1,1,1, 1,1,1,1]
	    pfclr = [pfclr,color]
	    pffc = [pffc,fill]
	    pfsty = [pfsty, linestyle]
	    pfthk = [pfthk, thick]
	    print,' Arrow added to memory.'
	    m = 0
	  endif
	endif
 
	;--------  Quit  ------------
	if !err eq 4 then begin
	  if m eq 2 then begin
	    plots, xp/ff, yp, /norm		; Erase temp arrow.
	    device, set_graphics=3		; Set CPY.
	  endif
	  return
	endif
 
	goto, loop
 
	end

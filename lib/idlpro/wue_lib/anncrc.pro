;+
; NAME:
;       ANNCRC
; PURPOSE:
;       Interactively draw circles on the screen with mouse. Annotate.
; CATEGORY:
; CALLING SEQUENCE:
;       anncrc
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords: 
;         COLOR=c circle outline color (def=255). 
;           Make same as FILL for no outline. 
;         THICK=t circle outline thickness (def=0). 
;         LINESTYLE=s circle outline line style (def=0). 
;         FILL=f set circle fill color (0-255, def = -1 = no fill). 
; OUTPUTS:
; COMMON BLOCKS:
;       annbox_com
;       ann_com
; NOTES:
;       Notes: One of the graphics annotation tools. 
;         Results of these tools may be saved, recalled, 
;         and repeated later. 
;         Do annhlp for more info on the annotate tools. 
; MODIFICATION HISTORY:
;-
 
	pro anncrc, help=hlp, color=color, thick=thick, linestyle=linestyle, $
	  fill=fill
 
	common annbox_com, xb, yb, dbx, dby
 
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
	  print,' Interactively draw circles on screen with mouse. Annotate.'
	  print,' anncrc'
	  print,'   Left button - position circle/adjust circle size.'
	  print,'   Middle button - draw permanent circles.'
	  print,'   Right button - quit.'
	  print,' Keywords:'
          print,'   COLOR=c circle outline color (def=255).'
          print,'     Make same as FILL for no outline.'
          print,'   THICK=t circle outline thickness (def=0).'
          print,'   LINESTYLE=s circle outline line style (def=0).'
          print,'   FILL=f set circle fill color (0-255, def = -1 = no fill).'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.'
	  print,'   Do annhlp for more info on the annotate tools.'
	  return
	endif
 
	;---------  Make sure parameters set  ---------
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(thick) eq 0 then thick = !p.thick
	if n_elements(linestyle) eq 0 then linestyle = !p.linestyle
	if n_elements(fill) eq 0 then fill = -1
	if n_elements(x) eq 0 then annres		; Reset memory arrays.
 
	if n_elements(xb) eq 0 then begin
	  xb = 100
	  yb = 100
	  dbx = 100
	  dby = 100
	endif
 
	print,' '
	print,' Circle will be inscribed in box when middle button is pressed.'
	print,' Use mouse to position box.'
	print,' Left button - position box/adjust box size.'
	print,' Middle button - Draw circle.'
	print,' Right button - quit.'
	print,' '
 
	xo = 0	; Options box position.
	yo = 0
 
loop:	movbox, xb, yb, dbx, dby, code, color=color, /nomenu,$
	   /noerase, /exiterase, /options, x_opt=xo, y_opt=yo
 
	if code eq 4 then return	; Quit.
 
	sx = float(!d.x_size)		; Screen size.
	sy = float(!d.y_size)
 
	x1 = xb/sx			; Convert dev to norm.
	y1 = yb/sy
	dx = (dbx-1)/sx
	dy = (dby-1)/sy
	x2 = x1 + dx
	y2 = y1 + dy
	xm = (x1+x2)/2.
	ym = (y1+y2)/2.
	r = dx/2.
	b = dy/dx
	polrec, r, makex(0,360,5)/!radeg, xp, yp
	xp = xp + xm
	yp = b*yp + ym
 
	if fill ne -1 then polyfill, /norm, xp, yp, color=fill
	plots, /norm, xp, yp, color=color, thick=thick, linestyle=linestyle
 
	pfx = [pfx,xp]			; Save circle in memory.
	pfy = [pfy,yp]
	p = fix(xp*0+1)
	p(0) = 0
	pfpen = [pfpen, p]
	pfclr = [pfclr, color]
	pffc = [pffc, fill]
	pfsty = [pfsty, linestyle]
	pfthk = [pfthk, thick]
	print,' Circle added to memory.'
 
	goto, loop
 
	end

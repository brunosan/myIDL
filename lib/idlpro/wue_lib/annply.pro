;+
; NAME:
;       ANNPLY
; PURPOSE:
;       Interactively draw polygons on the screen with mouse. Annotate.
; CATEGORY:
; CALLING SEQUENCE:
;       annply
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords: 
;         COLOR=c polygon outline color (def=255). 
;           Make same as FILL for no outline. 
;         THICK=t polygon outline thickness (def=0). 
;         LINESTYLE=s polygon outline line style (def=0). 
;         FILL=f set polygon fill color (0-255, def = -1 = no fill). 
; OUTPUTS:
; COMMON BLOCKS:
;       ann_com
; NOTES:
;       Notes: One of the graphics annotation tools. 
;         Results of these tools may be saved, recalled, 
;         and repeated later. 
;         Do annhlp for more info on the annotate tools. 
; MODIFICATION HISTORY:
;-
 

	pro annply, help=hlp, color=color, thick=thick,$
	  linestyle=linestyle, fill=fill
 
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
	print,' Interactively draw polygons on screen with mouse. Annotate.'
	  print,' annply'
	  print,'   Left button - draw side.'
	  print,'   Middle button - delete side.'
	  print,'   Right button - quit polygon draw.'
	  print,' Keywords:'
	  print,'   COLOR=c polygon outline color (def=255).'
	  print,'     Make same as FILL for no outline.'
	  print,'   THICK=t polygon outline thickness (def=0).'
	  print,'   LINESTYLE=s polygon outline line style (def=0).'
	  print,'   FILL=f set polygon fill color (0-255, def = -1 = no fill).'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.'
	  print,'   Do annhlp for more info on the annotate tools.'
	  return
	endif
 
	;---------  Make sure parameters set  ---------
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(fill) eq 0 then fill = -1
	if n_elements(thick) eq 0 then thick = !p.thick
	if n_elements(linestyle) eq 0 then linestyle = !p.linestyle
	if n_elements(x) eq 0 then annres		; Reset memory arrays.
 
loop:	drawpoly, xp, yp, /norm, linestyle=linestyle, thick=thick, $
	  color=color, fill=fill
 
	if n_elements(xp) lt 2 then return	; Quit.
 
	pfx = [pfx,xp]			; Save perm patch in memory.
	pfy = [pfy,yp]
	p = fix(xp*0+1)
	p(0) = 0
	pfpen = [pfpen, p]
	pfclr = [pfclr, color]
	pffc = [pffc, fill]
	pfsty = [pfsty, linestyle]
	pfthk = [pfthk, thick]
	print,' Polygon added to memory.'
 
	goto, loop
 
	end

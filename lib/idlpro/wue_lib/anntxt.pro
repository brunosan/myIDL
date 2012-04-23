;+
; NAME:
;       ANNTXT
; PURPOSE:
;       Interactively position text on the screen with mouse. Annotate.
; CATEGORY:
; CALLING SEQUENCE:
;       anntxt, txt
; INPUTS:
;       txt = text string to write.              in 
;       Left button - write temporary text.
;       Middle button - write permanent text.
;       Right button - quit. 
; KEYWORD PARAMETERS:
;       Keywords: 
;         COLOR=c set text color (0-255). 
;         SIZE=s set text size (def = 1). 
;         THICK=t = set text thickness (def=1). 
;         ORIENTATION=ang set text angle in degrees (def=0). 
; OUTPUTS:
; COMMON BLOCKS:
;       ann_com
; NOTES:
;       Notes: One of the graphics annotation tools. 
;         Results of these tools may be saved, recalled, 
;         and repeated later. 
;         Do annhlp for more info on the annotate tools. 
;         Normalized coordinates of permanent text listed as (x,y). 
;         May specify font in text string, ex: "!17Text". 
;         If fonts are to be mixed specify default as !3: "!3Text". 
; MODIFICATION HISTORY:
;       R. Sterner, 21 Sep, 1990
;-
 
	pro anntxt, txtin, help=hlp, color=color, size=size, $
	  orientation=orient, thick=thick
 
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
	  print,' Interactively position text on screen with mouse. Annotate.'
	  print,' anntxt, txt'
	  print,'   txt = text string to write.              in'
	  print,'   Left button - write temporary text.'
	  print,'   Middle button - write permanent text.'
	  print,'   Right button - quit.'
	  print,' Keywords:'
	  print,'   COLOR=c set text color (0-255).'
	  print,'   SIZE=s set text size (def = 1).'
	  print,'   THICK=t = set text thickness (def=1).'
	  print,'   ORIENTATION=ang set text angle in degrees (def=0).'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.'
	  print,'   Do annhlp for more info on the annotate tools.'
	  print,'   Normalized coordinates of permanent text listed as (x,y).'
	  print,'   May specify font in text string, ex: "!17Text".'
	  print,'   If fonts are to be mixed specify default as !3: "!3Text".'
	  return
	endif
 
	;---------  Make sure parameters set  ---------
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(size) eq 0 then size = 1.0
	if n_elements(thick) eq 0 then thick = 1.0
	if n_elements(orient) eq 0 then orient = 0.
	if n_elements(x) eq 0 then annres		; Reset memory arrays.
	xl = -1
	m = 0
	onechar = float(!d.x_ch_size)/(!d.x_size)	; Size of one char.
 
	if n_params(0) lt 1 then begin
	  txtin = ''
	  read,' Enter text: ',txtin
	  if txtin eq '' then return
	endif
 
	print,' '
	print,' Use mouse to position text.'
	print,' Left button - position text.'
	print,' Middle button - write text.'
	print,' Right button - quit.'
	print,' '
 
loop:	cursor, x0, y0, 1, /norm
	wait, .2
 
	;-------  Temporary text  --------------------
	if !err eq 1 then begin
	  device, set_graphics=6	; Set XOR.
	  if xl ge 0 then begin		; Erase old temp text.
	    xyouts, xl,yl,txtin,size=size,color=color,orient=orient,/norm
	  endif
	  xyouts, x0, y0,txtin,size=size,color=color,orient=orient,/norm
	  xl = x0
	  yl = y0
	  device, set_graphics=3	; Set CPY.
	endif
 
	;-------  Permanent text  ---------------
	if !err eq 2 then begin
	  if xl ge 0 then begin
	    device, set_graphics=6		; Set XOR and erase temp text.
	    xyouts, xl, yl,txtin,size=size,color=color,orient=orient,/norm
	    device, set_graphics=3		; Set CPY.
	  endif
	  xyouts, x0, y0,txtin,size=size,color=color,orient=orient,$
	    charthick=thick,/norm
	  ntxt = ntxt + 1		; Add text to memory.
	  tx = [tx,x0]
	  ty = [ty,y0]
	  tc = [tc,color]
	  ts = [ts,size]
	  ta = [ta,orient]
	  tt = [tt,thick]
	  txt = [txt,txtin]
	  print,' Text added to memory.  ('+strtrim(x0,2)+', '+$
	    strtrim(y0,2)+')'
	  xl = -1
	endif
 
	;--------  Quit  -----------
	if !err eq 4 then begin
	  if xl ge 0 then begin
	    device, set_graphics=6	; Set XOR and erase old temp text.
	    xyouts, xl, yl,txtin,size=size,color=color,orient=orient,/norm
	    device, set_graphics=3	; Set CPY.
	  endif
	  return
	endif
 
	goto, loop
 
	end

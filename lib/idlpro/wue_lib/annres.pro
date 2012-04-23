;+
; NAME:
;       ANNRES
; PURPOSE:
;       Reset annotate tools memory arrays.
; CATEGORY:
; CALLING SEQUENCE:
;       annres
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       ann_com
; NOTES:
;       Notes: One of the graphics annotation tools. 
;         Results of these tools may be saved, recalled, 
;         and repeated later.  See other ann* routines. 
; MODIFICATION HISTORY:
;       R. Sterner, 21 Sep, 1990
;-
 
	pro annres, help=hlp
 
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
	  print,' Reset annotate tools memory arrays.'
	  print,' annres'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.  See other ann* routines.'
	  return
	endif
 
	x = fltarr(1)
	y = fltarr(1)
	pen = intarr(1)
	clr = intarr(1)
	sty = intarr(1)
	thk = fltarr(1)
	ntxt = 0
	tx = fltarr(1)
	ty = fltarr(1)
	tc = intarr(1)
	ts = fltarr(1)
	ta = fltarr(1)
	tt = fltarr(1)
	txt = strarr(1)
	onechar = 1.
	pfx = fltarr(1)
	pfy = fltarr(1)
	pfpen = intarr(1)
	pfclr = intarr(1)
	pfthk = fltarr(1)
	pfsty = intarr(1)
	pffc = intarr(1)
	print,' Annotate tools memory cleared.'
	return
	 
	end

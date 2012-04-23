;+
; NAME:
;       ANNPUT
; PURPOSE:
;       Put annotate tools memory arrays into a file.
; CATEGORY:
; CALLING SEQUENCE:
;       annput, file
; INPUTS:
;       file = name of file in which to put annotation memory arrays.  in 
; KEYWORD PARAMETERS:
;	/XDR use XDR format.
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
 
	pro annput, file, help=hlp, xdr=xdr
 
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
	  print,' Put annotate tools memory arrays into a file.'
	  print,' annput, file'
	  print,'   file = file for annotation memory arrays.    in'
	  print,' Keywords:'
	  print,'   /XDR use XDR format.'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.  See other ann* routines.'
	  return
	endif
 
	if n_params(0) lt 1 then begin
	  file = ''
	  read, ' File for annotation memory arrays: ',file
	  if file eq '' then return
	endif

	save2, file, x, y, pen, clr, sty, thk, ntxt, tx, ty, /more, xdr=xdr
	save2, file, tc, ts, ta, tt, txt, onechar, /more, xdr=xdr
	save2, file, pfx, pfy, pfpen, pfclr, pfthk, pfsty, pffc, xdr=xdr
	print,' Annotate tools memory saved.'
	return
	 
	end

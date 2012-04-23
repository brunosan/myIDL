;+
; NAME:
;       ANNGET
; PURPOSE:
;       Get annotate tools memory arrays from a file.
; CATEGORY:
; CALLING SEQUENCE:
;       annget, file
; INPUTS:
;       file = name of file from which to get annotation memory arrays.  in 
; KEYWORD PARAMETERS:
;	/XDR uses XDR format.
; OUTPUTS:
; COMMON BLOCKS:
;       ann_com
; NOTES:
;       Notes: One of the graphics annotation tools. 
;         Results of these tools may be saved, recalled, 
;         and repeated later.  See other ann* routines. 
;         After annget use annexe to plot memory arrays. 
; MODIFICATION HISTORY:
;       R. Sterner, 21 Sep, 1990
;-
 
	pro annget, file, help=hlp, xdr=xdr
 
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
	  print,' Get annotate tools memory arrays from a file.'
	  print,' annget, file'
	  print,'   file = file with annotation memory arrays.     in'
	  print,' Keywords:'
	  print,'   /XDR uses XDR format.'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.  See other ann* routines.'
	  print,'   After annget use annexe to plot memory arrays.'
	  return
	endif
 
	if n_params(0) lt 1 then begin
	  file = ''
	  read,' Enter file with annotation memory arrays: ',file
	  if file eq '' then return
	endif
 
	restore2, file, x, y, pen, clr, sty, thk, ntxt, tx, ty, /more, xdr=xdr
	restore2, file, tc, ts, ta, tt, txt, onechar, /more, xdr=xdr
	restore2, file, pfx, pfy, pfpen, pfclr, pfthk, pfsty, pffc, xdr=xdr
	print,' Annotate tools memory recalled.'
	return
	 
	end

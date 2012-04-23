;+
; NAME:
;       ANNEXE
; PURPOSE:
;       Execute annotate tool commands from memory or a file.
; CATEGORY:
; CALLING SEQUENCE:
;       annexe, [file]
; INPUTS:
;       file = name of file with annotate commands.    in 
;         If no file given then commands in memory, if any, are used. 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /LAST use last plot area (instead of next). 
;         /REVERSE reverse the normal colors used.
;         XSCALE=s sets the ratio of the x size to the y size (def=1.4). 
;           Ex: use xscale=1 to annotate square images. 
;         /DEBUG does a debug stop to examine common.  Do .con to continue. 
;	  /XDR use XDR format.
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
 
	pro annexe, file, help=hlp, reverse=reverse, $
	  last=last, debug=debug, xscale=xscale, xdr=xdr
 
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
	  print,' Execute annotate tool commands from memory or a file.'
	  print,' annexe, [file]'
	  print,'   file = name of file with annotate commands.    in'
	  print,'     If no file given then commands in memory, any, are used.'
	  print,' Keywords:'
	  print,'   /LAST use last plot area (instead of next).'
	  print,'   /REVERSE reverse the normal colors used.'
	  print,'   XSCALE=s ratio of the x size to the y size (def=1.4).'
	  print,'     Ex: use xscale=1 to annotate square images.'
	  print,'   /DEBUG debug stop to examine common.  Do .con to continue.'
	  print,'   /XDR use XDR format.'
	  print,' Notes: One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.'
	  print,'   Do annhlp for more info on the annotate tools.'
	  return
	endif


	rflag = 0				    ; Set reverse flag.
	if !d.name eq 'PS' then rflag=1-rflag       ; Rev for PostScript.
	if keyword_set(reverse) then rflag=1-rflag  ; Rev for REVERSE keyword.
 
	if not keyword_set(last) then last=0
	if n_elements(xscale) eq 0 then xscale = 1.4  ; Set default xscale.
	xfact = xscale/1.4		; Multiply all X ccordinates by this.
 
	if n_params(0) gt 0 then annget, file, xdr=xdr
 
	nx = (n_elements(x) - 1)>0			; Number of points.
	npf = (n_elements(pfx) - 1)>0			; Number of polyfills.
 
	if (nx+npf+ntxt) eq 0 then begin
	  print,' Annotation memory clear, nothing to execute.'
	endif else begin
	  print,' Executing annotation memory.'
	endelse
 
	if keyword_set(debug) then begin
print,'	; Annotation tool common: --------------------------------------------
print,'	; Lines: x,y = arrays of x,y coordinates.  Pen = pen code.           |
print,' ;        clr = line color, sty = line style, thk = line thickness.   |
print,' ; Text:  tx,ty = text position.  tc,ts,ta = text color, size, angle. |
print,' ;        tt = thickness.  txt = text strings.  ntxt = # text strings.|
print,' ;        onechar = norm. size of 1 char on original device.          |
print,' ; Polyfill: pfx,pfy = polyfill points, pfpen = polyfill pen code,    |
print,' ;        pfclr,pfthk,pfsty = polyfill outline color, thick, style,   |
print,' ;        pffc = polyfill fill color.                                 |
print,' ;---------------------------------------------------------------------
	  stop
	  return
	endif 
 
	;--------  Do polyfills -----------
	if n_elements(pfx) gt 1 then begin
	  ;-----  Find breaks in curve  -------
	  p2 = pfpen(1:*)		; Copy polyfill pencode array.
	  p2(0) = 0			; Force first value to 0.
	  w0 = where([p2,0] eq 0)+1	; Find all 0s, (offset over first).
	  nw0 = n_elements(w0)
	  ;-----  Loop through connected sets ---------
	  for i = 0, nw0-2 do begin
	    xx = xfact*(pfx(w0(i):(w0(i+1)-1)))	; Extract connected set.
	    yy = pfy(w0(i):(w0(i+1)-1))
	    fc = pffc(i+1)
	    c = pfclr(i+1)
	    s = pfsty(i+1)
	    t = pfthk(i+1)
	    if rflag then begin
	      c = !d.n_colors - 1 - c
	      if fc ne -1 then fc = !d.n_colors - 1 - fc
	    endif
	    subnormal, xx, yy, xx2, yy2, last=last
	    xx = xx2  & yy = yy2
	    if fc ne -1 then polyfill, /norm, xx, yy, color=fc
	    plots, /norm, [xx,xx(0)],[yy,yy(0)],color=c, thick=t,linestyle=s
	  endfor
	endif
 
	;--------  Do lines  ------------
	if n_elements(x) gt 1 then begin
	  ;-----  Find breaks in curve  -------
	  p2 = pen(1:*)			; Copy pencode array (ignore first).
	  p2(0) = 0			; Force first value to 0.
	  w0 = where([p2,0] eq 0)+1	; Find all 0s, (offset over first).
	  nw0 = n_elements(w0)
	  ;-----  Loop through connected sets ---------
	  for i = 0, nw0-2 do begin
	    xx = xfact*(x(w0(i):(w0(i+1)-1)))	; Extract connected set.
	    yy = y(w0(i):(w0(i+1)-1))
	    subnormal, xx, yy, xx2, yy2, last=last
	    xx = xx2  & yy = yy2
	    c = clr(i+1)
	    if rflag then c = !d.n_colors - 1 - c
	    s = sty(i+1)
	    t = thk(i+1)
	    plots, xx, yy, /normal, color=c, linestyle=s, thick=t
	  endfor
	endif
 
	;--------  Do text  -------------
	if n_elements(ntxt) eq 0 then ntxt = 0
	if ntxt gt 0 then begin
	  onechar_2 = float(!d.x_ch_size)/(!d.x_size)	; Curr norm char size.
	  txtfact = onechar/onechar_2			; Size change factor.
	  for i = 1, ntxt do begin
	    c = tc(i)
	    if rflag then c = !d.n_colors - 1 - c
	    xx = xfact*tx(i)
	    yy = ty(i)
	    ; Scale by # plots in x, and size change fact.
	    ss = ts(i)/(float(!p.multi(1)>1))*txtfact
	    ss = xfact*ss			; Must also scale by xfactor.
	    subnormal, xx, yy, xx2, yy2, last=last
	    xx = xx2  & yy = yy2
	    xyouts, /norm, xx, yy, txt(i), color=c, size=ss, $
	      orient=ta(i), charthick=tt(i)
	  endfor
	endif
 
	end

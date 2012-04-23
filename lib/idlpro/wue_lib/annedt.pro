;+
; NAME:
;       ANNEDT
; PURPOSE:
;       Edit annotate tool commands in memory or a file.
; CATEGORY:
; CALLING SEQUENCE:
;       annedt, [file]
; INPUTS:
;       file = name of file with annotate commands.    in 
;         If no file given then commands in memory, if any, are used. 
;         Edit results are left in memory and may be saved with annput. 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       ann_com
; NOTES:
;       Notes: Allows the display and removal of any of the items in memory. 
;         One of the graphics annotation tools. 
;         Results of these tools may be saved, recalled, 
;         and repeated later. 
;         Do annhlp for more info on the annotate tools. 
; MODIFICATION HISTORY:
;	R. Sterner, 24 Oct, 1990
;-
 
	pro annedt, file, help=hlp
 
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
	  print,' Edit annotate tool commands in memory or a file.'
	  print,' annedt, [file]'
	  print,'   file = name of file with annotate commands.    in'
	  print,'     If no file given then commands in memory, are used.'
	  print,'     Edit results left in memory. May be saved with annput.'
	  print,' Notes: Allows display and removal of any items in memory.'
	  print,'   One of the graphics annotation tools.'
	  print,'   Results of these tools may be saved, recalled,'
	  print,'   and repeated later.'
	  print,'   Do annhlp for more info on the annotate tools.'
	  return
	endif
 
 
	if n_params(0) gt 0 then annget, file
 
	nx = (n_elements(x) - 1)>0	; Number of points.
	npf = (n_elements(pfx) - 1)>0	; Number of polyfills.
	nt = (n_elements(txt) - 1)>0	; Number of text strings.
 
        if n_elements(xscale) eq 0 then xscale = 1.4    ; Set default xscale.
        xfact = xscale/1.4              ; Multiply all X ccordinates by this.
 
	if (nx+npf+nt) eq 0 then begin
	  print,' Annotation memory clear, nothing to edit.'
	  return
	endif else begin
	  print,' Editing annotation memory.'
	endelse
 
	;--------  Put red at ct top  ----------
	tvlct, r0, g0, b0, /get
	r=r0 & g=g0 & b=b0
	lstclr = !d.n_colors - 1
	r(lstclr) = 255
	g(lstclr) = 0
	b(lstclr) = 0
	tvlct, r, g, b
 
	print,' '
	print,' Display and/or remove items in annotation memory.'
	print,' '
	print,' There are three types of items:'
	print,'   Curves - includes line segments,'
	print,'   Polygons - includes, boxes, circles, and arrows,'
	print,'   Text strings.'
 
loop:	print,' '
	;-----  Curves: find individual items  -------
	nc = 0
	txtc = 's'
	if n_elements(pen) gt 1 then begin
	  p = pen(1:*)		   ; Copy pencode array (ignore first).
	  p(0) = 0		   ; Force first value to 0.
	  wc = where([p,0] eq 0)+1 ; Find 0s, (offset over first).
	  nc = n_elements(wc)-1
	  txtc = ''
	  if nc ne 1 then txtc = 's'
	endif
	;-----  Polygons: Find individual polygons  -------
	np = 0
	txtp = 's'
	if n_elements(pfpen) gt 1 then begin
	  p = pfpen(1:*)	; Copy polyfill pencode array (ignore first).
	  p(0) = 0		; Force first value to 0.
	  wp = where([p,0] eq 0)+1  ; Find 0s, (offset over first).
	  np = n_elements(wp)-1
	  txtp = ''
	  if np ne 1 then txtp = 's'
	endif
	;------  Text strings  ------
	nt = ntxt
	txtt = ''
	if nt ne 1 then txtt = 's'
 
	print,' '
	tmp = 'are'
	if nc eq 1 then tmp = 'is'
	print,' There '+tmp
	print,' '+strtrim(nc,2)+' Curve'+txtc+','
	print,' '+strtrim(np,2)+' Polygon'+txtp+','
	print,' '+strtrim(nt,2)+' Text string'+txtt+'.'
	print,' '
 
tloop:	ityp = ''
	print,' '
	read,' Enter item type (C,P,T): ',ityp
	if ityp eq '' then goto, done
	ityp = strlowcase(ityp)
	case ityp of
'c': 	  ityptxt = 'curve'
'p': 	  ityptxt = 'polygon'
't': 	  ityptxt = 'text string'
else:	  goto, tloop
	endcase 
 
mloop:	mode = ''
	print,' '
	read,' Enter '+ityptxt+' display (D), removal (R), or Modify (M): ',$
	  mode
	if mode eq '' then goto, tloop
	mode = strlowcase(mode)
	if mode eq 'd' then modetxt = 'display'
	if mode eq 'r' then modetxt = 'removal'
 
	tmp = ''
	if mode eq 'd' then begin
	  read,' Enter '+ityptxt+' '+modetxt+$
	    ' indices to use (index or lo,hi, def=all): ',tmp
	  if tmp eq '' then tmp = '0,9999'
	endif
	if mode eq 'r' then begin
	  read,' Enter '+ityptxt+' '+modetxt+$
	    ' indices to use (index or lo,hi, def=none): ',tmp
	  if tmp eq '' then goto, mloop
	endif
	tmp = repchr(tmp,',')
	lo = getwrd(tmp) + 0
	hi = getwrd(tmp,/last) + 0
 
	;======  DISPLAY mode  ============
	if mode eq 'd' then begin 
 
	;------  Polygons  -------
	if ityp eq 'p' then begin
	erase
	if n_elements(pfx) gt 1 then begin
	  ;-----  Loop through connected sets ---------
	  for i = lo>0, hi<(np-1) do begin
	    xx = xfact*(pfx(wp(i):(wp(i+1)-1)))	; Extract connected set.
	    yy = pfy(wp(i):(wp(i+1)-1))
	    fc = pffc(i+1)
	    c = pfclr(i+1)
	    s = pfsty(i+1)
	    t = pfthk(i+1)
	    if keyword_set(reverse) then begin
	      c = !d.n_colors - 1 - c
	      if fc ne -1 then fc = !d.n_colors - 1 - fc
	    endif
	    subnormal, xx, yy, xx2, yy2, last=last
	    xx = xx2  & yy = yy2
	    if fc ne -1 then polyfill, /norm, xx, yy, color=fc<(lstclr-2)
	    plots, /norm, [xx,xx(0)],[yy,yy(0)],color=c<(lstclr-2), $
	      thick=t, linestyle=s
	    xyouts,/norm,mean(xx),mean(yy),strtrim(i,2),color=lstclr,$
	      align=.5, size=2
	  endfor
	endif
	endif  ; ityp eq 'p'
 
	;--------  Do curves ------------
	if ityp eq 'c' then begin
	erase
	if n_elements(x) gt 1 then begin
	  ;-----  Loop through connected sets ---------
	  for i = lo>0, hi<(nc-1) do begin
	    xx = xfact*(x(wc(i):(wc(i+1)-1)))	; Extract connected set.
	    yy = y(wc(i):(wc(i+1)-1))
	    subnormal, xx, yy, xx2, yy2, last=last
	    xx = xx2  & yy = yy2
	    c = clr(i+1)
	    if keyword_set(reverse) then c = !d.n_colors - 1 - c
	    s = sty(i+1)
	    t = thk(i+1)
	    plots, xx, yy, /normal, color=c<(lstclr-2), linestyle=s, thick=t
	    xyouts,/norm,xx(0),yy(0),strtrim(i,2),color=lstclr,align=.5,size=2
	  endfor
	endif
	endif  ; ityp eq 'c'
 
	;--------  Do text  -------------
	if ityp eq 't' then begin
	if n_elements(ntxt) eq 0 then ntxt = 0
	erase
	if ntxt gt 0 then begin
	  onechar_2 = float(!d.x_ch_size)/(!d.x_size)	; Cur norm char size.
	  txtfact = onechar/onechar_2			; Size change factor.
	  for i = 1, ntxt do begin
	    c = tc(i)
	    if keyword_set(reverse) then c = !d.n_colors - 1 - c
	    xx = xfact*tx(i)
	    yy = ty(i)
	    ;--- Scale by # plots in x, and size change fact.
	    ss = ts(i)/(float(!p.multi(1)>1))*txtfact	
	    ss = xfact*ss			; Must also scale by xfactor.
	    subnormal, xx, yy, xx2, yy2, last=last
	    xx = xx2  & yy = yy2
	    xyouts, /norm, xx, yy, txt(i), color=c<(lstclr-2), size=ss, $
	      orient=ta(i), charthick=tt(i)
	    xyouts,/norm,xx,yy,strtrim(i,2),color=lstclr,$
	      size=2, align=1.5, orient=ta(i)
	  endfor
	endif
	endif  ; if ityp eq 't'
 
	endif  ; if mode eq 'd'
	;=========  END DISPLAY  ==============
 
 
	;======  REMOVE mode  ============
	if mode eq 'r' then begin 
	  print,' '
	  print,' Removing '+ityptxt+'s . . .'
 
	;------  Polygons  -------
	if ityp eq 'p' then begin
	if n_elements(pfx) gt 1 then begin
	  ;-----  Loop through connected sets ---------
          qpfx = fltarr(1)
          qpfy = fltarr(1)
          qpfpen = intarr(1)
          qpfclr = intarr(1)
          qpfthk = fltarr(1)
          qpfsty = intarr(1)
          qpffc = intarr(1)
	  for i = 0, lo-1 do begin
	    qpfx = [qpfx, pfx(wp(i):(wp(i+1)-1))]  ; Extract connected set.
	    qpfy = [qpfy, pfy(wp(i):(wp(i+1)-1))]
	    qpfpen = [qpfpen, pfpen(wp(i):(wp(i+1)-1))]
	    qpffc = [qpffc, pffc(i+1)]
	    qpfclr = [qpfclr, pfclr(i+1)]
	    qpfsty = [qpfsty, pfsty(i+1)]
	    qpfthk = [qpfthk, pfthk(i+1)]
	  endfor
	  for i = hi+1, np-1 do begin
	    qpfx = [qpfx, pfx(wp(i):(wp(i+1)-1))]  ; Extract connected set.
	    qpfy = [qpfy, pfy(wp(i):(wp(i+1)-1))]
	    qpfpen = [qpfpen, pfpen(wp(i):(wp(i+1)-1))]
	    qpffc = [qpffc, pffc(i+1)]
	    qpfclr = [qpfclr, pfclr(i+1)]
	    qpfsty = [qpfsty, pfsty(i+1)]
	    qpfthk = [qpfthk, pfthk(i+1)]
	  endfor
          pfx = qpfx 
          pfy = qpfy 
          pfpen = qpfpen 
          pfclr = qpfclr 
          pfthk = qpfthk 
          pfsty = qpfsty 
          pffc = qpffc 
	endif
	endif  ; ityp eq 'p'
 
	;--------  Do curves ------------
	if ityp eq 'c' then begin
	if n_elements(x) gt 1 then begin
	  ;-----  Loop through connected sets ---------
          qx = fltarr(1)
          qy = fltarr(1)
          qpen = intarr(1)
          qclr = intarr(1)
          qsty = intarr(1)
          qthk = fltarr(1)
	  for i = 0, lo-1 do begin
	    qx = [qx, x(wc(i):(wc(i+1)-1))]	; Extract connected set.
	    qy = [qy, y(wc(i):(wc(i+1)-1))]
	    qpen = [qpen, pen(wc(i):(wc(i+1)-1))]
	    qclr = [qclr, clr(i+1)]
	    qsty = [qsty, sty(i+1)]
	    qthk = [qthk, thk(i+1)]
	  endfor
	  for i = hi+1, nc-1 do begin
	    qx = [qx, x(wc(i):(wc(i+1)-1))]	; Extract connected set.
	    qy = [qy, y(wc(i):(wc(i+1)-1))]
	    qpen = [qpen, pen(wc(i):(wc(i+1)-1))]
	    qclr = [qclr, clr(i+1)]
	    qsty = [qsty, sty(i+1)]
	    qthk = [qthk, thk(i+1)]
	  endfor
          x = qx
          y = qy
          pen = qpen
          clr = qclr
          sty = qsty
          thk = qthk
	endif
	endif  ; ityp eq 'c'
 
	;--------  Do text  -------------
	if ityp eq 't' then begin
	if n_elements(ntxt) eq 0 then ntxt = 0
	if ntxt gt 0 then begin
	  qtx = fltarr(1)
	  qty = fltarr(1)
	  qtc = intarr(1)
	  qts = fltarr(1)
	  qta = fltarr(1)
	  qtt = fltarr(1)
	  qtxt = strarr(1)
	  for i = 1, lo-1 do begin
	    qtx = [qtx, tx(i)]
	    qty = [qty, ty(i)]
	    qtc = [qtc, tc(i)]
	    qts = [qts, ts(i)]
	    qta = [qta, ta(i)]
	    qtt = [qtt, tt(i)]
	    qtxt = [qtxt, txt(i)]
	  endfor
	  for i = hi+1, ntxt do begin
	    qtx = [qtx, tx(i)]
	    qty = [qty, ty(i)]
	    qtc = [qtc, tc(i)]
	    qts = [qts, ts(i)]
	    qta = [qta, ta(i)]
	    qtt = [qtt, tt(i)]
	    qtxt = [qtxt, txt(i)]
	  endfor
	  tx = qtx 
	  ty = qty 
	  tc = qtc 
	  ts = qts 
	  ta = qta 
	  tt = qtt 
	  txt = qtxt 
	  ntxt = n_elements(txt)-1
	endif
	endif  ; if ityp eq 't'
 
	endif  ; if mode eq 'r'
	;=========  END REMOVE ==============

	;======  MODIFY mode  ============
	if mode eq 'm' then begin 
	  print,' '
	  print,' Modifying '+ityptxt+'s . . .'
 
	;------  Polygons  -------
	if ityp eq 'p' then begin
	if n_elements(pfx) gt 1 then begin
mpd:	  print,' Polygon       Color   Linestyle        Thick    Fill'
	  for i = 1, np do begin
	    print,i,pfclr(i),pfsty(i), pfthk(i), pffc(i)
	  endfor
	tmp = ''
mpi:	read,' Enter index range to modifiy (RETURN when done): ',tmp
	if tmp eq '' then goto, loop
	tmp = repchr(tmp,',')
	lo = getwrd(tmp) + 0
	hi = getwrd(tmp,/last)+0
mpp:	tmp2 = ''
	read,' Enter first letter of parameter to modifiy: ',tmp2
	if tmp2 eq '' then goto, mpi
	tmp2 = strlowcase(tmp2)
	case tmp2 of
'c':	  mtxt = 'color'
'l':	  mtxt = 'linestyle'
't':	  mtxt = 'thickness'
'f':	  mtxt = 'fill color'
else:	  goto, mpp
	endcase
mpv:	val = ''
	read,' Enter new value for '+mtxt+': ',val
	if val eq '' then goto, mpi
	if not isnumber(val) then goto, mpv
	for i = lo>1, hi<np do begin
	case tmp2 of
'c':	  pfclr(i) = val + 0
'l':	  pfsty(i) = val + 0
't':	  pfthk(i) = val + 0.
'f':	  pffc(i)  = val + 0
else:	  
	endcase
	endfor
	goto, mpd
	endif  ; n_elements ...
	endif  ; ityp eq 'p'
 
	;--------  Do curves ------------
	if ityp eq 'c' then begin
	if n_elements(x) gt 1 then begin
mcd:	  print,'   Curve       Color   Linestyle        Thick'
	  for i = 1, nc do begin
	    print,i,clr(i),sty(i),thk(i)
	  endfor
        tmp = ''
mci:    read,' Enter index range to modifiy (RETURN when done): ',tmp
        if tmp eq '' then goto, loop
        tmp = repchr(tmp,',')
        lo = getwrd(tmp) + 0
        hi = getwrd(tmp,/last)+0
mcp:    tmp2 = ''
        read,' Enter first letter of parameter to modifiy: ',tmp2
        if tmp2 eq '' then goto, mci
        tmp2 = strlowcase(tmp2)
        case tmp2 of
'c':      mtxt = 'color'
'l':      mtxt = 'linestyle'
't':      mtxt = 'thickness'
else:     goto, mcp
        endcase
mcv:    val = ''
        read,' Enter new value for '+mtxt+': ',val
        if val eq '' then goto, mci
        if not isnumber(val) then goto, mcv
        for i = lo>1, hi<nc do begin
        case tmp2 of
'c':      clr(i) = val + 0
'l':      sty(i) = val + 0
't':      thk(i) = val + 0.
else:
        endcase
        endfor
        goto, mcd
	endif
	endif  ; ityp eq 'c'
 
	;--------  Do text  -------------
	if ityp eq 't' then begin
	if n_elements(ntxt) eq 0 then ntxt = 0
	if ntxt gt 0 then begin
mtd:	  print,'    Text       Color         Size        Angle'+$
	    '        Thick   String'
	  for i = 1, ntxt do begin
	    print,i,tc(i),ts(i),ta(i),tt(i),'   ',txt(i)
	  endfor
        tmp = ''
mti:    read,' Enter index range to modifiy (RETURN when done): ',tmp
        if tmp eq '' then goto, loop
        tmp = repchr(tmp,',')
        lo = getwrd(tmp) + 0
        hi = getwrd(tmp,/last)+0
mtp:    tmp2 = ''
        read,' Enter first letter of parameter to modifiy: ',tmp2
        if tmp2 eq '' then goto, mti
        tmp2 = strlowcase(tmp2)
        case tmp2 of
'c':      mtxt = 'color'
's':      mtxt = 'character size'
'a':      mtxt = 'angle'
't':      mtxt = 'thickness'
else:     goto, mtp
        endcase
mtv:    val = ''
        read,' Enter new value for '+mtxt+': ',val
        if val eq '' then goto, mti
        if not isnumber(val) then goto, mtv
        for i = lo>1, hi<ntxt do begin
        case tmp2 of
'c':      tc(i) = val + 0
's':      ts(i) = val + 0.
'a':      ta(i) = val + 0.
't':      tt(i) = val + 0.
else:
        endcase
        endfor
        goto, mtd
	endif  ; n_elements ...
	endif  ; if ityp eq 't'
 
	endif  ; if mode eq 'm'
	;=========  END MODIFY  ==============
 
	goto, loop
 
	;--------  Done  --------
done:	tvlct, r0, g0, b0
	return
 
 
	end

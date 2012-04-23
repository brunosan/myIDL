;+
; NAME:
;       BAR
; PURPOSE:
;       Put an interactive color bar on the image display.
; CATEGORY:
; CALLING SEQUENCE:
;       bar
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords: 
;         /AGAIN repeats last bar without prompts. 
;         LAYOUT=txtarr  Complete bar layout contained in 
;           a string array. Plots specified color bar. 
;         /DESCRIPTION list a description of the LAYOUT array. 
;         GETLAYOUT=txtarr  Returns a layout array for the last 
;           color bar plotted. 
; OUTPUTS:
; COMMON BLOCKS:
;       bar_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 18 Apr, 1990
;-
 
	pro bar, help=hlp, again=rpt, layout=lay, description=desc,$
	  getlayout=getlay
 
	common bar_com, dx,dy,glo,ghi,x,y,x2,y2,title,lo,hi,step,$
	  dv,vlo,fmt,lsz,tsz,lclr,tclr
 
	if keyword_set(hlp) then begin
	  print,' Put an interactive color bar on the image display.'
	  print,' bar'
	  print,'   All values prompted for.'
	  print,' Keywords:'
	  print,'   /AGAIN repeats last bar without prompts.'
	  print,'   LAYOUT=txtarr  Complete bar layout contained in'
	  print,'     a string array. Plots specified color bar.'
	  print,'   /DESCRIPTION list a description of the LAYOUT array.'
	  print,'   GETLAYOUT=txtarr  Returns a layout array for the last'
	  print,'     color bar plotted.'
	  return
	endif
 
	;---------  LAYOUT description  ----------
	if keyword_set(desc) then begin
	  print,' Plot specified color bar.'
	  print,' bar, layout=txt'
	  print,'   txt = a string array defining color bar.   in'
	  print,' Array index   Name    Contents'
	  print,'      0         x1     Device X for bar lower left corner'
	  print,'      1         y1     Device Y for bar lower left corner'
	  print,'      2         x2     Device X for bar upper right corner'
	  print,'      3         y2     Device Y for bar upper right corner'
	  print,'      4         glo    Bar low gray value'
	  print,'      5         ghi    Bar high gray value'
	  print,'      6         plo    Parameter low value'
	  print,'      7         phi    Parameter high value'
	  print,'      8         llo    Label low value'
	  print,'      9         lhi    Label high value'
	  print,'     10         lst    Label increment step'
	  print,'     11         fmt    Label format string'
	  print,'     12         ttl    Bar title'
	  print,'     13         tsz    Title character size'
	  print,'     14         lsz    Labels character size'
	  print,'     15         tclr   Title color'
	  print,'     16         lclr   Labels color'
	  print,' '
	  print,' Try creating a color bar interactively if above is unclear.'
	  return
	endif
 
	;----------  AGAIN  -----------
	if keyword_set(rpt) then begin
	  if n_elements(dx) eq 0 then begin
	    print,' Error in bar: nothing to repeat.'
	    return
	  endif
	  goto, dobar
	endif
 
	;----------  LAYOUT  -------------
	if n_elements(lay) ne 0 then begin
	  x = lay(0) + 0
	  y = lay(1) + 0
	  x2 = lay(2) + 0
	  y2 = lay(3) + 0
	  glo = lay(4) + 0
	  ghi = lay(5) + 0
	  vlo = lay(6) + 0.
	  vhi = lay(7) + 0.
	  lo = lay(8) + 0.
	  hi = lay(9) + 0.
	  step = lay(10) + 0.
	  fmt = lay(11)
	  title = lay(12)
	  tsz = lay(13) + 0.
	  lsz = lay(14) + 0.
	  tclr = lay(15) + 0
	  lclr = lay(16) + 0
	  dv = vhi - vlo
	  dx = x2 - x + 1
	  dy = y2 - y + 1
	  if strmid(fmt,0,1) ne '(' then fmt = '('+fmt+')'
	  goto, dobar
	endif
 
	;----------  INTERACTIVE  ----------
	print,' Image colors represent values of some parameter.'
loop:	txt = ''
 
 
	read,' Enter min, max parameter values for bar (def=0,255, q=quit): ',$
	  txt
	if strlowcase(txt) eq 'q' then return
	if txt eq '' then txt = '0,255'
	txt = repchr(txt,',')
	vlo = getwrd(txt,0) + 0.
	vhi = getwrd(txt,1) + 0.
	txt = ''
	read,' Enter corresponding min, max image gray values (def=0,255): ',$
	  txt
	if txt eq '' then txt = '0 255'
	txt = repchr(txt,',')
	glo = getwrd(txt,0) + 0
	ghi = getwrd(txt,1) + 0
	txt = ''
	read,' Enter number of tick marks (def is about 5): ',txt
	if txt eq '' then txt = 5
	nticks = txt + 0.
	dv = vhi - vlo				; Parameter value range.
	step = nicenumber(dv/nticks)		; Label step size.
	lo = ceil(vlo/step)*step		; First label value.
	hi = floor(vhi/step)*step		; Last label value.
	title = ''
	read,' Color bar title: ', title
	txt = ''
	read,' Title character size (def = 1): ',txt
	if txt eq '' then txt = '1.'
	tsz = txt + 0.
	txt = ''
	read,' Title color (def = 255): ',txt
	if txt eq '' then txt = '255'
	tclr = txt + 0
	print,' '
	print,' Step size is '+strtrim(step,2)
	print,' From '+strtrim(lo,2)+' to '+strtrim(hi,2)
	fmt = ''
	read,' Enter format for labels (def = i3): ',fmt
	if fmt eq '' then fmt = 'i3'
	if strmid(fmt,0,1) ne '(' then fmt = '('+fmt+')'
	txt = ''
	read,' Labels character size (def = 1): ',txt
	if txt eq '' then txt = '1.'
	lsz = txt + 0.
	txt = ''
	read,' labels color (def = 255): ',txt
	if txt eq '' then txt = '255'
	lclr = txt + 0
 
	print,' Use box to position color bar.'
	print,' Mouse buttons:'
	print,' Left: position/size,  Middle: abort,  Right: draw bar.'
	x = 100
	y = 100
	dx = 100
	dy = 100
	movbox, x, y, dx, dy, c, /noerase, /nomenu
	if c eq 2 then return
	x2 = x + dx - 1
	y2 = y + dy - 1
 
	;-----------  plot bar  ---------------
dobar:
	if dx gt dy then begin				; Horizontal bar.
	  g = maken(glo, ghi, dx)			;   1 color bar line.
	  tv, bytarr(dx+2, dy+2) + 255, x-1, y-1	;   Frame.
	  for i = y, y2 do tv, g, x, i			;   Color.
	  xyouts, x+dx/2, y2+10, /dev, align=.5, $	;   Title.
	    title, size=tsz, color=tclr
	  for vx = lo, hi, step do begin		;   Loop through tics.
	    ix = (vx - vlo)*dx/dv + x			;   Tic positions.
	    plots, [ix,ix], [y, y-5]-1, /dev		;   Plot tic.
	    txt = string(vx,format=fmt)			;   Format label.
	    txt = strtrim(txt,2)			;   Trim label.
	    xyouts, ix, y-10-9*lsz,txt,/dev,align=.5, $	;   Print label.
	      size=lsz, color=lclr
	  endfor
	endif else begin				; Vertical bar.
	  g = transpose(maken(glo, ghi, dy))
	  tv, bytarr(dx+2, dy+2) + 255, x-1, y-1
	  for i = x, x2 do tv, g, i, y
	  xyouts, x+dx/2, y2+15, /dev, align=.5, $	;   Title.
	    title, size=tsz, color=tclr
	  for vy = lo, hi, step do begin		;   Loop through tics.
	    iy = (vy - vlo)*dy/dv + y			;   Tic positions.
	    plots, [x2,x2+5]+1, [iy,iy], /dev		;   Plot tic.
	    txt = string(vy,format=fmt)			;   Format label.
	    txt = strtrim(txt,2)			;   Trim label.
	    xyouts, x2+5+5*lsz, iy-3*lsz, txt, /dev, $	;   Print label.
	      size=lsz, color=lclr
	  endfor
	endelse
 
	getlay = strarr(17)
	getlay(0) = [x,y,x+dx-1,y+dy-1,glo,ghi,vlo,vlo+dv]
	getlay(8) = lo
	getlay(9) = hi
	getlay(10) = step
	getlay(11) = fmt
	getlay(12) = title
	getlay(13) = [tsz,lsz,tclr,lclr]
 
	return
 
	end

;+
; NAME:
;       IMGARROW
; PURPOSE:
;       Draw arrows on image using mouse.
; CATEGORY:
; CALLING SEQUENCE:
;       imgarrow, clr
; INPUTS:
;       clr = arrow color.     in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         LENGTH=l.  Arrow head length in pixels (def = 10). 
;         WIDTH=w.  Arrow head width in pixels (def = 5). 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: use button 1 to draw arrows, button 2 to draw them. 
;         Thick arrows may be plotted by setting !p.thick. 
;         !p.linestyle does not work very well with imgarrow. 
; MODIFICATION HISTORY:
;       R. Sterner, 25 Jan, 1990
;-
 
	pro imgarrow, clr, length=alen, width=awid, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Draw arrows on image using mouse.'
	  print,' imgarrow, clr'
	  print,'   clr = arrow color.     in'
	  print,' Keywords:'
	  print,'   LENGTH=l.  Arrow head length in pixels (def = 10).'
	  print,'   WIDTH=w.  Arrow head width in pixels (def = 5).'
	  print,' Note: use button 1 to draw arrows, button 2 to draw them.'
	  print,'   Thick arrows may be plotted by setting !p.thick.'
	  print,'   !p.linestyle does not work very well with imgarrow.'
	  return
	endif
 
	if n_params(0) lt 1 then clr = !p.color
	if not keyword_set(alen) then alen = 10.
	if not keyword_set(awid) then awid = 5.
	m = 0
 
	print,' Draw arrows on image.'
	print,' Use mouse button 1 to draw a temporary arrow, button 2 to draw permanent arrow.'
	print,' Buttons: 1=XOR arrow, 2=write arrow, 3=quit'
 
loop:	devcrs, x, y, z, c
 
	if c eq 'BUTTON_1' then begin
	  device, set_graphics=6
	  if m eq 2 then begin
	    plots, xh, yh, /dev
	    m = 0
	  endif
	  if m eq 0 then begin
	    x1 = x
	    y1 = y
	    plots, [x1,x1], [y1,y1], /dev
	  endif
	  if m eq 1 then begin
	    x2 = x
	    y2 = y
	    plots, [x1,x1], [y1,y1], /dev
	    dx = x2 - x1  & dy = y2 - y1
	    m1 = sqrt(dx^2 + dy^2)>.1
	    u1x = dx/m1  & u1y = dy/m1
	    u2x = -u1y  & u2y = u1x
	    x2b = x2 - alen*u1x  & y2b = y2 - alen*u1y
	    x3 = x2b + awid*u2x  & y3 = y2b + awid*u2y
	    x4 = x2b - awid*u2x  & y4 = y2b - awid*u2y
	    xh = [x1, x2b, x3, x2, x4, x2b] & yh = [y1, y2b, y3, y2, y4, y2b]
	    plots, xh, yh, /dev
	  endif
	  m = m + 1
	endif
 
	if c eq 'BUTTON_2' then begin
	  if m eq 2 then begin
	    plots, xh, yh, /dev
	    device, set_graphics=3
	    plots, xh, yh, /dev, color=clr
	    m = 0
	  endif
	endif
 
	if c eq 'BUTTON_3' then begin
	  if m eq 2 then begin
	    plots, xh, yh, /dev
	    device, set_graphics=3
	  endif
	  return
	endif
 
	goto, loop
 
	end

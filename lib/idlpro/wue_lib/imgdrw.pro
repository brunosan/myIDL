;+
; NAME:
;       IMGDRW
; PURPOSE:
;       Draw lines on image using mouse.
; CATEGORY:
; CALLING SEQUENCE:
;       imgdrw, clr
; INPUTS:
;       clr = line color.     in 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: use button 1 to draw temporary lines, 
;         button 2 to draw permanent lines, button 3 to quit. 
;         Thick lines may be plotted by setting !p.thick. 
;         !p.linestyle does not work very well with imgdrw. 
; MODIFICATION HISTORY:
;       R. Sterner, 25 Jan, 1990
;-
 
	pro imgdrw, clr, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Draw lines on image using mouse.'
	  print,' imgdrw, clr'
	  print,'   clr = line color.     in'
	  print,' Note: use button 1 to draw temporary lines,'
	  print,'   button 2 to draw permanent lines, button 3 to quit.'
	  print,'   Thick lines may be plotted by setting !p.thick.'
	  print,'   !p.linestyle does not work very well with imgdrw.'
	  return
	endif
 
	if n_params(0) lt 1 then clr = !p.color
	m = 0
 
	print,' Draw lines on image.'
	print,' Use mouse button 1 to draw a temporary line, button 2 to draw permanent line.'
	print,' Buttons: 1=XOR line, 2=write line, 3=quit'
 
loop:	devcrs, x, y, z, c
 
	if c eq 'BUTTON_1' then begin
	  device, set_graphics=6
	  if m eq 2 then begin
	    plots, [x1, x2], [y1, y2], /dev
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
	    plots, [x1,x2], [y1,y2], /dev
	  endif
	  m = m + 1
	  device, set_graphics=3
	endif
 
	if c eq 'BUTTON_2' then begin
	  if m eq 2 then begin
	    device, set_graphics=6
	    plots, [x1, x2], [y1, y2], /dev
	    device, set_graphics=3
	    plots, [x1, x2], [y1, y2], color=clr, /dev
	    m = 0
	  endif
	endif
 
	if c eq 'BUTTON_3' then begin
	  if m eq 2 then begin
	    device, set_graphics=6
	    plots, [x1, x2], [y1, y2], /dev
	    device, set_graphics=3
	  endif
	  return
	endif
 
	goto, loop
 
	end

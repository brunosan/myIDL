;+
; NAME:
;       IMGTXT
; PURPOSE:
;       Position text on image using mouse.
; CATEGORY:
; CALLING SEQUENCE:
;       imgtxt, txt
; INPUTS:
;       txt = text string to write.          in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         SIZE=sz,   text size (def = 1). 
;         COLOR=clr, text color (def = 255). 
;         ANGLE=ang, text angle (def=0). 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: use button 1 to position text, button 2 to write it. 
;         Button 1 text is only partly visible but is useful for positioning. 
;         To select text font put font code at front of text.  Ex: imgtxt,'!17text' 
; MODIFICATION HISTORY:
;       R. Sterner, 2 Jan, 1990
;		T. Leighton, 12 Sept, 1990 - latest Sterner version
;-
 
	pro imgtxt, txt, size=sz, color=clr, angle=ang, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Position text on image using mouse.'
	  print,' imgtxt, txt'
	  print,'   txt = text string to write.          in'
	  print,' Keywords:'
	  print,'   SIZE=sz,   text size (def = 1).'
	  print,'   COLOR=clr, text color (def = 255).'
	  print,'   ANGLE=ang, text angle (def=0).'
	  print,' Note: use button 1 to position text, button 2 to write it.'
	  print,'   Button 1 text is only partly visible but is useful for positioning.'
	  print,"   To select text font put font code at front of text.  Ex: imgtxt,'!17text'"
	  print,'	This is the latest version from Sterners idl/lib directory.'
	  return
	endif
 
	if n_elements(sz) eq 0 then sz = 1.
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(ang) eq 0 then ang = 0.
	xl = -1
 
	print,' Use mouse button 1 to position text, button 2 to write it.'  
	print,' Button 1 text is only partly visible but is useful for positioning.'
	print,' Buttons: 1=XOR text, 2=write text, 3=quit'
 
loop:	devcrs, x, y, z, c
	if c eq 'BUTTON_1' then begin
	  device, set_graphics=6
	  if xl ge 0 then begin
	    xyouts, xl, yl, txt, size=sz, color=clr, orient=ang, /dev
	  endif
	  xyouts, x,  y,  txt, size=sz, color=clr, orient=ang, /dev
	  xl = x
	  yl = y
	  device, set_graphics=3
	  print,' Text at device x,y of ', x, y
	endif
	if c eq 'BUTTON_2' then begin
	  if xl ge 0 then begin
	    device, set_graphics=6
	    xyouts, xl, yl, txt, size=sz, color=clr, orient=ang, /dev
	    device, set_graphics=3
	  endif
	  xyouts, x,  y,  txt, size=sz, color=clr, orient=ang, /dev
	  print,' Text at device x,y of ', x, y
	  xl = -1
	endif
	if c eq 'BUTTON_3' then begin
	  if xl ge 0 then begin
	    device, set_graphics=6
	    xyouts, xl, yl, txt, size=sz, color=clr, orient=ang, /dev
	    print,' Text at device x,y of ', x, y
	    device, set_graphics=3
	  endif
	  return
	endif
 
	goto, loop
 
	end

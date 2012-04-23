;+
; NAME:
;       PLOTWIN
; PURPOSE:
;       Gives plot window (area enclosed by axes) in pixels.
; CATEGORY:
; CALLING SEQUENCE:
;       plotwin, px0, py0, dpx, dpy
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       px0, py0 = window lower-left corner coord. in pixels.   out 
;       dpx, dpy = window size in pixels.                       out 
; COMMON BLOCKS:
; NOTES:
;       Note: Only for square pixels currently. 
; MODIFICATION HISTORY:
;       R. Sterner, 13 Dec, 1989
;-
 
	pro plotwin, px0, py0, dpx, dpy, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Gives plot window (area enclosed by axes) in pixels.'
	  print,' plotwin, px0, py0, dpx, dpy'
	  print,'   px0, py0 = window lower-left corner coord. (pixels).   out'
	  print,'   dpx, dpy = window size in pixels.                      out'
	  print,' Note: Only for square pixels currently.'
	  return
	endif
 
	plot,[0,1],/nodata,/noerase,xstyle=4,ystyle=4	; This sets up window.
 
	px0 = !x.window(0)*!d.x_size			; Find out what it is.
	py0 = !y.window(0)*!d.y_size
	dpx = !x.window(1)*!d.x_size - px0
	dpy = !y.window(1)*!d.y_size - py0
 
	return
	end

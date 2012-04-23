;+
; NAME:
;       HOR
; PURPOSE:
;       Plot a horizontal line on a graph at specified y value.  See ver.
; CATEGORY:
; CALLING SEQUENCE:
;       hor, y
; INPUTS:
;       y = Y value of horizontal line.   in 
; KEYWORD PARAMETERS:
;	Keywords:
;	  LINESTYLE = s.  Linestyle.
;	  COLOR = c.  color.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;-
 
	pro hor, y, help=hlp, linestyle=ls, color=clr
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot a horizontal line on a graph at specified y value.'
	  print,' hor, y'
	  print,'   y = Y value of horizontal line.  Scalar or array.    in'
	  print,' Keywords:'
	  print,'   LINESTYLE = s.  Linestyle.'
	  print,'   COLOR = c.  color.'
	  print,' Notes: see ver.'
	  return
	end

	yy = array(y)
 
	n = n_elements(yy)
	if n_elements(ls) eq 0 then ls = 0
	if n_elements(clr) eq 0 then clr = !p.color
	xx = [!x.range, !x.crange]

	for i = 0, n-1 do begin
	  oplot, [min(xx),max(xx)], [1.,1.]*yy(i), linestyle=ls, color=clr
	endfor
 
	return
	end

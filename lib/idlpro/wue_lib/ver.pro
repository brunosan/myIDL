;+
; NAME:
;       VER
; PURPOSE:
;       Plot a vertical line on a graph at specified x value. See hor.
; CATEGORY:
; CALLING SEQUENCE:
;       ver, x
; INPUTS:
;       x = X value of vertical line.   in 
; KEYWORD PARAMETERS:
;	Keywords:
;	  LINESTYLE = s.  Linestyle.
;	  COLOR = c.  Color.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 2 Aug, 1989.
;		T. Leighton, 12 Sept, 1990 - latest Sterner version
;-
 
	pro ver, x, help=hlp, linestyle=ls, color=clr
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Plot a vertical line on a graph at specified x value. See hor.'
	  print,' ver, x'
	  print,'   x = X value of vertical line. Scalar or array.    in'
	  print,' Keywords:'
	  print,'   LINESTYLE = s.  Linestyle.'
	  print,'   COLOR = c.  Color.'
          print,' Note: see hor.'
	  print,'	This is the latest version from Sterners idl/lib directory.'
	  return
	end
 
	xx = array(x)
	if n_elements(ls) eq 0 then ls = 0
	if n_elements(clr) eq 0 then clr = !p.color
	n = n_elements(xx)
	yy = [!y.range, !y.crange]
	for i = 0, n-1 do begin
 	  oplot, [1.,1.]*xx(i), [min(yy),max(yy)], linestyle=ls, color=clr
	endfor
 
	return
	end

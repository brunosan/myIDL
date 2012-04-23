;+
; NAME:
;       MOVE
; PURPOSE: 
;       Graphics move to a point
; CATEGORY:
; CALLING SEQUENCE:
;       move, x, y
; INPUTS: 
;       x,y = scalar coordinates of point to move to.
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       move_com
; NOTES:
;       see draw
; MODIFICATION HISTORY:
;       R. Sterner, 22 Jan, 1990
;-       

	pro move, x, y, help=hlp

	common move_com, lstx, lsty

	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Graphics move to a point.'
	  print,' move, x, y'
	  print,'   x,y = scalar coordinates of point to move to.   in'
	  print,' Note: see draw.'
	  return
	endif

	lstx = x
	lsty = y
	return
	end

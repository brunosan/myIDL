;+
; NAME:
;       LINEPTS
; PURPOSE:
;       Gives pixel coordinates of points along a line segment.
; CATEGORY:
; CALLING SEQUENCE:
;       linepts, ix1, iy1, ix2, iy2, x, y
; INPUTS:
;       ix1, iy1 = Coordinates of point 1.         in 
;       ix2, iy2 = Coordinates of point 2.         in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x, y = arrays of coordinates along line.   out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  9 May, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO LINEPTS, IX1, IY1, IX2, IY2, JX, JY, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Gives pixel coordinates of points along a line segment.'
	  print,' linepts, ix1, iy1, ix2, iy2, x, y
	  print,'   ix1, iy1 = Coordinates of point 1.         in'
	  print,'   ix2, iy2 = Coordinates of point 2.         in'
	  print,'   x, y = arrays of coordinates along line.   out'
	  return
	endif
 
	IF (IX1 EQ IX2) AND (IY1 EQ IY2) THEN BEGIN
	  JX = INTARR(1) + IX1
	  JY = INTARR(1) + IY1
	  RETURN
	END
 
	IDX = ABS(IX2-IX1)		; size of line segment components.
	IDY = ABS(IY2-IY1)
 
	IF IDX GT IDY THEN BEGIN	; want to step along longest component.
	  JX = MAKEI( FIX(.5+IX1), FIX(.5+IX2), SIGN(IX2-IX1))
	  T = MAKEN( IY1, IY2, N_ELEMENTS(JX))
	  W = WHERE( T LT 0.0, cnt)		; values < 0 truncate upward.
	  if cnt gt 0 then T(W) = T(W) - 1.0	; so correct for this.
	  JY = FIX(.5+T)
	ENDIF ELSE BEGIN
	  JY = MAKEI( FIX(.5+IY1), FIX(.5+IY2), SIGN(IY2-IY1))
	  T = MAKEN( IX1, IX2, N_ELEMENTS(JY))
	  W = WHERE( T LT 0.0, cnt)
	  if cnt gt 0 then T(W) = T(W) - 1.0
	  JX = FIX(.5+T)
	ENDELSE
 
	RETURN
 
	END

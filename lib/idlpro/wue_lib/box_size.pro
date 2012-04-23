;+
; NAME:
;       BOX_SIZE
; PURPOSE:
;       Used by MOVBOX to change box size using the cursor.
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
;	/POSITION prints box size and position on exit of BOX_SIZE.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  25 July, 1989.
;-
 
	PRO BOX_SIZE, X, Y, DX, DY, position=pos, help=hlp, $
	  xsize=xsiz, ysize=ysiz
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Used by MOVBOX to change box size using the cursor.'
	  print,' BOX_SIZE, x, y, dx, dy'
	  print,'   x,y = lower left corner device coordinates.    in'
	  print,'   dx, dy = box size.                             in, out'
	  print,' Keywords:'
	  print,'   /POSITION prints box position and size on exit.'
	  print,'   XSIZE = factor.  Mouse changes Y size, computes X size.'
	  print,'   YSIZE = factor.  Mouse changes X size, computes Y size.'
	  return
	endif
 
	X2 = X + DX - 1			; Upper right box corner.
	Y2 = Y + DY - 1
	TVCRS, X2, Y2
	wait, .1			; This help vms.
 
loop:	CURSOR, X2, Y2, 2, /DEVICE	; Move upper right corner.
	X2 = X2 > X			; Don't allow negative box sizes.
	Y2 = Y2 > Y
	DX = X2 - X + 1			; New box size.
	DY = Y2 - Y + 1
	if keyword_set(xsiz) then begin
	  dx = fix(.5+dy*xsiz)
	  if dx gt (!d.x_size - x) then begin
	    dx = !d.x_size - x
	    dy = fix(.5+dx/xsiz)>1<(!d.y_size-y)
	  endif
	  tvcrs, x, y+dy-1
	endif
	if keyword_set(ysiz) then begin
	  dy = fix(.5+dx*ysiz)
	  if dy gt (!d.y_size - y) then begin
	    dy = !d.y_size - y
	    dx = fix(.5+dy/ysiz)>1<(!d.x_size-x)
	  endif
	  tvcrs, x+dx-1, y
	endif
	TVBOX2, X, Y, DX, DY, 255			; Draw new box.
	if keyword_set(pos) then SHOW_BOX, X, Y, DX, DY	; Print box size.
	IF !ERR NE 1 THEN GOTO, LOOP			; Button 1 pressed?
	!ERR = 0
	TVCRS, X, Y
 
	RETURN
	END

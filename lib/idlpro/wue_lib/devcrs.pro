;+
; NAME:
;       DEVCRS
; PURPOSE:
;	Data cursor. X, Y dev coord. and image value at that point.
; CATEGORY:
; CALLING SEQUENCE:
;       devcrs, x, y, z, cmd
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x,y = device coordinates of point.         in, out 
;       z   = screen image value at (x,y).         out 
;       cmd = command.                             out 
;	  cmd = BUTTON_1, BUTTON_2, or BUTTON_3
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;	R. Sterner, 1 Jan, 1990
;-
 
	pro devcrs, x, y, z, cmd, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Data cursor. Gives X, Y dev coord & image value at point.'
	  print,' devcrs, x, y, z, cmd'
	  print,'   x,y = device coordinates of point.         in, out'
	  print,'   z   = screen image value at (x,y).         out'
	  print,'   cmd = command.                             out'
	  print,'     cmd = BUTTON_1, BUTTON_2, or BUTTON_3'
	  return
	endif
 
	if n_elements(x) eq 0 then x = 200
	if n_elements(y) eq 0 then y = 200
	tvcrs, x, y
 
loop: 	cursor, x, y, 1, /device
	z = tvrd(x,y,1,1) & z = z(0)
	if !err eq 1 then cmd = 'BUTTON_1'
	if !err eq 2 then cmd = 'BUTTON_2'
	if !err eq 4 then cmd = 'BUTTON_3'
	end

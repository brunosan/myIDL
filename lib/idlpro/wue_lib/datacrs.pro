;+
; NAME:
;       DATACRS
; PURPOSE:
;       Data cursor. Returns X and Y data coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       datacrs, x, y, cmd
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       x,y = data coordinates of point.         in, out 
;       cmd = command.                           out 
;	  cmd = BUTTON_1, BUTTON_2, or BUTTON_3
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;	R. Sterner, 19 Jan, 1990
;-
 
	pro datacrs, x, y, cmd, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Data cursor. Returns X and Y data coordinate.'
	  print,' datacrs, x, y,  cmd'
	  print,'   x,y = data coordinates of point.         in, out'
	  print,'   cmd = command.                           out'
	  print,'     cmd = BUTTON_1, BUTTON_2, or BUTTON_3'
	  return
	endif
 
	if n_elements(x) eq 0 then x = midv(!x.range)
	if n_elements(y) eq 0 then y = midv(!y.range)
	tvcrs, x, y, /data
 
loop: 	cursor, x, y, 1, /data
	if !err eq 1 then cmd = 'BUTTON_1'
	if !err eq 2 then cmd = 'BUTTON_2'
	if !err eq 4 then cmd = 'BUTTON_3'
	end

;+
; NAME:
;       CRS
; PURPOSE:
;       Interactive cursor. Lists positions in data or device coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       crs, [x,y]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords: 
;         /DATA to work in data coordinates 
;         /DEVICE to work in device coordinates. 
;	  /QUIET suppresses crs instructions and coordinate listing.
;	  TIME=t time in milliseconds when button was pressed.
; OUTPUTS:
;	x, y = cursor coordinates.     out
; COMMON BLOCKS:
;       crs_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner  2 Aug, 1989.
;	R. Sterner, 18 Mar, 1990 --- added /QUIET.
;	R. Sterner, 29 Jun, 1990 --- added TIME.
;-
 
	pro crs, x, y, help=hlp, data=dt, device=dv, quiet=quiet, time=tim
 
	common crs_com, xl, yl, timc
 
	if keyword_set(hlp) then begin
	  print,' Interactive cursor. Lists positions in data or dev coord.'
	  print,' crs, [x,y]'
	  print,'   x, y = cursor coordinates.        out'
	  print,' Keywords:'
	  print,'   /DATA to work in data coordinates'
	  print,'   /DEVICE to work in device coordinates.'
	  print,'   /QUIET suppresses crs instructions and coordinate listing.'
	  print,'   TIME=t time in milliseconds when button was pressed.'
	  return
	endif
 
	if n_elements(xl) eq 0 then xl = 0.
	if n_elements(yl) eq 0 then yl = 0.
	if n_elements(timc) eq 0 then timc = 0L
 
	if (keyword_set(dt)+keyword_set(dv)) eq 0 then dt = 1
 
	if not keyword_set(quiet) then begin
	  if keyword_set(dt) then print,' Data cursor.'
	  if keyword_set(dv) then print,' Device cursor.'
	  print,' Left button lists data coordinates of cursor,'
	  print,' and x and y distance from last point.'
	  print,' Right button exits.'
	endif

	cnt = 0

loop:	if keyword_set(dt) then begin
	  cursor, x, y, /data
	endif
	if keyword_set(dv) then begin
	  cursor, x, y, /device
	endif
	tim = !mouse.time
	delta = tim - timc
	if delta lt 50 then begin
	  goto, loop
	endif
	timc = tim
	dx = x - xl  & dy = y - yl
	if not keyword_set(quiet) then begin
	  print,'    ',cnt
	  print,'x, y = ', x, y
	  print,'dx, dy = ', dx, dy 
	  if dx eq 0 then print,'Slope: Undefined.' else print,'Slope: ',dy/dx
	endif
	xl = x
	yl = y
	if !err eq 4 then return
	cnt = cnt + 1
	goto, loop
 
	end

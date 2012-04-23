;+
; NAME:
;       TVRDBOX
; PURPOSE:
;       Read part of screen image into a byte array.
; CATEGORY:
; CALLING SEQUENCE:
;       tvrdbox, a
; INPUTS:
; KEYWORD PARAMETERS:
;	/NOERASE prevents last box from being erased first.'
;	  Good when a new image covers up last box.'
; OUTPUTS:
;       a = image read from screen.   out 
; COMMON BLOCKS:
;       tvrdbox_com
; NOTES:
;       Notes: See also tvwrbox 
; MODIFICATION HISTORY:
;       R. Sterner, 19 Nov, 1989
;-
 
	pro tvrdbox, a, help=hlp, noerase=noer
 
	common tvrdbox_com, xr, yr, dxr, dyr, xw, yw, dxw, dyw
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read part of screen image into a byte array.'
	  print,' tvrdbox, a'
	  print,'   a = image read from screen.   out'
	  print,' Keywords:'
	  print,'   /NOERASE prevents last box from being erased first.'
	  print,'     Good when a new image covers up last box.'
	  print,' Notes: See also tvwrbox'
	  return
	endif
 
	if n_elements(xr) eq 0 then xr = 100
	if n_elements(yr) eq 0 then yr = 100
	if n_elements(dxr) eq 0 then dxr = 100
	if n_elements(dyr) eq 0 then dyr = 100
 
	print,' Use right mouse button to read box image.'
	print,' Use middle mouse button for options menu.'
	print,' Use left mouse button to change box size.'
	movbox, xr, yr, dxr, dyr, code, noerase=noer
	if code eq 4 then a = tvrd(xr,yr,dxr,dyr)
	return
 
	end

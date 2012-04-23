;+
; NAME:
;       IMGBOX
; PURPOSE:
;       Draw a box on image.
; CATEGORY:
; CALLING SEQUENCE:
;       imgbox, [color]
; INPUTS:
;       color = box color (def = !p.color).  in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         THICKNESS=t  box thickness.  Thickens outward. 
; OUTPUTS:
; COMMON BLOCKS:
;       imgbox_com
; NOTES:
;       Note: new box starts at last box position if any. 
; MODIFICATION HISTORY:
;       R. Sterner, 25 Jan, 1990
;-
 
	pro imgbox, clr, thickness=thk, help=hlp
 
	common imgbox_com, xr, yr, dxr, dyr
 
	if keyword_set(hlp) then begin
	  print,' Draw a box on image.'
	  print,' imgbox, [color]'
	  print,'   color = box color (def = !p.color).  in'
	  print,' Keywords:'
	  print,'   THICKNESS=t  box thickness.  Thickens outward.'
	  print,' Note: new box starts at last box position if any.'
	  return
	endif
 
	if n_elements(xr) eq 0 then xr = 100
	if n_elements(yr) eq 0 then yr = 100
	if n_elements(dxr) eq 0 then dxr = 100
	if n_elements(dyr) eq 0 then dyr = 100
	if n_params(0) lt 1 then clr = !p.color
	if n_elements(thk) eq 0 then thk = 1
 
	print,' Draw box on image with mouse.'
	print,' Left button - toggle between change box size and move box.'
	print,' Middle button - draw box and exit.'
	print,' Right button - erase box and exit.'
 
	movbox, xr, yr, dxr, dyr, code, /noerase, color=clr
 
	if code eq 2 then begin
	  if thk gt 1 then begin
	    for i = 1, thk do tvbox, xr-i, yr-i, dxr+2*i, dyr+2*i, clr, /noerase
	  endif
	endif
 
	return
 
	end

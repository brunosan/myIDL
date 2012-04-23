;+
; NAME:
;       XYOUTB
; PURPOSE:
;       Bold text version of xyouts.
; CATEGORY:
; CALLING SEQUENCE:
;       xyoutb, x, y, text
; INPUTS:
;       x,y = text position.           in 
;       text = text string to plot.    in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /DATA use data coordinates (default). 
;         /DEVICE use device coordinates. 
;         /NORM use normalized coordinates. 
;         BOLD=N  Text is replotted N X N times, 
;           shifting by P pixel in x or y each time. 
;           Default N=2.  For hardcopy try about 5.  
;         PIXELS=P number of pixels to use for each shift (def=1). 
;           For hardcopy try 5 or 10. 
;         Other keywords: ALIGNMENT, COLOR, FONT, ORIENTATION, SIZE. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 21 June, 1990
;-
 
	pro xyoutb, x, y, text, help=hlp,alignment=ka,color=kc,data=kda,$
	    device=kde,font=kf,normal=kn,orientation=ko,size=ks,bold=kb, $
	    pixels=px
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Bold text version of xyouts.'
	  print,' xyoutb, x, y, text'
	  print,'   x,y = text position.           in'
	  print,'   text = text string to plot.    in'
	  print,' Keywords:'
	  print,'   /DATA use data coordinates (default).'
	  print,'   /DEVICE use device coordinates.'
	  print,'   /NORM use normalized coordinates.'
	  print,'   BOLD=N  Text is replotted N X N times,'
	  print,'     shifting by P pixel in x or y each time.'
	  print,'     Default N=2.  For hardcopy try about 5.''
	  print,'   PIXELS=P number of pixels to use for each shift (def=1).'
	  print,'     For hardcopy try 5 or 10.'
	  print,'   Other keywords: ALIGNMENT, COLOR, FONT, ORIENTATION, SIZE.'
	  return
	endif
 
	todev, x, y, xdv, ydv				; assume /DATA.
	if keyword_set(kn) then todev, x, y, xdv, ydv, /norm	; Was /NORM.
	if keyword_set(kde) then begin			; Was /DEV, just move.
	  xdv = x
	  ydv = y
	endif
 
	if n_elements(kb) eq 0 then kb = 2		; Default is bold=3.
	if n_elements(px) eq 0 then px = 1		; Def. pixels.
 
	if n_elements(ka) eq 0 then ka = 0.		; Def. align
	if n_elements(kc) eq 0 then begin
	  if !d.name ne 'PS' then begin			; Def. color
	    kc = !d.n_colors-1				;   If not PS.
	  endif else begin
	    kc = 0					; For PS.
	  endelse
	endif
	if n_elements(kf) eq 0 then kf = -1		; Def. font
	if n_elements(ko) eq 0 then ko = 0.		; Def. orient
	if n_elements(ks) eq 0 then ks = 1.		; Def. size
 
	dd = (kb-1.)/2.
	lo = floor(-dd)*px
	hi = floor(dd)*px
 
	for iy = lo, hi, px do begin
	  for ix = lo, hi, px do begin
	    xyouts, xdv+ix, ydv+iy, text, /dev, align=ka, color=kc, font=kf, $
	      orient=ko, size=ks
	  endfor
	endfor
 
	return
	end

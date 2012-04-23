;+
; NAME:
;       STEREO
; PURPOSE:
;       Do red/green stereo graphics
; CATEGORY:
; CALLING SEQUENCE:
;       stereo, x, y, p
; INPUTS:
;       x,y = arrays of x,y values to plot.
;       p = optional pen code (0=down, 1=up).
; KEYWORD PARAMETERS:
;       /CT loads red/green stereo color table.
;         Graphics are to be viewed with red/green viewers.
;       /OLDCT reloads original color table.
;       /RED plots x,y in red.
;       /GREEN plots x,y in green.
;       /GRAY plots x,y in gray = erase.
;       PSYM=p plots symbols along x,y using symbol number p.
; OUTPUTS:
: COMMON BLOCKS:
;       stereo_com
; NOTES: 
; MODIFICATION HISTORY:             
;	R. Sterner, 12 Jan, 1990
;-

	pro stereo, x, y, p, help=hlp, ct=ct, oldct=oldct,$
	   red=red, green=green, gray=gray, psym=psym

	common stereo_com, r0, g0, b0		; Original color table.

	if keyword_set(hlp) then begin
	  print,' Do red/green stereo graphics.'
	  print,' stereo, x, y, p'
	  print,'   x,y = arrays of x,y values to plot.    in'
	  print,'   p = optional pen code (0=down, 1=up).  in'
	  print,' Keywords:'
	  print,'   /CT loads red/green stereo color table.'
	  print,'     Graphics are to be viewed with red/green viewers.'
	  print,'   /OLDCT reloads original color table.'
	  print,'   /RED plots x,y in red.'
	  print,'   /GREEN plots x,y in green.'
	  print,'   /GRAY plots x,y in gray = erase.'
	  print,'   PSYM=p plots symbols along x,y using symbol number p.'
	  return
	endif

	if keyword_set(oldct) then begin
	   tvlct, r0, g0, b0
	   return
	endif

	if keyword_set(ct) then begin
	   tvlct, r0, g0, b0, /get
	   tvlct, [87,209,0,204], [87,71,193,191], [87,71,0,66]
	endif

	if keyword_set(red) then begin		; red writes on bit-plane 1.
	  device, set_graphics = 7
	  clr = 1
	endif

	if keyword_set(green) then begin	; green writes on bit-plane 2.
	  device, set_graphics = 7
	  clr = 2
	endif

	if keyword_set(gray) then begin		; gray: erases all bit planes. 
	  device, set_graphics = 1
	  clr = 0
	endif

	if keyword_set(psym) then begin
	  oplot, x, y, color=clr, psym=psym
	  goto, done
	endif

	if n_params(0) eq 2 then begin
	  plotp, x, y, color = clr
	  goto, done
	endif

	if n_params(0) eq 3 then begin
	  plotp, x, y, p, color = clr
	endif

done:	device, set_graphics = 3
	return

	end

;+
; NAME:
;       XPRINT
; PURPOSE:
;       Print text on graphics device.  After initializing use just like print.
; CATEGORY:
; CALLING SEQUENCE:
;       xprint, item1, [item2, ..., item10]
; INPUTS:
;       txt = text string to print.     in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c set text color.
;         ALIGNMENT=a set text alignment.
;         /DATA use data coordinates (def).
;         /DEVICE use device coordinates.
;         /NORM use normalized coordinates.
;           Except for data coordinates always use the
;           coordinate keyword (also on /INIT).
;         /INIT to initialize xprint.
;           xprint,/INIT,x,y
;             x,y = coord. of upper-left corner of first line of text.    in
;         SIZE=sz  Text size to use. On /INIT only.
;         DY=factor.  Adjust auto line space by this factor. On /INIT only
;           Try DY=1.5 for PS plots with the printer fonts (not PSINIT,/VECT).
;	  YSPACE=out return line spacing in Y.
; OUTPUTS:
; COMMON BLOCKS:
;       xprint_com
; NOTES:
;       Notes: Initialization sets text starting location and text size.
;         All following xprint calls work just like print normally does except
;         text is output on the graphics device.
; MODIFICATION HISTORY:
;       R. Sterner, 9 Oct, 1989.
;-
 
	pro xprint, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, $
	  help=hlp, init=nit, dy=dy2, size=size, color=color, $
	  alignment=alignment, data=data, device=device, norm=norm, $
	  yspace=yspace
 
	common xprint_com, xc, yc, szc, dy
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Print text on graphics device.  After initializing '+$
	    'use just like print.'
	  print,' xprint, item1, [item2, ..., item10]'
	  print,'   txt = text string to print.     in'
	  print,' Keywords:'
	  print,'   COLOR=c set text color.'
	  print,'   ALIGNMENT=a set text alignment.'
	  print,'   /DATA use data coordinates (def).'
	  print,'   /DEVICE use device coordinates.'
	  print,'   /NORM use normalized coordinates.'
	  print,'     Except for data coordinates always use the'
	  print,'     coordinate keyword (also on /INIT).'
	  print,'   /INIT to initialize xprint.'
	  print,'     xprint,/INIT,x,y'
	  print,'       x,y = coord. of upper-left corner of first '+$
	    'line of text.    in'
	  print,'   SIZE=sz  Text size to use. On /INIT only.'
	  print,'   DY=factor.  Adjust auto line space by this factor. '+$
	    'On /INIT only.
	  print,'     Try DY=1.5 for PS plots with the printer fonts '+$
	    '(not PSINIT,/VECT).'
	  print,'   YSPACE=out return line spacing in Y.'
	  print,' Notes: Initialization sets text starting location and '+$
	    'text size.'
	  print,'   All following xprint calls work just like print '+$
	    'normally does except'
	  print,'   text is output on the graphics device.'
	  return
	endif
 
	if n_elements(data) eq 0 then data = 0
	if n_elements(device) eq 0 then device = 0
	if n_elements(norm) eq 0 then norm = 0
	if data+device+norm eq 0 then data=1
	to_data = 0
	if data eq 1 then to_data = 1
	to_norm = 0
	if norm eq 1 then to_norm = 1
	to_dev = 0
	if device eq 1 then to_dev = 1
 
	;--------  /INIT  ----------------
	if keyword_set(nit) then begin
	  if n_params(0) lt 2 then begin
	    print,' Must give both x and y in normalized coordinates.'
	    return
	  endif
	  xc = p1	; TExt starting x,y.
	  yc = p2 
	  szc = 1.	; Use size=1 to figure spacing.
	  if n_elements(size) ne 0 then szc = size
	  ;---  Figure out line spacing.  ---
	  xyouts, -10, -10, 'M', width=dy, color=0, $
	    data=data, device=device, norm=norm
	  aa = convert_coord([0,dy],[0,1.7*dy], /norm, to_data=to_data, $
	    to_dev=to_dev, to_norm=to_norm)
	  dy = aa(1,1) - aa(1,0)
	  dy = szc*dy
	  if n_elements(dy2) gt 0 then dy = dy*dy2  ; Line spacing over-ride.
	  yspace = dy	; Output line spacing.
	  return
	endif
 
	txt = ''
	for i = 1, n_params(0) do begin
	  j = execute('t = p'+strtrim(i,2))
	  txt = txt + string(t)
	endfor
 
	if n_elements(color) eq 0 then color = !p.color
	if n_elements(alignment) eq 0 then alignment = 0.
 
	xyouts, xc, yc, txt, size=szc, color=color, $
	  alignment=alignment, data=data,device=device, norm=norm
	yc = yc - dy
 
	return
	end

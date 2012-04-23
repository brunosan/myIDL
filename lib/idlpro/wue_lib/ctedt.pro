;+
; NAME:
;       ctedt 
; PURPOSE:
;       Edit a color table entry.
; CATEGORY:
; CALLING SEQUENCE:
;       ctedt, r, g, b
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords: 
;         BOTTOM=[rb,gb,bb] a color to display along 
;           bottom of color patch. 
;         TOP=[rt,gt,bt] a color to display along 
;           top of color patch. 
; OUTPUTS:
;       r = red color value (0-255).     in out 
;       g = green color value (0-255).   in out 
;       b = blue color value (0-255).    in out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 4 Sep, 1990
;       rename from edtclr -> ctedt G. Jung, 26 Oct, 1992
;-
 
	pro ctedt, r, g, b, bottom=bot, top=top, $
	  xpos=xpos, ypos=ypos, title=title, help=hlp
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Edit a color table entry.'
	  print,' ctedt, r, g, b'
	  print,'   r = red color value (0-255).     in out'
	  print,'   g = green color value (0-255).   in out'
	  print,'   b = blue color value (0-255).    in out'
	  print,' Keywords:'
	  print,'   BOTTOM=[rb,gb,bb] a color to display along'
	  print,'     bottom of color patch.'
	  print,'   TOP=[rt,gt,bt] a color to display along'
	  print,'     top of color patch.'
	  print,'   XPOS=x screen x position of edit window.'
	  print,'     0 to 500 (def = 200).'
	  print,'   YPOS=y screen y position of edit window.'
	  print,'     0 to 700 (def = 20).'
	  print,'   TITLE=t edit window title (def=Adjust Color).'
	  return
	endif
 
	;-------  Fix undefined values  ------
	if n_elements(r) eq 0 then r = 100
	if n_elements(g) eq 0 then g = 100
	if n_elements(b) eq 0 then b = 100
	if n_elements(xpos) eq 0 then xpos = 200
	if n_elements(ypos) eq 0 then ypos = 20
	if n_elements(title) eq 0 then title='Adjust Color'
 
	;-------  Initialize values  -----
	tvlct, rr0, gg0, bb0, /get		; Save current color table.
	x0 = 8
	z = bytarr(256,40)
	rd = bytarr(256,40)+1b
	gr = bytarr(256,40)+2b
	bl = bytarr(256,40)+3b
	gray = bytarr(300-x0-255, 150) + 64
	gray2 = gray(*,0:49)
 
	;-------  Initial screen setup  --------
	wdelete, 2
	window, 2, xsize=300, ysize=300, xpos=xpos, ypos=ypos, title=title
	rr = indgen(256)			  ; Set up new color table.
	gg = rr					  ; Start all gray,
	bb = rr
	rr(1) = 255 & gg(1) = 0   & bb(1) = 0	  ; 1 = red
	rr(2) = 0   & gg(2) = 255 & bb(2) = 0	  ; 2 = green
	rr(3) = 0   & gg(3) = 0   & bb(3) = 255	  ; 3 = blue
	rr(4) = r   & gg(4) = g   & bb(4) = b	  ; 4,5,6 = given color.
	rr(5) = r   & gg(5) = g   & bb(5) = b
	rr(6) = r   & gg(6) = g   & bb(6) = b
	topi = 4					; Top color index.
	boti = 4					; Bottom color index.
	if n_elements(top) gt 0 then begin
	  rr(5)=top(0) & gg(5)=top(1) & bb(5)=top(2)  ; Set given top color.
	  topi = 5
	endif
	if n_elements(bot) gt 0 then begin
	  rr(6)=bot(0) & gg(6)=bot(1) & bb(6)=bot(2)  ; Set given bottom color.
	  boti = 6
	endif
	tvlct, rr, gg, bb			; Load working color table.
	erase, 64				; Window background (gray).
	tv, bytarr(256,150), x0, 150		; Bar background (black).
	tv, bytarr(300,75)			; Black border.
	tv,bytarr(290,25)+4b,5,25		; Color patch.
	tv,bytarr(290,20)+topi,5,50		; Top color.
	tv,bytarr(290,20)+boti,5,5		; Bottom color.
	xyouts, x0, 140, /dev, align=.5, '0'	; Labels.
	xyouts, x0+255, 140, /dev, align=.5, '255'
	xyouts, 20, 114+10,/dev,'Left Button: Set color values', charsize=1.5
	xyouts, 20, 101+5,/dev,'Middle Button: Adjust brightness', charsize=1.5
	xyouts, 20, 88,  /dev, 'Right Button: quit', charsize=1.5
 
	;------- Show starting color  ------
	tv, z, x0, 155
	tv, bl(0:b,*), x0, 155
	xyouts, x0+255, 165, /dev, align=-.2, strtrim(b,2)
	tv, z, x0, 205
	tv, gr(0:g,*), x0, 205
	xyouts, x0+255, 215, /dev, align=-.2, strtrim(g,2)
	tv, z, x0, 255
	tv, rd(0:r,*), x0, 255
	xyouts, x0+255, 265, /dev, align=-.2, strtrim(r,2)
 
rd:	tvrdc, x, y, 1, /dev
 
	;-----  Return  --------
	if !err eq 4 then begin
	  tvlct, rr0, gg0, bb0			; Restore original color table.
	  wdelete, 2   				; Delete edit window.
	  return
	end

	if y lt 150 then goto, rd
 
	dx = (x - x0)<255>0
	dy = (y - 150)/50
 
	;------  Adjust brightness  ------
	if !err eq 2 then begin
	  m = r>g>b
	  f = dx/float(m)
	  r = fix(.5+r*f)>1
	  g = fix(.5+g*f)>1
	  b = fix(.5+b*f)>1
	  dy = 3
	endif
 
	;-----  Adjust r, g, or b  -------
	case dy of
0:	begin			; Blue
	  b = dx
	  tv, z, x0, 155
	  tv, bl(0:b,*), x0, 155
	  tv, gray2, x0+256, 150
	  xyouts, x0+256, 165, /dev, align=-.2, strtrim(b,2)
	end
1:	begin			; Green
	  g = dx
	  tv, z, x0, 205
	  tv, gr(0:g,*), x0, 205
	  tv, gray2, x0+256, 200
	  xyouts, x0+256, 215, /dev, align=-.2, strtrim(g,2)
	end
2:	begin			; Red
	  r = dx
	  tv, z, x0, 255
	  tv, rd(0:r,*), x0, 255
	  tv, gray2, x0+256, 250
	  xyouts, x0+256, 265, /dev, align=-.2, strtrim(r,2)
	end
3:	begin			; All = brightness.
	  tv, gray, x0+256, 150
	  tv, z, x0, 155
	  tv, bl(0:b,*), x0, 155
	  xyouts, x0+256, 165, /dev, align=-.2, strtrim(b,2)
	  tv, z, x0, 205
	  tv, gr(0:g,*), x0, 205
	  xyouts, x0+256, 215, /dev, align=-.2, strtrim(g,2)
	  tv, z, x0, 255
	  tv, rd(0:r,*), x0, 255
	  xyouts, x0+256, 265, /dev, align=-.2, strtrim(r,2)
	end
	endcase
 
	rr(4) = r		; Load new color into working color table.
	gg(4) = g
	bb(4) = b
	tvlct, rr, gg, bb	; Load updated working color table.
 
	goto, rd
 
	end

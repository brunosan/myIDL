;+
; NAME:
;       ANN
; PURPOSE:
;       Menu driven annotation routine.
; CATEGORY:
; CALLING SEQUENCE:
;       ann
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
;       ann_menu_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 21 Sep, 1990
;-
 
	pro ann, help=hlp
 
	common ann_menu_com, color, pcolor, linestyle, thick, size, $
	   orient, length, width, shaft, text, file
 
	if keyword_set(hlp) then begin
	  print,' Menu driven annotation routine.'
	  print,' ann'
	  print,'   Menu prompt for inputs.'
	  return
	endif
 
	;------  initialize option values  ----------
	if n_elements(color) eq 0 then begin
	  color = !p.color
	  pcolor = -1
	  linestyle = !p.linestyle
	  thick = !p.thick
	  size = !p.charsize>1.
	  orient = 0.
	  length = 5.
	  width = 2.
	  shaft = 1.
	  file = ''
	  text = ''
	endif
 
	menu1 = ['Graphics Annotation','  Quit','  Lines and Curves',$
	         '  Text','  Polygons','  Boxes','  Circles','  Arrows',$
	         '  Change options','  Display memory','  Edit memory',$
	         '  Save memory','  Load memory','  Clear memory']
	in = 2
 
loop1:	in = wmenu(menu1, title=0, init=in)
 
	;----- quit  -----
	if in eq 1 then return
 
	;----  Lines and curves  -----
	if in eq 2 then begin
	  anncrv, color=color, linestyle=linestyle, thick=thick
	  goto, loop1
	endif
 
	;----  Text  -----
	if in eq 3 then begin
	  txt = ''
	  read,' Enter text (def = '+text+'): ', txt
	  if txt eq '' then txt = text
	  if txt eq '' then goto, loop1
	  text = txt
	  anntxt, text, color=color, size=size, thick=thick, orient=orient
	  goto, loop1
	endif
 
	;----  Polygons ------
	if in eq 4 then begin
	  annply, color=color, thick=thick, linestyle=linestyle, fill=pcolor
	  goto, loop1
	endif

	;----  Boxes  ------
	if in eq 5 then begin
	  annbox, color=color, thick=thick, linestyle=linestyle, fill=pcolor
	  goto, loop1
	endif
 
	;----  Circles ------
	if in eq 6 then begin
	  anncrc, color=color, thick=thick, linestyle=linestyle, fill=pcolor
	  goto, loop1
	endif

	;----  Arrows  -----
	if in eq 7 then begin
	  annarr, color=color, thick=thick, linestyle=linestyle, fill=pcolor, $
	    length=length, width=width, shaft=shaft
	  goto, loop1
	endif
 
	;----  Options  -----
	if in eq 8 then begin
	  in2 = 2
loop2:	  m2 = '  Color = '+strtrim(color,2)
	  m3 = '  Linestyle = '+strtrim(linestyle,2)
	  m4 = '  Thickness = '+strtrim(thick,2)
	  m5 = '  Fill color = '+strtrim(pcolor,2)
	  m6 = '  Char size = '+strtrim(size,2)
	  m7 = '  Text angle = '+strtrim(orient,2)
	  m8 = '  Arrow head length = '+strtrim(length,2)
	  m9 = '  Arrow head width = '+strtrim(width,2)
	  m10 = '  Arrow shaft width = '+strtrim(shaft,2)
	  menu2 = ['Change option values','  Cancel',m2,m3,m4,m5,m6,m7,$
	            m8,m9,m10]
	  in2 = wmenu(menu2, title=0, init=in2)
	  case in2 of
1:	    goto, loop1
2:	    begin
	      txt = ''
	      read,' Enter new color: ',txt
	      if txt ne '' then color = txt + 0
	      goto, loop2
	    end
3:	    begin
	      txt = ''
	      read,' Enter new linestyle: ',txt
	      if txt ne '' then linestyle = txt + 0
	      goto, loop2
	    end
4:	    begin
	      txt = ''
	      read,' Enter new thickness: ',txt
	      if txt ne '' then thick = txt + 0
	      goto, loop2
	    end
5:	    begin
	      txt = ''
	      read,' Enter new fill color: ',txt
	      if txt ne '' then pcolor = txt + 0
	      goto, loop2
	    end
6:	    begin
	      txt = ''
	      read,' Enter new char size: ',txt
	      if txt ne '' then size = txt + 0.
	      goto, loop2
	    end
7:	    begin
	      txt = ''
	      read,' Enter new text angle: ',txt
	      if txt ne '' then orient = txt + 0.
	      goto, loop2
	    end
8:	    begin
	      txt = ''
	      read,' Enter new arrow head length: ',txt
	      if txt ne '' then length = txt + 0.
	      goto, loop2
	    end
9:	    begin
	      txt = ''
	      read,' Enter new arrow head width: ',txt
	      if txt ne '' then width = txt + 0.
	      goto, loop2
	    end
10:	    begin
	      txt = ''
	      read,' Enter new arrow shaft width: ',txt
	      if txt ne '' then shaft = txt + 0.
	      goto, loop2
	    end
else:	    goto, loop2
	  endcase
	endif
 
	;--------  Display memory  -------
	if in eq 9 then begin
	  erase
	  annexe
	  goto, loop1
	endif

	;--------  Edit memory  -------
	if in eq 10 then begin
	  annedt
	  goto, loop1
	endif
 
	;--------  Save memory  ------
	if in eq 11 then begin
	  txt = ''
	  print,' Save memory in a file.'
	  read,' Enter file name (def = '+file+'): ',txt
	  if txt eq '' then txt = file
	  if txt eq '' then goto, loop1
	  file = txt
	  annput, file
	  goto, loop1
	endif
 
	;--------  Recall memory  ------
	if in eq 12 then begin
	  txt = ''
	  print,' Load memory from a file.'
	  read,' Enter file name (def = '+file+'): ',txt
	  if txt eq '' then txt = file
	  if txt eq '' then goto, loop1
	  file = txt
	  annget, file
	  goto, loop1
	endif
 
	;----  Clear memory  ------
	if in eq 13 then begin
	  annres
	  goto, loop1
	endif
 
	goto, loop1
 
	end

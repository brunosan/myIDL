;+
; NAME:
;       WMENU2
; PURPOSE:
;       Like wmenu but allows non-mouse menus.
; CATEGORY:
; CALLING SEQUENCE:
;       i = wmenu2(list)
; INPUTS:
;       list = menu in a string array.        in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         TITLE=t  item number to use as title (def = no title). 
;         INITIAL_SELECTION=s  initial item selected (or default value). 
; OUTPUTS:
;       i = selected menu item number.        out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 22 May 1990
;-
 
	function wmenu2, list, title=tt, initial_selection=init, help=hlp, $
	  nomouse=nom
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Like wmenu but allows non-mouse menus.'
	  print,' i = wmenu2(list)'
	  print,'   list = menu in a string array.        in'
	  print,'   i = selected menu item number.        out'
	  print,' Keywords:'
	  print,'   TITLE=t  item number to use as title (def = no title).'
	  print,'   INITIAL_SELECTION=s  initial item selected (=default).'
	  return, -1
	endif

	if n_elements(tt) eq 0 then tt = -1
	if n_elements(init) eq 0 then init = -1
 
	name = !d.name				; Plot device name.
	flag = 0				; Assume no mouse.
	if name eq 'SUN' then flag = 1		; On SUN, assume mouse.
	if name eq 'X' then flag = 1		; On X windows, assume mouse.
	if keyword_set(nom) then flag = 0	; Force no mouse.
 
	;--------  mouse menu  ----------
	if flag eq 1 then begin
loop:	  in = wmenu(list, title=tt, init=init)
	  if in lt 0 then goto, loop
	  return, in
	endif
 
	;-------  non-mouse menu  --------
	print,' '
	mx = n_elements(list)-1
	if tt ge 0 then print,'          '+list(tt)
	for i = 0, mx do begin
	  if i ne tt then print,' ',i,' '+list(i)
	endfor
loop2:	txt = ''
	if init ge 0 then begin
	  read,' Choose (def = '+strtrim(init,2)+'): ',txt
	endif else begin
	  read,' Choose: ', txt
	endelse
	if txt eq '' then txt = init
	in = txt + 0
	if (in lt 0) or (in gt mx) then begin
	  print,' You must choose one of the above'
	  goto, loop2
	endif
	if in eq tt then begin
	  print,' You must choose one of the above'
	  goto, loop2
	endif
	return, in
 
	end

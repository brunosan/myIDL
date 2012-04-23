;+
; NAME:
;       TAPE_SELECT
; PURPOSE:
;       Pop-up menu selection of a tape drive.
; CATEGORY:
; CALLING SEQUENCE:
;       tape_select, tape
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       tape = name of tape drive (none for none).   out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 26 Mar, 1990
;	T. Leighton, 31 Oct, 1990 - corrected tape drive names
;-
 
	pro tape_select, tape, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Pop-up menu selection of a tape drive.'
	  print,' tape_select, tape'
	  print,'   tape = name of tape drive (none for none).   out'
	  return
	endif
 
	menu = ['Select tape drive','  None','  Kennedy 1 1600 bpi',$
	  '  Kennedy 1 6250 bpi','  Kennedy 0 1600 bpi','  Kennedy 0 6250 bpi', $
	  '  Exabyte unit 1','  Exabyte unit 2']
 
	list = ['title','none','nrmt1','nrmt9',$
	  'nrmt0','nrmt8','nrst1','nrst2']
 
	if n_elements(tape) eq 0 then tape = ''
	w = where(list eq tape, count)
	if count eq 0 then in = 2
	if count ne 0 then in = w(0)
 
loop:	wshow, 0
	in = wmenu(menu, title=0, init=in)
	if in lt 0 then goto, loop
 
	tape = list(in)
 
	return
	end

;+
; NAME:
;       LPRINT2
; PURPOSE:
;       From IDL, print a file on a laser printer. May select printer.
; CATEGORY:
; CALLING SEQUENCE:
;       lprint2, file
; INPUTS:
;       file = text file to print.         in 
; KEYWORD PARAMETERS:
;       Keywords may be used to select which printer: 
;       /NEC = NEC Silent writer (default). 
;       /NEW = newgen TurboPS/360  
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 17 Aug, 1989.
;         G.Jung, 26 Jan, 1993  -renamed from lprint.pro
;                               -made for Institut fuer Astronomie und
;                                         Astrophysik Wuerzburg
;-
 
	pro lprint2, file, nec=nec, new=new, help=h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' From IDL, print a file on a laser printer. May select printer.'
	  print,' lprint2, file'
	  print,'   file = text file to print.         in'
	  print,'   Keywords may be used to select which printer:'
	  print,'   /NEC = NEC Silent writer (default).'
	  print,'   /NEW = newgen TurboPS/360' 
	  return
	endif
 
	if n_elements(file) eq 0 then begin
	  print,' File name must be a string.  Setup a string variable or put name in quotes.'
	  return
	endif
 
	n = 0
	if keyword_set(nec) then n = 1
	if keyword_set(new) then n = 2
	n = n>1
 
	case n of
1:	begin
	  print,' Printing file on NEC Silent writer . . .'
	 spawn,'lpr -P0 ' + file, err
	print,'lpr -P0 ' + file
	end
2:	begin
	  print,' Printing file on newgen TurboPS/360 . . .'
	  spawn,'lpr -P1 ' + file, err
	end
else:	begin
	  print,'  Internal error in lprint2.'
	  return
	end
	endcase
 
	err = array(err)
	if err(0) eq '' then print,' '+file+' printed.' else print, err
 
	return
	end

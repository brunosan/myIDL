;+
; NAME:
;       CLT
; PURPOSE:
;       Load a color table. Menu selection.
; CATEGORY:
; CALLING SEQUENCE:
;       clt, [file]
; INPUTS:
;       file = optional color table file name (no extension).     in 
;         If no args given then menu is given. 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /LOCAL uses local color tables, else 
;            uses system color tables. 
;            The standard directory is IDLUSR (must be upper) which 
;            is a env. var. in UNIX and a logical name in VMS. 
;         /SAVE saves current color table. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: color table file names must end in .clt 
;         and have been saved as: save2, 'name.clt',string, r, g, b, /XDR 
;         where string is a short description, and r,g,b are byte 
;         arrays for the red, green, and blue parts of the color 
;         table (0 to 255).  Arrays are generally 256 elements long, 
;         but other sizes will also work. 
; MODIFICATION HISTORY:
;       R. Sterner, 10 July, 1990
;-
 
	pro clt, file, help=hlp, local=loc, save=sv
 
	if keyword_set(hlp) then begin
	  print,' Load a color table. Menu selection.'
	  print,' clt, [file]'
	  print,'   file = optional color table file name (no extension).   in'
	  print,'     If no args given then menu is given.'
	  print,' Keywords:'
	  print,'   /LOCAL uses local color tables, else'
	  print,'      uses system color tables.'
	  print,'      The standard directory is IDLUSR (must be upper) which'
	  print,'      is a env. var. in UNIX and a logical name in VMS.'
	  print,'   /SAVE saves current color table.'
	  print,' Notes: color table file names must end in .clt'
	  print,"   and have been saved as:"
	  print,"     save2, 'name.clt',string, r, g, b, /XDR"
	  print,'   where string is a short description, and r,g,b are byte'
	  print,'   arrays for the red, green, and blue parts of the color'
	  print,'   table (0 to 255).  Arrays are generally 256 elements long,'
	  print,'   but other sizes will also work.'
	  return
	endif
 
	;------  Get color table directory  ---------
	dir = filename('IDLUSR','')
 
	;------  wanted a local color table  --------
	if keyword_set(loc) then dir = ''
 
	;------  save color table  ----------
	if keyword_set(sv) then begin
	  tvlct, r, g, b, /get
	  if n_params(0) lt 1 then begin
	    file = ''
	    read,' Enter file name to save in (no ext): ',file
	    if file eq '' then return
	  endif
	  s = ''
	  read,' Enter color table description (brief): ',s
	  save2,dir+file+'.clt',s,r,g,b, /xdr
	  print,' Color table saved.'
	  return
	endif
 
	;------  Load named color table  ---------
	if n_params(0) ge 1 then begin
	  restore2,dir+file+'.clt',s,r,g,b, error=err, /xdr
	  if err ne 0 then return
	  print,' Loading '+s+' from file '+file
	  tvlct,r,g,b
	  return
	endif
 
	;-----  No color table given, find possibilities ---------
	f = findfile(dir+'*.clt')
	f = array(f)
	if f(0) eq '' then begin
	  print,' Error in CLT: No color table files found (*.clt).'
	  return
	endif
 
	;----  Put list of color tables in a menu  --------
	menu = ['Select Color Table','  Quit']
	nf = n_elements(f)
	for i = 0, nf-1 do begin
	  restore2,f(i),s, /xdr
	  menu = [menu,'  '+s]
	endfor
 
	;-----  menu selection  -------
	in = 2
loop:	in = wmenu(menu, title=0, init=in)
	if in eq 1 then return
	t = f(in-2)
	restore2,t,s,r,g,b, /xdr
	t = getwrd(t,/last,delim=']')
	t = getwrd(t,delim='.')
	print,' Loading '+s+' from file '+t
	tvlct,r,g,b
	goto, loop
 
	end

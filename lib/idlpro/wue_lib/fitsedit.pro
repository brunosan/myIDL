;+
; NAME:
;       FITSEDIT
; PURPOSE:
;       Edit FITS file headers.
; CATEGORY:
; CALLING SEQUENCE:
;       fitsedit
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 6 Apr, 1990
;-
 
	pro fitsedit, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Edit FITS file headers.'
	  print,' fitsedit'
	  print,'   Prompts for input.'
	  return
	endif
 
	erase
	wshow,0,0
	txt = ''
 
	print,' '
	print,' ---==< Edit FITS headers >==---'
	print,' '
	print,' This routine uses pop-up menus.  The mouse is used to'
	print,' select menu items by clicking the left mouse button.'
	print,' '
	getdefdir, dir, /new
floop:	print,' '
	pat = ''
	read,' Enter file name wildcard pattern (Ex: twr*.tmp): ', pat
	if pat eq '' then return
	print,' '
	ans = ''
	read,' Sort files numerically? y/n: ', ans
	if strlowcase(ans) eq 'y' then begin
	  print,' Searching for and sorting files . . .'
	  f = findfile2(dir+pat, /sort)
	endif else begin
	  print,' Searching for files . . .'
	  f = findfile(dir+pat)
	endelse
	f = array(f)
	if f(0) eq '' then begin
	  print,' No files found, re-enter file name pattern.'
	  goto, floop
	endif
	ff = f
	nff = n_elements(f)
	for i = 0, nff-1 do begin
	  ff(i) = getwrd(f(i), delim='/', /last)
	endfor
	f = ['-','-',f]
	ff = ['Select file to edit','quit',ff]
 
	;------- file select  ----------
	print,' Select file.'
	in1 = 2
inpt:	wshow, 0
	in1 = wmenu(ff, init=in1, title=0)
	if in1 lt 0 then goto, inpt
 
	if in1 eq 1 then goto, done
 
	wshow, 0, 0
	file = ff(in1)
;#####################################################	
 
	fitshdr, dir+file, hdr, error=err
	if err ne 0 then begin
	  print,' Error in fitsedit, aborting.'
	  return
	endif
 
	h0 = hdr
	last = n_elements(hdr)-1
	mflag = 0
 
	print,' '
	print,' Edit header'
 
loop:	print,' '
	print,' Editing file '+file
	print,' '
	print,' q - write out new header and quit'
	print,' w - write out new header'
	print,' u - undo all changes'
	print,' l - list header lines'
	print,' i - insert a header line'
	print,' d - delete header lines'
	print,' e - edit header lines'
	print,' ? - help'
	print,' '
 
	cmd = ''
	read, ' Command: ',cmd
	if cmd eq '' then goto, loop
	cmd = strupcase(cmd)
	cmd = repchr(cmd,',')
	cmd0 = getwrd(cmd,0)
 
	if cmd eq '?' then begin
	  print,' '
	  print,' Commands operate on the entire header'
	  print,' unless a line number range is given.'
	  print,' An example command using a line number range is:'
	  print,' l 0, 10'
	  print,' which lists lines 0 through 10.'
	  print,' l 20  lists header lines 20 to the end.'
	  print,' e 38  edits only line 38.'
	  print,' '
	goto, loop
	endif
 
	if cmd eq 'Q' then begin			; Quit.
	  if mflag eq 0 then begin
	    print,' Quiting, header not modified.'
	    goto, inpt2
	  endif else begin
	    fitswrite, dir+file, hdr
	    print,' Quiting, header modified.'
	    goto, inpt2
	  endelse
	endif
 
	if cmd eq 'W' then begin			; Write.
	  if mflag eq 0 then begin
	    print,' No changes, header not modified.'
	    goto, inpt2
	  endif else begin
	    fitswrite, dir+file, hdr
	    print,' Writing, header modified.'
	    goto, inpt2
	  endelse
	endif
 
	if cmd eq 'U' then begin			; Quit, no changes.
	  hdr = h0
	  mflag = 0
	  print,' All changes undone.'
	  goto, loop
	endif
 
	if cmd0 eq 'L' then begin			; List header lines.
	  lo = getwrd(cmd,1) + 0
	  hi = getwrd(cmd,2) + 0
	  if hi eq 0 then hi = last
	  for i = lo, hi do begin
	    t = hdr(i)
	    print,i,'  ',t
	    if getwrd(t,0) eq 'END' then goto, loop
	  endfor
	  goto, loop
	endif
 
	if cmd0 eq 'D' then begin			; Delete header lines.
	  lo = getwrd(cmd,1)
	  if lo eq '' then begin
	    read,' Line to delete: ',lo
	    if lo eq '' then goto, loop
	    lo = lo + 0
	    hi = lo
	    goto, del
	  endif
	  lo = lo + 0
	  hi = getwrd(cmd,2)
	  if hi eq '' then begin
	    hi = lo
	    goto, del
	  endif
	  hi = hi + 0
del:	  print,' Deleting lines '+strtrim(lo,2)+' to '+strtrim(hi,2)
dloop:	  hi = hi + 1
	  t = hdr(hi)
	  hdr(lo) = t
	  lo = lo + 1
	  if getwrd(t,0) ne 'END' then goto, dloop
	  sp = spc(80)
	  for i = lo, last do begin
	    if hdr(i) eq sp then goto, ddn
	    hdr(i) = sp
	  endfor
ddn:	  mflag = 1
	  goto, loop
	endif
 
	if cmd0 eq 'I' then begin			; Insert a header line.
	  lo = getwrd(cmd,1)
	  if lo eq '' then begin
	    read,' Line to insert text before: ',lo
	    if lo eq '' then goto, loop
	  endif
	  lo = lo + 0
	  t = ''
	  read,' Enter new header line: ',t
	  if t eq '' then goto, loop
	  for hi = (lo-1)>0, last do begin			; Find END.
	    tt = hdr(hi)
	    if getwrd(tt,0) eq 'END' then goto, inxt
	  endfor
inxt: 	  if lo gt hi then begin
	     print,' Cannot insert text after END'
	     goto, loop
	   endif
	   for i = hi+1, lo+1, -1 do begin
	     hdr(i) = hdr(i-1)
	   endfor
	   hdr(lo) = strmid(t,0,80)
	   mflag = 1
	   goto, loop
	endif
 
	if cmd0 eq 'E' then begin			; Edit header lines.
	  lo = getwrd(cmd,1)
	  if lo eq '' then begin
	    read,' Line to edit: ',lo
	    if lo eq '' then goto, loop
	    lo = lo + 0
	    hi = lo
	    goto, edt 
	  endif
	  lo = lo + 0
	  hi = getwrd(cmd,2)
	  if hi eq '' then begin
	    hi = lo
	    goto, edt
	  endif
	  hi = hi + 0
edt:	  print,' Edit command: r: replace, p: precede, f: follow, d: delete'
	  ecmd = ''
	  read, ' Enter edit command: ',ecmd
	  if ecmd eq '' then goto, loop
	  ecmd = strupcase(ecmd)
	  case ecmd of
     'R': pr = 'replace'
     'P': pr = 'precede'
     'F': pr = 'follow'
     'D': pr = 'delete'
    else: begin
	    print,' Invalid edit command.'
	    goto, edt
	  end
	  endcase
	  oldss = ''
	  print,' Substring to '+pr, format='($,a)'
	  read,oldss
	  if oldss eq '' then goto, loop
	  newss = ''
	  if ecmd ne 'D' then begin
	    print,' '+pr+' by',format='($,a)'
	    read, newss
	  endif
	  n = 0
	  read, ' Occurrance number to edit (0=all): ',n
	  print,' Editing lines ',lo,' to ',hi
	  for i = lo, hi<last do begin
	    t0 = hdr(i)
	    t = stress(t0, ecmd, n, oldss, newss)
	    t = strmid(t,0,80)
	    hdr(i) = t
	    print,' Old: ',i,'  ',t0
	    print,' New: ',i,'  ',t
	    print,' '
	    if getwrd(t0,0) eq 'END' then goto, loop
	  endfor
	  mflag = 1
	  goto, loop
	endif
 
	goto, loop
 
;#####################################################	
inpt2: print,' Press any key to continue'
	k = get_kbrd(1)
	goto, inpt
 
done:	print,' Quitting'
	wshow, 0, 0
	return
 
	end

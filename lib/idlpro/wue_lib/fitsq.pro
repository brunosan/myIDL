;+
; NAME:
;       FITSQ
; PURPOSE:
;       Do quick look at FITS image files.
; CATEGORY:
; CALLING SEQUENCE:
;       fitsq, [userpro]
; INPUTS:
;       userpro = optional procedure to process a FITS file.   in 
;         Must be a procedure and must have the FITS file name 
;         as the only argument.  userpro is a string with the 
;         procedure name.  Ex: fitsq, 'test' would execute: 
;         test, file 
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: fitsq is normally used without a processing procedure. 
;         It is almost completely menu driven using the mouse. 
; MODIFICATION HISTORY:
;       R. Sterner, 18 Mar, 1990
;-
 
	pro fitsq, userpro, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Do quick look at FITS image files.'
	  print,' fitsq, [userpro]'
	  print,'   userpro = optional procedure to process a FITS file.   in'
	  print,'     Must be a procedure and must have the FITS file name'
	  print,'     as the only argument.  userpro is a string with the'
	  print,"     procedure name.  Ex: fitsq, 'test' would execute:"
	  print,'     test, file'
	  print,' Notes: fitsq is normally used without a processing proc.'
	  print,'   It is almost completely menu driven using the mouse.'
	  return
	endif
 
	erase
	wshow,0,0
	txt = ''
 
	print,' '
	print,' ---==< FITS image quick look >==---'
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
	read,' Sort files numerically? y/N: ', ans
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
	print,' There are '+strtrim(nff,2)+' files.'
	read,' Show number of images per file? Takes about 1 sec'+$
	  ' per file.  y/N: ', ans
	ans = strlowcase(ans)
	for i = 0, nff-1 do begin
	  if !version.os ne 'vms' then begin
	    ff(i) = getwrd(f(i), delim='/', /last)
	  endif else begin
	    ff(i) = getwrd(f(i), delim=']', /last)
	    ff(i) = getwrd(ff(i),delim=';')
	  endelse
	  if ans eq 'y' then begin
	    print,i+1,' of ', nff
	    nim = fitsnum('naxis3',file=f(i), error=err)
	    if err eq 1 then begin		; No naxis3. Assume = 1.
	      nim = 1
	      err = 0
	    endif
	    if err eq 0 then begin
	      add = '  '+strtrim(fix(nim),2)
	    endif else begin
	      add = '  BAD'
	    endelse
	    ff(i) = ff(i) + add
	  endif
	endfor
	f = ['-','-',f]
	ff = ['Select file to examine','quit',ff]
 
	;------- file select  ----------
	print,' Select file.'
	in1 = 2
sloop:	wshow, 0
	in1 = wmenu(ff, init=in1, title=0)
	if in1 lt 0 then goto, sloop
 
	if in1 eq 1 then goto, done
 
	;------  select process  ----------
	print,' Select function.'
	file = f(in1)
	pmenu = ['Select function for FITS file '+getwrd(ff(in1)), '  Quit',$
	         '  Select another file','  Display header','  Display image',$
	         '  Print image and header']
	if n_params(0) gt 0 then pmenu = [pmenu, '  Apply '+userpro+$
	  ' to selected file']
 
ploop:	wshow, 0
	in2 = wmenu(pmenu, init=4, title=0)
	if in2 lt 0 then goto, ploop
 
	if in2 eq 1 then goto, done	; Quit.
 
	if in2 eq 2 then goto, sloop	; Select another file.
 
	if in2 eq 3 then begin		; Select header.
	  wshow, 0, 0
	  print,' Displaying header from file '+ff(in1)+' . . .'
	  fitshdr, file, hdr, error=err
	  if err ne 0 then begin
	    bell
	    print, ' Press any key to continue'
	    txt = get_kbrd(1)
	    goto, ploop
	  endif
	  if !version.os ne 'vms' then begin
	    openw, lun, '/dev/tty', /get_lun, /more
	  endif else begin
	    openw, lun, 'tt:', /get_lun, /more, /stream
	  endelse
	  for i = 0, n_elements(hdr)-1 do begin
	    txt = hdr(i)
	    if strtrim(txt,2) ne '' then printf, lun, hdr(i)
	  endfor
	  free_lun, lun
	  print, ' Press any key to continue'
	  txt = get_kbrd(1)
	  goto, ploop
	endif
 
	if in2 eq 4 then begin		; Display image.
	  print,' Display images.'
	  nim = fitsnum(file=file, 'naxis3')>1
	  imenu = ['Select image number to display','quit',$
	    'Select another function','Select another image',$
	    'Hide this menu, CLICK to redislpay']
	  for i = 1, nim do imenu = [imenu, strtrim(i,2)]
	  in = 5
iloop:	  wshow, 0
	  in = wmenu(imenu, init=in, title=0)
	  if in lt 0 then goto, iloop
	  if in eq 1 then goto, done
	  if in eq 2 then goto, ploop
	  if in eq 3 then goto, sloop
	  if in eq 4 then begin
	    cursor, x, y, /dev
	    goto, iloop
	  endif
	  nimg = in - 4
	  txt = 'Displaying file '+getwrd(ff(in1))+', image # '+$
	    strtrim(nimg,2)+' . . .'
	  for ix = -1, 1, 2 do begin
	  for iy = -1, 1, 2 do begin
	    xyouts, 10+ix, 10+iy, txt, /dev, size=1, color=0
	  endfor
	  endfor
	  xyouts, 10, 10, txt, /dev, size=1, color=255
	  wait, 0
	  fitsdata, file, img, set=nimg, error=err
	  if err ne 0 then begin
	    bell
	    wshow, 0, 0
	    print, ' Press any key to continue'
	    txt = get_kbrd(1)
	    goto, iloop
	  endif
	  tv, ls(img)
	  goto, iloop
	endif
 
	if in2 eq 5 then begin		; Print image.
	  nim = fitsnum(file=file, 'naxis3')>1
	  imenu = ['Select image number to print','quit',$
	    'Select another function','Select another image', '-']
	  txt = 'Click here to change printer #.  Now = 1'
	  imenu(4) = txt
	  prnum = 1
	  for i = 1, nim do imenu = [imenu, strtrim(i,2)]
	  in = 5
dloop:	  wshow, 0
	  in = wmenu(imenu, init=in, title=0)
	  if in lt 0 then goto, dloop
	  if in eq 1 then goto, done
	  if in eq 2 then goto, ploop
	  if in eq 3 then goto, sloop
	  if in eq 4 then begin
	    prnum = 1 + (prnum mod 2)
	    imenu(4) = 'Press here to change printer #.  Now = '+$
	      strtrim(prnum,2)
	    goto, dloop
	  endif
	  nimg = in - 4
	  wshow, 0, 0
	  print,' Printing FITS file . . .'
	  fitsps, file, set=nimg, printer=prnum, error=err
	  if err ne 0 then begin
	    bell
	    wshow, 0, 0
	    print, ' Press any key to continue'
	    txt = get_kbrd(1)
	  endif
	  goto, dloop
	endif
 
	;---  Use user provided procedure to process selected file. ---
	if in2 eq 6 then begin
	  wshow, 0, 0
	  print,' Processing image file '+getwrd(ff(in1))+$
	    ' using user routine '+userpro+' . . .'
	  x = execute(userpro+',"'+file+'"')
	  print,' Press any key'
	  txt = get_kbrd(1)
	  goto, ploop
	endif
 
done:	print,' Quitting'
	wshow, 0, 0
	return
 
	end

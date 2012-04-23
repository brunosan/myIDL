;+
; NAME:
;       FITSHDR
; PURPOSE:
;       Get or display FITS image header.
; CATEGORY:
; CALLING SEQUENCE:
;       fitshdr, file, hdr
; INPUTS:
;       file = FITS file name.  in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         ERROR=e  error flag: 0=ok, 1=file not found, 2=file not FITS. 
; OUTPUTS:
;       hdr = header.           out 
; COMMON BLOCKS:
;       last_header
; NOTES:
;       Note: if only file name is given then 
;         FITS header is displayed. 
; MODIFICATION HISTORY:
;       R. Sterner, 4 Mar, 1990
;-
 
	pro fitshdr, file, hdr, error=err, help=hlp
 
	common last_header, last_h
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get or display FITS image header.'
	  print,' fitshdr, file, hdr'
	  print,'   file = FITS file name.  in'
	  print,'   hdr = header.           out'
	  print,' Keywords:'
	  print,'   ERROR=e  error flag: 0=ok, 1=file not found,'
	  print,'     2=file not FITS.'
	  print,' Note: if only file name is given then'
	  print,'   FITS header is displayed.'
	  return
	endif
 
	on_ioerror, err
	get_lun, lun
	openr, lun, file, /block
	on_ioerror, err2
	hh = assoc(lun, bytarr(80,36))
	i = 0
	hdr = [' ']
loop:	tmp = string(hh(i))
	if i eq 0 then begin		; Header must start with SIMPLE = ...
	  if getwrd(tmp(0)) ne 'SIMPLE' then goto, err2
	endif
	hdr = [hdr,tmp]
	for j = 0, 35 do begin
	  t = getwrd(tmp(j),0)
	  if t eq 'END' then goto, next
	endfor
	i = i + 1
	goto, loop
next:	close, lun
	free_lun, lun
	hdr = hdr(1:*)
	if n_params(0) lt 2 then begin
	  openw,lun,'/dev/tty',/get_lun,/more
	  printf, lun, ' FITS header for file '+file+':'
	  for i=0, n_elements(hdr)-1 do if strtrim(hdr(i),2) ne '' then $
	     printf,lun,i,' ',hdr(i)
	  free_lun, lun
	endif
	err = 0
	last_h = hdr
	return
	
err:	print,' Error in fitshdr: File '+file+' not opened.'
	err = 1
	goto, done

err2:	print,' Error in fitshdr: file '+file+' not a FITS file.'
	err = 2
	goto, done

done:	close, lun
	free_lun, lun
	return
 
	end	

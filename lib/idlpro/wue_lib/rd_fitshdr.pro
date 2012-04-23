;+
; NAME:
;       RD_FITSHDR
; PURPOSE:
;       Get FITS image header.
; CATEGORY:
; CALLING SEQUENCE:
;       rd_fitshdr, lu, hdr
; INPUTS:
;       lu = logical unit of FITS file name.  in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         ERROR=e  error flag: 0=ok, 1=file not found, 2=file not FITS. 
; OUTPUTS:
;       hdr = header.           out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 4 Mar, 1990
;		T. Leighton, 29 Aug, 1990 modified fitshdr, input now lu instead
;					 of file name.  Won't display header, just returns it
;-
 
	pro rd_fitshdr, lu, hdr, help=hlp
 
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get FITS image header.'
	  print,' rd_fitshdr, lu, hdr'
	  print,'   lu = logical unit of FITS file name.  in'
	  print,'   hdr = header.           out'
	  print,' Keywords:'
	  print,'   ERROR=e  error flag: 0=ok, 1=file not found,'
	  print,'     2=file not FITS.'
	  return
	endif
 
	hh = assoc(lu, bytarr(80,36))
	i = 0
	hdr = [' ']
loop:	tmp = string(hh(i))
	if i eq 0 then begin				; Header must start with SIMPLE = ...
	  if getwrd(tmp(0)) ne 'SIMPLE' then goto, err2
	endif
	hdr = [hdr,tmp]
	for j = 0, 35 do begin
	  t = getwrd(tmp(j),0)
	  if t eq 'END' then goto, next
	endfor
	i = i + 1
	goto, loop
next:	hdr = hdr(1:*)
	return

err2:	print, ' Error: file not FITS file'
	err = 2
	return
	end	

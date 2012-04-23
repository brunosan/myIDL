;+
; NAME:
;       RD_BBSOHDR
; PURPOSE:
;       Get FITS image header.
; CATEGORY:
; CALLING SEQUENCE:
;       rd_bbsohdr, lu, hdr
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
;		T. Leighton, 14 Nov, 1990
;-
 
	pro rd_bbsohdr, lu, hdr, help=hlp
 
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Get FITS image header.'
	  print,' rd_bbsohdr, lu, hdr'
	  print,'   lu = logical unit of BBSOFITS file name.  in'
	  print,'   hdr = header.           out'
	  print,' Keywords:'
	  print,'   ERROR=e  error flag: 0=ok, 1=file not found,'
	  print,'     2=file not BBSOFITS.'
	  return
	endif
 
	hh = assoc(lu, bytarr(80,7))
	i = 0
	hdr = [' ']
loop:	tmp = string(hh(i))
	if i eq 0 then begin				; Header must start with SIMPLE = ...
	  if getwrd(tmp(0)) ne 'SIMPLE' then goto, err2
	endif
	hdr = [hdr,tmp]
	for j = 0, 6 do begin
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

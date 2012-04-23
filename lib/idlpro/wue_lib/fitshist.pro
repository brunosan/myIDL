;+
; NAME:
;       FITSHIST
; PURPOSE:
;       Return HISTORY record with given string from FITS header
; CATEGORY:
; CALLING SEQUENCE:
;       t = fitshist(w)
; INPUTS:
;       w = keyword to find in a HISTORY record.   in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         HEADER=h  FITS header in a string array.   in or out. 
;           Assumed input unless FILE is given, then output. 
;         FILE=f    Name of FITS file to examine.     in 
;         ERROR=e  error code: 0=ok, 1=keyword not found, 
;           2=no header specified, 3=file not opened, 4=file not FITS. 
; OUTPUTS:
;       t = returned HISTORY record.               out 
; COMMON BLOCKS:
; NOTES:
;       Notes: either HEADER or FILE may be given.  If both are 
;         given then FILE takes precedence and HEADER is an output. 
;         If neither is given then last header accessed is used if any. 
;         If the keyword occurs anywhere in a HISTORY record, then 
;         the entire HISTORY record is returned.  The first HISTORY 
;         record found with the given keyword is returned. 
; MODIFICATION HISTORY:
;	R. Sterner, 4 Apr, 1990
;-
 
	function fitshist, wrd, header=h, file=f, error=err, help=hlp
 
	common last_header, last_h
 
	if (n_params() lt 1) or keyword_set(hlp) then begin
	  print,' Return HISTORY record with given string from FITS header'
	  print,' t = fitshist(w)'
	  print,'   w = keyword to find in a HISTORY record.   in'
	  print,'   t = returned HISTORY record.               out'
	  print,' Keywords:'
	  print,'   HEADER=h  FITS header in a string array.   in or out.'
	  print,'     Assumed input unless FILE is given, then output.'
	  print,'   FILE=f    Name of FITS file to examine.     in'
	  print,'   ERROR=e  error code: 0=ok, 1=keyword not found,'
	  print,'     2=no header specified, 3=not opened, 4=not FITS.'
	  print,' Notes: either HEADER or FILE may be given.  If both are'
	  print,'   given then FILE takes precedence and HEADER is an output.'
	  print,'   If neither given last header accessed is used if any.'
	  print,'   If the keyword occurs anywhere in a HISTORY record, then'
	  print,'   the entire HISTORY record is returned.  The first HISTORY'
	  print,'   record found with the given keyword is returned.'
	  return, -1
	endif
 
	if n_elements(f) ne 0 then begin    ; FILE given?
	  fitshdr, f, h, err=e		    ; Yes, try to read header from it.
	  if e eq 2 then begin		    ; File not FITS.
	    err = 4
	    return, -1
	  endif
	  if e ne 0 then begin		    ; File read error.
	    print,' FITS file '+f+' not opened.'
	    err = 3
	    return, -1
	  endif
	endif else begin			   ; No FILE given.
	  if n_elements(h) eq 0 then begin	   ; No HEADER given.
	    if n_elements(last_h) eq 0 then begin  ; No last header available.
	      print,' No FITS header specified.'
	      err = 2
	      return, -1
	    endif				   ; Use last header.
	    h = last_h
	  endif
	endelse
 
	last_h = h				   ; Save current header.
	k = strupcase(wrd)			   ; Want upper case keyword.
	err = 0
	;----  Search for keyword in HISTORY rec, return rec if found.  -----
	for i = 0, n_elements(h)-1 do $
	  if getwrd(h(i),0) eq 'HISTORY' then begin
	  txt = strupcase(h(i))
	  if wordpos(txt, k) ge 0 then return, h(i) 
	endif
	err = 1
	return, -1
	end

;+
; NAME:
;       FITSHLINE
; PURPOSE:
;       Return selected rec from FITS header (by line # or keyword).
; CATEGORY:
; CALLING SEQUENCE:
;       r = fitshline([n])
; INPUTS:
;       n = header line number to return.    in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         KEY=k  keyword to search for instead of line number. 
;         HEADER=h  FITS header in a string array.   in or out. 
;           Assumed input unless FILE is given, then output. 
;         FILE=f    Name of FITS file to examine.     in 
;         ERROR=e  error code: 0=ok, 1=keyword not found, 
;           2=no header specified, 3=file not opened, 4=file not FITS. 
; OUTPUTS:
;       r = returned header record.          out 
; COMMON BLOCKS:
;       last_header
; NOTES:
;       Notes: either HEADER or FILE may be given.  If both are 
;         given then FILE takes precedence and HEADER is an output. 
;         If neither is given then last header accessed is used if any. 
; MODIFICATION HISTORY:
;	R. Sterner, 6 Apr, 1990
;-
 
	function fitshline, num,key=wrd,header=h,file=f,error=err,help=hlp
 
	common last_header, last_h
 
	if keyword_set(hlp) then begin
	  print,' Return selected rec from FITS header (by line # or keyword).'
	  print,' r = fitshline([n])'
	  print,'   n = header line number to return.    in'
	  print,'   r = returned header record.          out'
	  print,' Keywords:'
	  print,'   KEY=k  keyword to search for instead of line number.'
	  print,'   HEADER=h  FITS header in a string array.   in or out.'
	  print,'     Assumed input unless FILE is given, then output.'
	  print,'   FILE=f    Name of FITS file to examine.     in'
	  print,'   ERROR=e  error code: 0=ok, 1=keyword not found,'
	  print,'     2=no header specified, 3=not opened, 4=not FITS.'
	  print,' Notes: either HEADER or FILE may be given.  If both are'
	  print,'   given then FILE takes precedence and HEADER is an output.'
	  print,'   If neither given last header accessed is used if any.'
	  return, -1
	endif
 
	;-------  if FILE given try to read it  ------------
	if n_elements(f) ne 0 then begin    ; FILE given?
	  fitshdr, f, h, err=e		    ; Yes, try to read header from it.
	  if e eq 2 then begin
	    err = 4
	    return, -1
	  endif
	  if e ne 0 then begin		    ; File read error.
	    print,' FITS file '+f+' not opened.'
	    err = 3
	    return, -1
	  endif
	;--------  Try to use last header  --------------
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
 
	;------  Save last header  ---------
	last_h = h			 	   ; Save current header.
 
	;------ Use line number  --------------
	if n_params(0) ge 1 then begin
	  return, h(num)
	endif
 
	;-------  Use keyword  ------------
	k = strupcase(wrd)			   ; Want upper case keyword.
	err = 0
	;----  Search for keyword, return value if found.  --------
	for i = 0, n_elements(h)-1 do if k eq getwrd(h(i),0) then begin
	  return, h(i)
	endif
 
	;---------  Keyword not found  ---------
	err = 1
	return, -1
	end

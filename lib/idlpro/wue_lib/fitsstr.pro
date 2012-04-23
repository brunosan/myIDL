;+
; NAME:
;       FITSSTR
; PURPOSE:
;       Return a specified string from a FITS header
; CATEGORY:
; CALLING SEQUENCE:
;       s = fitsstr(w,[c])
; INPUTS:
;       w = keyword in header.               in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         HEADER=h  FITS header in a string array.   in or out. 
;           Assumed input unless FILE is given, then output. 
;         FILE=f    Name of FITS file to examine.     in 
;         ERROR=e  error code: 0=ok, 1=keyword not found, 
;           2=no header specified, 3=file not opened, 4=file not FITS. 
; OUTPUTS:
;       s = returned string.                 out 
;	c = optioanlly returned comment.     out
; COMMON BLOCKS:
;       last_header
; NOTES:
;       Notes: either HEADER or FILE may be given.  If both are 
;         given then FILE takes precedence and HEADER is an output. 
;         If neither is given then last header accessed is used if any. 
; MODIFICATION HISTORY:
;       R. Sterner, 4 Mar, 1990
;-
 
	function fitsstr, wrd, comm, header=h, file=f, error=err, help=hlp
 
	common last_header, last_h
 
	if (n_params() lt 1) or keyword_set(hlp) then begin
	  print,' Return a specified string from a FITS header'
	  print,' s = fitsstr(w, [c])'
	  print,'   w = keyword in header.               in'
	  print,'   s = returned string.                 out'
	  print,'   c = optionally returned comment.     out'
	  print,' Keywords:'
	  print,'   HEADER=h  FITS header in a string array.   in or out.'
	  print,'     Assumed input unless FILE is given, then output.'
	  print,'   FILE=f    Name of FITS file to examine.     in'
	  print,'   ERROR=e  error code: 0=ok, 1=keyword not found,'
	  print,'     2=no header given, 3=file not opened, 4=file not FITS.'
	  print,' Notes: either HEADER or FILE may be given.  If both are'
	  print,'   given then FILE takes precedence and HEADER is an output.'
	  print,'   If neither given last header accessed is used if any.'
	  return, -1
	endif
 
	if n_elements(f) ne 0 then begin		; FILE given?
	  fitshdr, f, h, err=e				; Yes, read header.
	  if e eq 2 then begin				; File not FITS.
	    err = 4
	    return, -1
	  endif
	  if e ne 0 then begin				; File read error.
	    print,' FITS file '+f+' not opened.'
	    err = 3
	    return, -1
	  endif
	endif else begin				; No FILE given.
	  if n_elements(h) eq 0 then begin		; No HEADER given.
	    if n_elements(last_h) eq 0 then begin	; No last hdr.
	      print,' No FITS header specified.'
	      err = 2
	      return, -1
	    endif					; Use last header.
	    h = last_h
	  endif
	endelse
 
	last_h = h					; Save current header.
	k = strupcase(wrd)				; Want upcase keyword.
	err = 0
	;----  Search for keyword, return value if found.  --------
	for i = 0, n_elements(h)-1 do if k eq getwrd(h(i),0) then begin
	  txt = h(i)
	  l = strpos(txt, '/')
	  comm = ''
	  if l ge 0 then comm = strmid(txt, l+1, 80)
	  out = getwrd(txt,1,delim="'")
	  if out eq '' then begin
	    txt = repchr(txt,'=')
	    out = getwrd(txt,1)
	    print,' Warning in fitsstr: non-standard fits header.'
	  endif
	  return, out
	endif
	err = 1
	return, -1
	end

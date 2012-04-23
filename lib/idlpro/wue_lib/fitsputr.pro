;+
; NAME:
;       FITSPUTR
; PURPOSE:
;       Put an real keyword and value into a FITS header.
; CATEGORY:
; CALLING SEQUENCE:
;       fitsputr, hdr, key, val, [comm]
; INPUTS:
;       key = FITS keyword.                            in 
;       val = keyword real value.                      in 
;       comm = optional FITS header line comment.      in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /UPDATE means replace existing value of keyword. 
;         ERROR=err.  Error flag: 0=ok, 1=invalid FITS header, 
;           2=keyword not found for update. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 12 Mar, 1990
;-
 
	pro fitsputr, hdr, key, val, comm, error=err, help=hlp, update=update
 
	if (n_params(0) lt 3) or keyword_set(hlp) then begin
	  print,' Put an real keyword and value into a FITS header.'
	  print,' fitsputr, hdr, key, val, [comm]'
	  print,'   hdr = an existing FITS hdr as a string array.  in,out'
	  print,'   key = FITS keyword.                            in'
	  print,'   val = keyword real value.                      in'
	  print,'   comm = optional FITS header line comment.      in'
	  print,' Keywords:'
	  print,'   /UPDATE means replace existing value of keyword.'
	  print,'   ERROR=err.  Error flag: 0=ok, 1=invalid FITS header,'
	  print,'     2=keyword not found for update.'
	  return
	endif
 
	if n_params(0) lt 4 then comm = ''
 
	;--------  header check  --------------
	lh = n_elements(hdr)-1
	for i = 0, lh do begin
	  if strtrim(hdr(i),2) eq 'END' then goto, next
	endfor
 
	;------  Not FITS header  -------------
	print,' Error in fitsputr: invalid FITS header.'
	err = 1
	return
 
 
	;-------  FITS ok, check if update  --------------
next:	if keyword_set(update) then begin
	  k = strupcase(key)
	  for i = 0, lh do begin
	    if k eq getwrd(hdr(i),0) then begin
	      if comm eq '' then x = fitsnum(head=hdr,k,comm)
	      print,' Updating FITS header . . .'
	      hdr(i) = fitstxtr(k,val,comm)
	      err = 0
	      return
	    endif
	  endfor
	  print,' Error in fitsputr: keyword not found for update.'
	  err = 2
	  return
	endif
 
	;-------  not update, add new  --------
	new = fitstxtr(key, val, comm)
 
	;--------- insert new line  --------
	if i eq 0 then begin
	  hdr = [new, 'END']
	endif else begin
	  hdr = [hdr(0:i-1),new,'END']
	endelse
 
	;--------  no error  ----------
	err = 0
	return
	end

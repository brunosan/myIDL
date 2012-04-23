;+
; NAME:
;       FITSPUTCOM
; PURPOSE:
;       Put a comment into a FITS header.
; CATEGORY:
; CALLING SEQUENCE:
;       fitsputcom, hdr, comm
; INPUTS:
;       comm = comment text.                           in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         ERROR=err.  Error flag: 0=ok, 1=invalid FITS header. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 12 Mar, 1990
;	R. Sterner, 26 Feb, 1991 --- Renamed from fitsputcomm.pro
;-
 
	pro fitsputcom, hdr, val, error=err, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Put a comment into a FITS header.'
	  print,' fitsputcom, hdr, comm'
	  print,'   hdr = an existing FITS hdr as a string array.  in,out'
	  print,'   comm = comment text.                           in'
	  print,' Keywords:'
	  print,'   ERROR=err.  Error flag: 0=ok, 1=invalid FITS header.'
	  return
	endif
 
	if n_params(0) lt 4 then comm = ''
	new = fitstxtcom(val)
 
	for i = 0, n_elements(hdr)-1 do begin
	  if strtrim(hdr(i),2) eq 'END' then goto, next
	endfor
 
	print,' Error in fitsputcom: invalid FITS header.'
	err = 1
	return
 
next:	if i eq 0 then begin
	  hdr = [new, 'END']
	endif else begin
	  hdr = [hdr(0:i-1),new,'END']
	endelse
 
	err = 0
	return
	end
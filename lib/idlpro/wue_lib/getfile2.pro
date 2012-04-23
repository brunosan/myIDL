;+
; NAME:
;       GETFILE2
; PURPOSE:
;       Read a text file into a string array.
; CATEGORY:
; CALLING SEQUENCE:
;       s = getfile2(f)
; INPUTS:
;       f = text file name.      in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         ERROR=err  error flag: 0=ok, 1=file not opened. 
; OUTPUTS:
;       s = string array.        out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 20 Mar, 1990
;       G. Jung, 15 Dec, 1992 -renamed from getfile.pro
;-
 
	function getfile2, file, error=err, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Read a text file into a string array.'
	  print,' s = getfile2(f)'
	  print,'   f = text file name.      in'
	  print,'   s = string array.        out'
	  print,' Keywords:'
	  print,'   ERROR=err  error flag: 0=ok, 1=file not opened.'
	  return, -1
	endif
 
	get_lun, lun
	on_ioerror, err
	openr, lun, file
 
	s = [' ']
	t = ''
 
	while not eof(lun) do begin
	  readf, lun, t
	  s = [s,t]
	endwhile
 
	close, lun
	free_lun, lun
	err = 0
	return, s(1:*)
 
err:	if !err eq -168 then begin
	  print,' Non-standard text file format.'
	  free_lun, lun
	  return, s(1:*)
	endif
	print,' Error in getfile2: File '+file+' not opened.'
	free_lun, lun
	err = 1
	return, -1
 
	end

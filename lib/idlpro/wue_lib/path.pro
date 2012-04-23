;+
; NAME:
;       PATH
; PURPOSE:
;       Examine and modify the IDL path.
; CATEGORY:
; CALLING SEQUENCE:
;       path, new
; INPUTS:
;       new = new path name to add to existing path.     in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /LAST forces new path to be added to end of existing 
;            path instead of front which is default. 
;         /LIST displays a numbered list of all the paths. 
;         /RESET restores initial path (found on first call). 
; OUTPUTS:
; COMMON BLOCKS:
;       path_com
; NOTES:
;       Notes: can use paths like ../xxx as a shortcut. 
;         Useful to turn on & off libraries of IDL routines. 
; MODIFICATION HISTORY:
;       R. Sterner, 20 Sep, 1989
;-
 
	pro path, in, help=hlp, last=aftr, reset=rst, list=lst
 
	common path_com, firstpath
 
	if keyword_set(hlp) then begin
	  print,' Examine and modify the IDL path.'
	  print,' path, new'
	  print,'   new = new path name to add to existing path.     in'
	  print,' Keywords:'
	  print,'   /LAST forces new path to be added to end of existing'
	  print,'      path instead of front which is default.'
	  print,'   /LIST displays a numbered list of all the paths.'
	  print,'   /RESET restores initial path (found on first call).'
	  print,' Notes: can use paths like ../xxx or [-.xxx] as a shortcut.'
	  print,'   Useful to turn on & off libraries of IDL routines.'
	  return
	endif
 
	if n_elements(firstpath) eq 0 then firstpath = !path

	if !version.os eq 'vms' then begin
	  delim = ','
	endif else begin
	  delim = ':'
	endelse

	if n_params(0) gt 0 then begin
	  if keyword_set(aftr) then begin
	    !path = !path + delim + in	
	  endif else begin
	    !path = in + delim + !path
	  endelse
	endif
 
	if keyword_set(rst) then begin
	  !path = firstpath
	endif
 
	if keyword_set(lst) then begin
	  txt = repchr(!path,delim)
	  for i = 0, nwrds(txt)-1 do begin
	    print,i+1,'  ',getwrd(txt,i)
	  endfor
	endif
 
	return
	end

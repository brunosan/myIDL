;+
; NAME:
;       GETDEFDIR
; PURPOSE:
;       Gets default directory from env var or log name DEF_DIR.
; CATEGORY:
; CALLING SEQUENCE:
;       getdefdir, dir
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         /NEW prompts for directory, uses default if none entered.
; OUTPUTS:
;       dir = default directory to use.   out
; COMMON BLOCKS:
;       defdircom
; NOTES:
;       Notes: Returned directory ends with a slash (/) if UNIX.
;         VMS: to use current dir., enter a space.
; MODIFICATION HISTORY:
;       R. Sterner, 26 Mar, 1990
;       R. Sterner, 30 May, 1990 --- converted to VMS.
;       R. Sterner, 26 Feb, 1991 --- Renamed from get_def_dir.pro
;-
 
	pro getdefdir, dir, help=hlp, new=new
 
	common defdircom, ddir
 
	if keyword_set(hlp) then begin
	  print,' Gets default directory from env var or log name DEF_DIR.'
	  print,' getdefdir, dir'
	  print,'   dir = default directory to use.   out'
	  print,' Keywords:'
	  print,'   /NEW prompts for directory, uses default if none entered.'
	  print,' Notes: Returned directory ends with a slash (/) if UNIX.'
	  print,'   VMS: to use current dir., enter a space.'
	  return
	endif
 
	if n_elements(ddir) eq 0 then begin	; Initialize default directory.
	  if !version.os ne 'vms' then begin
	    print,' Reading default data directory from the environmental'
	    print,' variable DEF_DIR.  Use set_env DEF_DIR directory_name'
	    print,' in your .cshrc file to set.'
	  endif else begin
	    print,' Reading default data directory from the logical name'
	    print,' DEF_DIR.  Use DEF/JOB DEF_DIR directory_name'
	    print,' in your LOGIN.COM file to set.'
	  endelse
	  print,' '
	  ddir = getenv('DEF_DIR')
	endif
 
 
	dir = ddir			; try to use default directory.
 
	if keyword_set(new) then begin	; Keyboard entry of default directory.
	  print,' '
	  if strtrim(ddir,2) eq '' then begin
	    read,' Enter data directory (default = current ): ', dir
	  endif else begin
	    read,' Enter data directory (default = '+ddir+' ): ', dir
	  endelse
	  if dir eq '' then dir = ddir
	  dir = strtrim(dir,2)
	  if dir eq '' then print,' Using current directory' $
	    else print,' Using directory '+dir
	  ddir = dir			; remember new default directory.
	endif
 
	if !version.os ne 'vms' then begin
	  if dir ne '' then dir = dir + '/'
	endif
 
	return
 
	end

;+
; NAME:
;       FILENAME
; PURPOSE:
;       File names with system independent symbolic directories.
; CATEGORY:
; CALLING SEQUENCE:
;       f = filename(symdir, name)
; INPUTS:
;       symdir = symbolic directory name.   in
;       name = file name.                   in
; KEYWORD PARAMETERS:
;	/NOSYM means directory given is not a symbolic name.
; OUTPUTS:
;       f = file name including directory.  out
; COMMON BLOCKS:
; NOTES:
;       Notes: symdir is a logical name for VMS and
;         an environmental variable for UNIX.  Ex:
;         DEFINE IDLUSR d0:[publib.idl]  for VMS
;         setenv IDLUSR /usr/pub/idl     for UNIX.
;         Then in IDL: f=filename('IDLUSR','tmp.tmp')
;         will be the name of the file tmp.tmp in IDLUSR.
; MODIFICATION HISTORY:
;       R. Sterner, 4 Feb, 1991
;	R. Sterner, 27 Mar, 1991 --- added /NOSYM
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
 
	function filename, symdir, name, help=hlp, nosym=nosym
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' File names with system independent symbolic directories.'
	  print,' f = filename(symdir, name)'
	  print,'   symdir = symbolic directory name.   in'
	  print,'   name = file name.                   in'
	  print,'   f = file name including directory.  out'
	  print,' Keywords:'
	  print,'   /NOSYM means directory given is not a symbolic name.'
	  print,' Notes: symdir is a logical name for VMS and'
	  print,'   an environmental variable for UNIX.  Ex:'
	  print,'   DEFINE IDLUSR d0:[publib.idl]  for VMS'
	  print,'   setenv IDLUSR /usr/pub/idl     for UNIX.'
	  print,"   Then in IDL: f=filename('IDLUSR','tmp.tmp')"
	  print,'   will be the name of the file tmp.tmp in IDLUSR.'
	  return, -1
	endif
 
	case !version.os of
'vms':	   begin
	     t = name
	     if symdir ne '' then begin
	       if not keyword_set(nosym) then t = ':'+t
	       t = symdir + t
	     endif 
	     return, t
	   end
'sunos':   begin
	    t = name
	    if symdir ne '' then begin
	      t = symdir+'/'+name
	      if not keyword_set(nosym) then t = '$'+t
	    endif
	    return, t
	   end
else:	   begin
	     print,' Error in FILENAME: operating system unknown'
	     print,'!version.os
	     return, -1
	   end
	endcase
 
	end


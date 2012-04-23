pro cdl,string
;+
; NAME:
;       CDL
; PURPOSE:
;       Change current working directory and list it's content (ls -FA).
;*CATEGORY:            @CAT-# 40 28@
;       Operating System Access , Programming
; CALLING SEQUENCE:
;       CDL [,directory]
; INPUTS:
;       none
; OPTIONAL INPUT PARAMETERS:
;       directory : string, directory to be made current working directory;
;                   if a "null"-string (cdl,''), the home directory
;                   will become current; if omitted, the working directory
;                   will not be changed.
; KEYWORD PARAMETERS:
; OUTPUTS:
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
;       changes current working directory (if so specified);
;       prints contents of new directory to standard-out (ls -Fa)
;       and the directory-name incl. it's full path.
; RESTRICTIONS:
; PROCEDURE:
;       calls CD (IDL ROUTINES), spawns UNIX command "ls -FA", 
;       calls PRINTD (IDL USERLIB).
; MODIFICATION HISTORY:
;       1993-Mar-12 nlte (KIS) created.
;-

on_error,1
if n_params() eq 1 then $
   if (size(string))(0) eq 0 and (size(string))(1) eq 7 then cd,string $
   else message,'argument must be a scalar string' $
else cd   ; do not change directory
spawn,'ls -FA'
printd
end



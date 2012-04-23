pro ll,string,t=t
;+
; NAME:
;       LL
; PURPOSE:
;       Long List of the contents of the current working directory
;       in alphabetic order or sorted by time of last modification
;       (latest last).
;*CATEGORY:            @CAT-# 40 28@
;       Operating System Access , Programming
; CALLING SEQUENCE:
;       LL [,directory] [,/T]
; INPUTS:
; OPTIONAL INPUT PARAMETERS:
;       directory : string, directory to be listed; 
;                   default: current working directory.
; KEYWORD PARAMETERS:
;       /T        : if set, the contents is  sorted by time of last 
;                   modification (latest last); if not set, the list
;                   will be in alphabetic order.
; OUTPUTS:
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
;       Output on standard-out.
; RESTRICTIONS:
; PROCEDURE:
;       spawns UNIX command "ls -lFAg <directory>" or (if /T set):
;                           "ls -ltrFAg <directory>"
; MODIFICATION HISTORY:
;       1993-Mar-12 nlte (KIS) created.
;-
on_error,1
if keyword_set(t) then command='ls -ltrFAg ' else command='ls -lFAg '
if n_params() eq 1 then command=command+string
spawn,command
end

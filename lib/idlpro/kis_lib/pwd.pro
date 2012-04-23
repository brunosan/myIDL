pro pwd
;+
; NAME:
;       PWD
; PURPOSE:
;       Print the name of current working directory incl. it's full path
;       (simulates UNIX command pwd).
;*CATEGORY:            @CAT-# 40 28@
;       Operating System Access , Programming
; CALLING SEQUENCE:
;       PWD
; INPUTS:
;       none
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       none
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
;       1 print line to standard out.
; RESTRICTIONS:
; PROCEDURE:
;       CD, CURRENT=current  ; CD is an IDL routine.
; MODIFICATION HISTORY:
;       1993-Mar-15 nlte (KIS) created.
;-

CD, CURRENT=current
print, current

end

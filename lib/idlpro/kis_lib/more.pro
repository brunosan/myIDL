PRO more,file
;+
; NAME:
;       MORE
; PURPOSE:
;       Reads contents of an ASCII file & prints it on screen with 
;       UNIX command MORE .
;*CATEGORY:            @CAT-# 14 42 40@
;       I/O , Files , Operating System Access
; CALLING SEQUENCE:
;       MORE, file
; INPUTS:
;       file  : string, the name of the ASCII file to be read.
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
; OUTPUTS:
;       none
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
;       prints file on screen via UNIX MORE
; RESTRICTIONS:
; PROCEDURE:
;       spawns more.
; MODIFICATION HISTORY:
;       1992-Jan-16 nlte (KIS) created.
;       1993-Mar-15 nlte (KIS) documentation.
;-
on_error,1

cmnd='more '+file
spawn,cmnd
end

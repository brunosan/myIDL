FUNCTION blnk2ulin,strein
;+
; NAME:
;	BLNK2ULIN
; PURPOSE:
;	Converts all blanks within character-string strein to _
;*CATEGORY:            @CAT-# 35@
;	String Processing Routines
; CALLING SEQUENCE:
;	out_string = BLNK2ULIN(input_string)
; INPUTS:
;	input_string : string to be converted.
; OUTPUTS:
;	converted string.
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	none
; RESTRICTIONS:
;	none
; PROCEDURE:
;	straight
; MODIFICATION HISTORY:
;	nlte, 1990-03-17
;	nlte, 1992-05-06 : on_error,1 
;-
on_error,1
straus=strcompress(strtrim(strein,2))
if strlen(straus) lt 1 then straus='_' else begin
jmp:   pos=strpos(straus,' ')
	if pos lt 0 then goto,ret
	strput,straus,'_',pos
	goto,jmp
     endelse
ret: return,straus
end

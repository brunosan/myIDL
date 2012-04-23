;+
; NAME:
;       SHOW_BOX
; PURPOSE:
;       Used by MOVBOX to display current box size and position.
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  26 July, 1989.
;-
 
	PRO SHOW_BOX, X, Y, DX, DY, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Used by MOVBOX to display current box size and position.'
	  return
	endif
 
	X2 = X + DX - 1			; Upper right box corner.
	Y2 = Y + DY - 1
 
	PRINT,'     array('+STRTRIM(X,2)+':'+STRTRIM(X2,2)+','+STRTRIM(Y,2)+$
	  ':'+STRTRIM(Y2,2)+')'+'  box size: '+STRTRIM(DX,2)+$
	  ' X '+STRTRIM(DY,2)
 
	RETURN
	END

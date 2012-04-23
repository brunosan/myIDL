;+
; NAME:
;       FIXGAPS
; PURPOSE:
;       Linearly interpolate across data gaps in an array.
; CATEGORY:
; CALLING SEQUENCE:
;       fixgaps, a, tag, [eflag]
; INPUTS:
;       tag = value in data gaps.                    in 
;       eflag = flag: if no-zero then fix any        in
;         gap at end of data by replicating last good
;         value. 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       a = array to process.                        in, out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,   6 Mar, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES, 16 Dec, 1987 --- added eflag.
;-
 
	PRO FIXGAPS,A,TAG,EFLAG, help=hlp
 
	IF (N_PARAMS(0) LT 2) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Linearly interpolate across data gaps in an array.'
	  PRINT,' fixgaps, a, tag, [eflag]'
	  print,'   a = array to process.                        in, out'
	  print,'   tag = value in data gaps.                    in'
	  print,'   eflag = flag: if no-zero then fix any        in
	  PRINT,'     gap at end of data by replicating last good
	  PRINT,'     value.'
	  RETURN
	ENDIF
 
	IF N_PARAMS(0) LT 3 THEN EFLAG = 0
 
	S = SIZE(A)
	NR = S(S(0))
 
	FOR I = 0L, NR-1 DO BEGIN	; search for start of a gap.
 
	  IF A(I) EQ TAG THEN BEGIN	; found one.
	    I1 = I - 1   		; last good value before gap.
 
	    FOR J = I+1, NR-1 DO BEGIN	; search for end of gap.
	      IF A(J) NE TAG THEN BEGIN ; found it.
	        I2 = J			; first good value after gap.
	        GOTO, FIX		; go fix gap.
	      ENDIF
	    ENDFOR ; J.
 
	    IF EFLAG EQ 0 THEN BEGIN
	      PRINT,'Error: gap to end of data. Not fixed.'
	      GOTO, DONE
	    ENDIF ELSE BEGIN
	      T = A(I1)			; Last good value.
	      FOR J = I1, NR-1 DO A(J) = T
	      PRINT,'Warning: gap to end of data filled with last good value.'
	      GOTO, DONE
	    ENDELSE
 
FIX:	    LINFILL, A, I1, I2
	    I = I2
	  ENDIF
 
	ENDFOR  ; I.
 
DONE:	RETURN
 
	END

;+
; NAME:
;       ADD_MARGIN
; PURPOSE:
;       Add space to left margin and top of a text file.
; CATEGORY:
; CALLING SEQUENCE:
;       add_margin, in, out, n_left, [n_top]
; INPUTS:
;       in = Input file.                                    in.
;       n_left = Number of spaces to add to left margin.    in.
;       n_top = number of blank lines to add to top.        in.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = Output file.                                  out.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Written by R. Sterner, 3 Mar, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 17 Sep, 1989 --- converted to SUN.
;-
 
	PRO ADD_MARGIN, IN, OUT, N_LEFT, N_TOP, help=hlp
 
	NP = N_PARAMS(0)
	IF (NP EQ 0) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Add space to left margin and top of a text file.
	  PRINT,' add_margin, in, out, n_left, [n_top]
	  PRINT,'   in = Input file.                                    in.
	  PRINT,'   out = Output file.                                  out.
	  PRINT,'   n_left = Number of spaces to add to left margin.    in.
	  PRINT,'   n_top = number of blank lines to add to top.        in.
	  RETURN
	ENDIF
 
	IF NP LT 4 THEN N_TOP = 0
	IF NP LT 3 THEN N_LEFT = 0
 
	GET_LUN,LUN1
	GET_LUN,LUN2
 
	ON_IOERROR, ERR1
	OPENR,LUN1,IN
	ON_IOERROR, ERR2
	OPENW,LUN2,OUT
	ON_IOERROR, NULL
 
	TXT = ''
;------------  Add or remove top margin  --------------
	IF N_TOP LT 0 THEN FOR I = 1, -N_TOP DO READF, LUN1, TXT
	IF N_TOP GT 0 THEN FOR I = 1, N_TOP DO PRINTF, LUN2, ' '
 
;------------  do left margin  -------------------------
	IF N_LEFT GE 0 THEN MAR = SPC(N_LEFT)
 
	WHILE NOT EOF(LUN1) DO BEGIN
	  READF,LUN1,TXT
	  IF TXT EQ '' THEN TXT = ' '
	  IF N_LEFT GE 0 THEN PRINTF, LUN2, MAR + TXT
	  IF N_LEFT LT 0 THEN BEGIN
	    B = BYTE(TXT)
	    IF N_ELEMENTS(B) GT (-N_LEFT) THEN BEGIN
	      PRINTF, LUN2, STRING(B((-N_LEFT):*))
	    ENDIF ELSE BEGIN
	      PRINTF, LUN2, ' '
	    ENDELSE
	  ENDIF
	ENDWHILE
 
DONE:	CLOSE,LUN1
	FREE_LUN,LUN1
	CLOSE,LUN2
	FREE_LUN,LUN2
 
	RETURN
 
;-----------------  ERRORS  ---------------
ERR1:	PRINT,'Error opening file '+IN
	GOTO, DONE
ERR2:	PRINT,'Error opening file '+OUT
	GOTO, DONE
 
	END

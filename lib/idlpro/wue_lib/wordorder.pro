;+
; NAME:
;       WORDORDER
; PURPOSE:
;       Re-arrange words in a text string.
; CATEGORY:
; CALLING SEQUENCE:
;       NEW = WORDORDER( OLD, ORDER)
; INPUTS:
;       OLD = input text string. Words delimited by spaces.      in 
;       ORDER = array of word numbers.  Indicates                in 
;               order of words in NEW.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       NEW = resulting text string.  Any multiple spaces        out 
;             will be squeezed to single spaces.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  29 Oct, 1986.
;       R. Sterner 27 Dec, 1989 --- converted to SUN.
;-
 
	FUNCTION WORDORDER, OLD, ORDER, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Re-arrange words in a text string.
	  print,' NEW = WORDORDER( OLD, ORDER)
	  print,'   OLD = input text string. Words delimited by spaces.   in'
	  print,'   ORDER = array of word numbers.  Indicates             in'
	  print,'           order of words in NEW.
	  print,'   NEW = resulting text string.  Any multiple spaces     out'
	  print,'         will be squeezed to single spaces.
	  return, -1
	endif
 
	N = N_ELEMENTS(ORDER)
	IF N EQ 0 THEN RETURN, ''
	NEW = GETWRD(OLD, ORDER(0))
	IF N EQ 1 THEN RETURN, NEW
	FOR I = 1, N-1 DO NEW = NEW + ' ' + GETWRD(OLD, ORDER(I))
	RETURN, strcompress(NEW)
	END

;+
; NAME:
;       FNDWRD
; PURPOSE:
;       Find number, locations, and lengths of words in a text string.
; CATEGORY:
; CALLING SEQUENCE:
;       fndwrd, txt, nwds, loc, len
; INPUTS:
;       txt = text string to examine.                    in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       nwds = number of words found in txt.             out 
;       loc = array of word start positions (0=first).   out 
;       len = array of word lengths.                     out 
; COMMON BLOCKS:
; NOTES:
;       Note: Words must be separated by spaces. 
; MODIFICATION HISTORY:
;       Ray. Sterner,  11 Dec, 1984.
;       RES  Handle null strings better.   16 Feb, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;-
 
	PRO FNDWRD,TXTSTR,NWDS,LOC,LEN, help=hlp
 
	if (n_params(0) lt 4) or keyword_set(hlp) then begin
	  print,' Find number, locations, lengths of words in a text string.'
	  print,' fndwrd, txt, nwds, loc, len'
	  print,'    txt = text string to examine.                    in'
	  print,'    nwds = number of words found in txt.             out'
	  print,'    loc = array of word start positions (0=first).   out'
	  print,'    len = array of word lengths.                     out'
	  print,' Note: Words must be separated by spaces.'
	  return
	endif
 
	IF TXTSTR EQ '' THEN BEGIN
	  NWDS = 0
	  LOC = INTARR(1)-1
	  LEN = LOC
	  RETURN
	ENDIF
	X = BYTE(TXTSTR) NE 32
	X = [0,X,0]
 
	Y = (X-SHIFT(X,1)) EQ 1
	Z = WHERE(SHIFT(Y,-1) EQ 1)
	Y2 = (X-SHIFT(X,-1)) EQ 1
	Z2 = WHERE(SHIFT(Y2,1) EQ 1)
 
	NWDS = fix(TOTAL(Y))
	LOC = Z
	LEN = Z2 - Z - 1
 
	RETURN
 
	END

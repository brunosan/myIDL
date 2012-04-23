;+
; NAME:
;       NPHRASES
; PURPOSE:
;       Return the number of phrases in the given text string.
; CATEGORY:
; CALLING SEQUENCE:
;       n = nphrases(txt)
; INPUTS:
;       txt = text string to examine.             in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         DELIMITERS = d.  Set phrase delimiter character (def = comma). 
; OUTPUTS:
;       n = number of phrases found.              out 
; COMMON BLOCKS:
; NOTES:
;	Notes: See also getphrase, nwrds.
; MODIFICATION HISTORY:
;       R. Sterner, 4 Feb, 1990
;-
 
	FUNCTION Nphrases,TXTSTR, help=hlp, delimiter=delim
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return the number of phrases in the given text string.'
	  print,' n = nphrases(txt)'
	  print,'   txt = text string to examine.             in'
	  print,'   n = number of phrases found.              out'
	  print,' Keywords:'
	  print,'   DELIMITERS = d.  Set phrase delimiter character (def = comma).'
	  print,' Notes: See also getphrase, nwrds.'
	  return, -1
	endif
 
	IF STRLEN(TXTSTR) EQ 0 THEN RETURN,0
	ddel = ','
	if n_elements(delim) ne 0 then ddel = delim
	tst = (byte(ddel))(0)
	X = BYTE(TXTSTR) NE tst
	X = [0,X,0]
 
	Y = (X-SHIFT(X,1)) EQ 1
 
	N = fix(TOTAL(Y))
 
	RETURN, N
 
	END

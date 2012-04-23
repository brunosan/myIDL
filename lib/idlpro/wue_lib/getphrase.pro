;+
; NAME:
;       GETPHRASE
; PURPOSE:
;       Return the n'th phrase from a text string.
; CATEGORY:
; CALLING SEQUENCE:
;       ph = getwrd(txt, n, [m])
; INPUTS:
;       txt = text string to extract from.         in 
;       n = phrase number to get (first = 0).      in 
;       m = optional last phrase number to get.    in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         DELIMITER = d.  Set phrase delimiter character (def = comma). 
;         LOCATION = l.  Return phrase n string location. 
; OUTPUTS:
;       ph = returned phrase or phrases.           out 
; COMMON BLOCKS:
; NOTES:
;       Note: if m > n then ph will be a string of phrases from phrase n to 
;             phrase m.  If no m is given then ph will be a single phrase. 
;             If n<0 then returns text starting at phrase abs(n) to end of string. 
;             If n is out of range then a null string is returned. 
;	      See also getwrd, nphrases.
; MODIFICATION HISTORY:
;       R. Sterner, 4 Feb, 1990
;-
 
	FUNCTION GETphrase,TXTSTR,NTH,MTH,help=hlp, location=ll, delimiter=delim
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print," Return the n'th phrase from a text string."
	  print,' ph = getwrd(txt, n, [m])'
	  print,'   txt = text string to extract from.         in'
	  print,'   n = phrase number to get (first = 0).      in'
	  print,'   m = optional last phrase number to get.    in'
	  print,'   ph = returned phrase or phrases.           out'
	  print,' Keywords:'
	  print,'   DELIMITER = d.  Set phrase delimiter character (def = comma).'
	  print,'   LOCATION = l.  Return phrase n string location.'
	  print,'Note: if m > n then ph will be a string of phrases from phrase n to'
	  print,'      phrase m.  If no m is given then ph will be a single phrase.'
	  print,'      If n<0 then returns text starting at phrase abs(n) to end of string.'
	  print,'      If n is out of range then a null string is returned.'
	  print,'      See also getwrd, nphrases.'
	  return, -1
	endif
 
	IF N_PARAMS(0) LT 3 THEN MTH = NTH	; def is one phrase.
	ddel = ','				; Default delimiter is a comma.
	if n_elements(delim) ne 0 then ddel = delim
	TST = (byte(ddel))(0)			; delimiter as byte.
	X = BYTE(TXTSTR) NE TST			; non-space chars.
	X = [0,X,0]				; tack 0s at ends.
 
	Y = (X-SHIFT(X,1)) EQ 1			; look for transitions.
	Z = WHERE(SHIFT(Y,-1) EQ 1)
	Y2 = (X-SHIFT(X,-1)) EQ 1
	Z2 = WHERE(SHIFT(Y2,1) EQ 1)
 
	NWDS = TOTAL(Y)
	LOC = Z
	LEN = Z2 - Z - 1
 
	N = ABS(NTH)
	IF N GT NWDS-1 THEN RETURN,''
	ll = loc(n)
	IF NTH LT 0 THEN GOTO, NEG
	IF MTH GT NWDS-1 THEN MTH = NWDS-1
 
	RETURN, strtrim(STRMID(TXTSTR,ll,LOC(MTH)-LOC(NTH)+LEN(MTH)), 2)
 
NEG:	RETURN, strtrim(STRMID(TXTSTR,ll,9999), 2)
 
	END

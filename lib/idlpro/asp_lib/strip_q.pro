function strip_q, line
;+
;
;	function:  strip_q
;
;	purpose:  return the string between double quotes of a line
;		  (e.g., strip the quoted part of a PRINT statement)
;
;	author:  rob@ncar, 7/93
; 
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ret = strip_q(line)"
	print
	print, "	Return the string between double quotes of a line"
	print, "	(e.g., strip the quoted part of a PRINT statement)."
	print, "	The input must contain 0 or 1 pairs of quotes.
	print
	print, "	Arguments"
	print, "		line	 - the string to search"
	print
	print, "   ex:  str = strip_q(str)"
	print
	return, ''
endif
;-
;
;	Get input string length.
;
len = strlen(line)
if len eq 0 then return, ''	; return empty string if no characters input
;
;	Find location of 1st double quote.
;
pos1 = strpos(line, '"')
if pos1 lt 0 then return, ''	; return empty string if no double quotes
;
;	Find location of 2nd double quote.
;
pos2 = strpos(strmid(line, pos1+1, 80), '"')
if pos2 lt 0 then return, ''	; return empty string if no closing quotes
pos2 = pos2 + pos1 + 1
;
;	Calculate number of characters to return.
;
num = pos2 - pos1 - 1
if num eq 0 then return, ''	; return empty string if nothing btw quotes
;
;	Return the string between double quotes.
;
return, strmid(line, pos1+1, num)

end

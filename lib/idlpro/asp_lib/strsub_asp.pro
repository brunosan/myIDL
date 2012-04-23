function strsub, str, s_old, s_new
;+
;
;	function:  strsub
;
;	purpose:  return a string with a substring substitution
;
;	author:  rob@ncar, 10/93
;
;==============================================================================
;
;	Set value to return on error.
;
error_ret = ''
;
;	Check number of parameters.
;
if n_params() ne 3 then begin
	print
	print, "usage:  s2 = strsub(s1, s_old, s_new)"
	print
	print, "	Return a string with a substring substitution"
	print, "	(first occurrence of 's_old' is replaced by 's_new')."
	print, "	Null string is returned on error."
	print
	print, "	Arguments"
	print, "		s1	- original string"
	print, "		s_old	- substring to replace"
	print, "		s_new	- substring to replace with"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return, error_ret
endif
;-
;
;	Get lengths of substrings.
;
len_old = strlen(s_old)
len_new = strlen(s_new)
;
;	Find the location of the substring to replace.
;
loc = strpos(str, s_old)
if loc lt 0 then return, error_ret
;
;	Do substring substitution.
;
if len_old eq len_new then begin	; substrings are the same size
	result = str
	strput, result, s_new, loc
endif else begin			; substrings are NOT the same size
	if loc eq 0 then result = '' $
		    else result = strmid(str, 0, loc)
	result = result + s_new
	rest  = strlen(str) - loc - len_old
	if rest gt 0 then result = result + strmid(str, loc + len_old, rest)
endelse
;
;	Return new string.
;
return, result
end

function get_words, text, count, delimiters=delimiters
;+
; NAME:
;	GET_WORDS
;
; PURPOSE:
;	Separate text string(s) into array of words.
;
; CATEGORY:
;	AFOE 
;
; CALLING SEQUENCE:
;	words = get_words( text [, count] )
;
; INPUTS:
;	text		- scalar string or array of strings
;
; KEYWORDS:
;	delimiters	- scalar or array of delimiter characters
;			  (default = [' ', '	', ','],
;			       i.e., [space, tab, comma])
;
; OUTPUTS:
;	count		- optional returned count of the number of words
;
;	Function returns array of strings ("words").
;	(If just one word, a scalar string is returned;
;	 however, can still index it as words(0).)
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;
; EXAMPLE:
;	line = ''
;	readf, unit, line
;	words = get_words(line)
;	print, 'First word = ', words(0)
;
; MODIFICATION HISTORY:
;	1989, Frank Varosi - written.
;	12/90, FV - generalized, restructured, added 'delimiters' keyword.
;	11/93, Rob Montgomery - commented; reformatted; changed 'dpos' to
;		'wstart', then 'wpos' to 'dpos'; removed the side effect of
;		spaces being added to the input string array; removed the
;		bugs when specifying own delimiters - must add 0B delimiter,
;		and must use a given delimiter to extend with if input is
;		array of strings.
;	12/94, Rob Montgomery - added 'count' argument; fixed bug of case
;		where input is nothing but a single delimiter; improved usage.
;
;==============================================================================
;
;	Set default count.
;
count = 0
;
;	Check number of parameters.
;
if n_params() lt 1 then begin
	print
	print, "usage:  words = get_words(text [,count])"
	print
	print, "	Separate text string(s) into array of words."
	print
	print, "	Arguments"
	print, "		text       - scalar string or array of"
	print, "			     strings"
	print, "		count      - optional returned count of"
	print, "			     number of words found"
	print
	print, "	Keywords"
	print, "		delimiters - scalar or array of delimiter"
	print, "			     characters (default ="
	print, "			       [' ', '	', ','], i.e.,"
	print, "			       [space, tab, comma])"
	print
	return, ''
endif
;-
;
;	If input empty, return empty string.
;
ntext = n_elements(text)
if ntext eq 0 then return, ''
;
;	Work with a copy of the input to avoid side effects.
;
text_use = text
;
;	Set the delimiters to use.
;
;		0B = empty string [because byte(string_array) fills in with
;		     this to make all elements of the array the same length]
;		9B = tab
;	byte(", ") = [comma, space]
;
if n_elements(delimiters) eq 0 then begin
	delimb = [0B, 9B, byte(", ")]		; default
endif else begin
	delimb = [0B, byte(delimiters)]		; user-specified + 0B
endelse
ndelim = n_elements(delimb)
;
;	If array of strings input, append delimiter to longest string.
;	Thus when converted to byte, will get have a delimiter and 0B's that
;	can be used as delimiters between successive strings (see above).
;
if ntext gt 1 then begin
	lens = strlen(text_use)
	lenmax = max(lens, maxi)
	text_use(maxi) = text_use(maxi) + string(delimb(1))
endif
;
;	Convert string(s) to byte.
;
textb = byte(text_use)
len = n_elements(textb)
if len eq 1 then begin				; only one byte
	w = where(delimb eq textb(0), c)	;  check against delimiters
	if c ne 0 then return, ''		;   (IS a delimiter)
	count = 1  &  return, string(textb)	;   (is NOT a delimiter)
endif
;
;	Find where the delimiters are and add 1,
;	thus specifying indices where words might start.
;
wstart = 0

for i = 0, ndelim-1 do begin
	dpos = where(textb eq delimb(i), npos)
	if (npos gt 0) then wstart = [wstart, dpos+1]
endfor
;
;	If no delimiters found, return the input string(s).
;
if n_elements(wstart) le 1 then begin &  count=ntext  &  return,text  &  endif
;
;	Sort the delimiter locations.
;
wstart = wstart(sort(wstart))
;
;	Specify indices where words may end.
;
wend = [wstart(1:*)-2, len-1]
;
;	Use the indices to find where there are words.
;
w = where(wend ge wstart, count)
wstart = wstart(w)
wend = wend(w)
words = strarr(count)
;
;	Grab the words using their byte indices; make them strings.
;
for i = 0, count-1 do  words(i) = string(textb(wstart(i):wend(i)))
;
;	Return the words.
;
return, words
end

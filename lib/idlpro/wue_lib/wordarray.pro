;+
; NAME:
;       WORDARRAY
; PURPOSE:
;       Convert a text string or string array into a 1-d array of words.
; CATEGORY:
; CALLING SEQUENCE:
;       wordarray, instring, outlist
; INPUTS:
;       instring = string or string array to process.  in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         IGNORE = character or array of characters. 
;           These characters are removed before processing. 
;           Ex: wordarray,in,out,ignore=',' 
;               wordarray,in,out,ignore=[',',';','(',')'] 
; OUTPUTS:
;       outlist = 1-d array of words in instring.      out 
; COMMON BLOCKS:
; NOTES:
;       Notes: Words are assumed delimited by spaces. 
;         Non-spaces are returned as part of the words. 
;         Spaces are not needed at the beginning and end of the strings.  
; MODIFICATION HISTORY:
;       R. Sterner, 29 Nov, 1989
;-
 
	pro wordarray, in0, out, ignore=ign, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(h) then begin
	  print,' Convert a text string or string array into a 1-d array of words.'
	  print,' wordarray, instring, outlist'
	  print,'   instring = string or string array to process.  in'
	  print,'   outlist = 1-d array of words in instring.      out'
	  print,' Keywords:'
	  print,'   IGNORE = character or array of characters.'
	  print,'     These characters are removed before processing.'
	  print,"     Ex: wordarray,in,out,ignore=','"
	  print,"         wordarray,in,out,ignore=[',',';','(',')']"
	  print,' Notes: Words are assumed delimited by spaces.'
	  print,'   Non-spaces are returned as part of the words.'
	  print,'   Spaces are not needed at the beginning and end of the strings.' 
	  return
	endif
 
	in = in0
 
	if n_elements(ign) gt 0 then begin
	  rm = array(ign)
	  for i = 0, n_elements(rm)-1 do in = repchr(in, rm(i))
	endif
 
	t = ' ' + array(in) + ' '		; Force spaces on ends
	b = byte(t)				; Convert to byte array.
	w = where(b ne 0, count)		; Find non-null chars.
	if count gt 0 then b = b(w)		; Extract non-null characters.
	X = B NE 32b				; non-space chars.
	X = [0,X,0]				; tack 0s at ends.
 
	Y = (X-SHIFT(X,1)) EQ 1			; look for transitions.
	Z = WHERE(SHIFT(Y,-1) EQ 1)
	Y2 = (X-SHIFT(X,-1)) EQ 1
	Z2 = WHERE(SHIFT(Y2,1) EQ 1)
 
	NWDS = TOTAL(Y)				; Total words in IN.
	LOC = Z					; Word start positions.
	LEN = Z2 - Z - 1			; Word lengths.
 
	out = bytarr(max(len), nwds)		; Set up output array.
	if nwds gt 1 then begin
	  for i = 0, nwds-1 do begin
	    out(0,i) = b(loc(i):(loc(i)+len(i)-1))
	  endfor
	  out = string(out)
	endif else begin
	  out(0) = b(loc(0):(loc(0)+len(0)-1))
	  out = array(string(out))
	endelse
 
 
	return
 
	END

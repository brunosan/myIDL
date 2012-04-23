pro pause, message, dummy, ans=ans, nopause=nopause
;+
;
;	function:  pause
;
;	purpose:  print message and wait until user hits a 'return'
;
;	author:  rob@ncar, 3/92
;
;	note:  if 'message' is present, it will be automatically converted
;	       to a string
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() gt 1 then begin
	print
	print, "usage:  pause [, message]"
	print
	print, "	Print message and wait until user hits a 'return'."
	print
	print, "	Arguments"
	print, "	    message	- string to print"
	print
	print, "	Keywords"
	print, "	    ans		- character typed by user"
	print, "	    nopause	- if set, don't print the word pause"
	print, "			  (def = print 'pause ... ')"
	print
	return
endif
;-

;
;	Set to return to caller on error.
;
on_error, 2
;
;	Set up message to print.
;
ans = ''
if not keyword_set(nopause) then msg = 'pause ... ' else msg = ''
if n_params() eq 1 then msg = msg + string(message)
;
;	Print message and read response.
;
print, msg, format='(a, $)'
read, ans
;
end

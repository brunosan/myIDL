pro p, value
;+
;
;	procedure:  p
;
;	purpose:  print a value (faster to type than 'print')
;
;	author:  rob@ncar, 5/92
;
;	notes:  - Tried to use ON_ERROR and MESSAGE, but no option of ON_ERROR
;		  worked for the following case:
;			1. put a STOP in a procedure and ran it until the STOP
;			2. did a 'p' of an undefined variable
;				ON_ERROR, 0	; stopped in p.pro
;				ON_ERROR, 1	; returned to $MAIN$
;				ON_ERROR, 2	; returned to $MAIN$
;				ON_ERROR, 3	; returned to $MAIN$
;		  Thus I PRINT my own message and RETURN.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  p, value"
	print
	print, "	Print a value."
	print
	return
endif
;-
;
;	Return to caller if error.
;
if sizeof(value, -3) eq 'Undefined' then begin
	print, 'p.pro: value is undefined.'
	return
endif
;
;	Print the value.
;
print, value
end

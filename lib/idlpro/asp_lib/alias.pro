pro alias, rnum, command
;+
;
;	procecure:  alias
;
;	purpose:  simple Sun csh-like ("sort of") alias procedure
;
;	author:  rob@ncar, 12/92
; 
; 	notes:  - must do SETUP_KEYS first (e.g., put it in your startup file)
;		- must use suntool rather than cmdtool (i.e., no scrollbar)
;		- this approach can work for keys F2-F9 as well
; 
;	to show current settings:
;	help, /keys, 'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', $
;		     'R10', 'R11', 'R12', 'R13', 'R14', 'R15'
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
usage:
	print
	print, "usage:  alias, rnum, command"
	print
	print, "	Simple Sun csh-like ('sort of') alias procedure."
	print
	print, "	Arguments"
	print, "		rnum	 - number of Sun 'R' key (1-15)"
	print, "		command	 - command to associate with the key"
	print
	print
	print, "   ex:	alias, 7, 'help'"
	print
	return
endif
;-

if (rnum lt 1) or (rnum gt 15) then goto, usage

key = 'R' + stringit(rnum)

define_key, key, command

help, /keys, key

end

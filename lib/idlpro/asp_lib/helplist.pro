pro helplist, dummy
;+
;
;	procedure:  helplist
;
;	purpose:  show list of help options and other useful info
;
;	author:  rob@ncar, 11/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  helplist"
	print
	print, "	Show list of help options and other useful info."
	print
	return
endif
;-
;
;	Print useful information.
;
line = '--------------------------------------------------------------------'
print, line
print, "               ASP IDL Help Information"
print, "
print, "help, /all_keys"
print, "help, /breakpoints          [UPDATE THIS FOR 3.6.1a  -Rob]"
print, "help, /calls"
print, "help, /device"
print, "help, /files		--> helpfiles"
print, "help, /keys"
print, "help, /memory                               unit"
print, "help, names='string'                          0  = stdin"
print, "help, /recall_commands                       -1  = stdout"
print, "help, /routines                              -2  = stderr"
print, "help, /structures"
print, "help, /system_variables	--> helpsy"
print, "help, /traceback"
print
print, " help on a specific structure:  helps, str      (e.g., 'helps, !p')"
print, "help on one or more variables:  h, v1, v2, ...  (uses 'helps.pro')"
print, "show !PATH in readable format:  path"
print, "    help on IDL-code routines:  usage, 'routine'"
print, "            widget-based help:  ?"
print
print, "system       !c, !d, !dir, !dpi, !dtor, !edit_input, !error,"
print, " variables:  !err_string, !journal, !msg_prefix, !order, !p, !path,"
print, "             !pi, !quiet, !prompt, !radeg, !version, !x, !y, !z"
print
print, "^C	- Interrupt"
print, "^D	- Exit"
print, "^\	- Abort    [WARNING - information may not be up to date!]"
print, line
;
end

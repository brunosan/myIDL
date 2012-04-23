pro helps, v
;
;	procedure:  helps
;
;	purpose:  do HELP on a variable, and if it's a structure,
;		  print the fields
;
;	author:  rob@ncar, 11/93
;
;	ex:  helps, !p
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  helps, v"
	print
	print, "	Do HELP on a variable, and if it's a structure,"
	print, "	print the fields."
	print
	return
endif
;-
;
;	Do a regular help on the variable.
;
help, v
;
;	Return if the variable is not a structure.
;
if sizeof(v, -3) ne 'Structure' then return
;
;	Set general parameters for structure processing.
;
max_nlen = 20			; (max length of field name to print)
names = tag_names(v)
print
;
;-----------------------
;
;	LOOP FOR EACH FIELD OF THE STRUCTURE.
;
for i = 0, n_tags(v) - 1 do begin

;	Grab variable and its name.
	var = v.(i)
	name = names(i)

;	Set print format to use constant number of columns for name.
	nlen = strlen(name)
	if nlen gt max_nlen then begin
		f = '(A' + stringit(max_nlen)
	endif else begin
		f = '(A, ' + stringit(max_nlen - nlen) + 'X'
	endelse

	f = f + ', A'

;	Set scalar or array part of print format.
	if sizeof(var, 0) eq 0 then begin			  ; scalar
		f = f + ', A)'
	endif else begin					  ; array
		f = f + ', A, 6(2X, A), 50(/, 13X, 7(2X, A)))'
	endelse

;	Print the field.
	print, name, ' - ', stringit(var), format=f

endfor
;
;-----------------------
;
end

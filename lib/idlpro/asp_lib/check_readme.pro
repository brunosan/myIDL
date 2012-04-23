pro check_readme, dummy, dir=dir
;+
;
;	procedure:  check_readme
;
;	purpose:  check that ASP README file is up to date
;
;	author:  rob@ncar, 11/94
;
;==============================================================================
;
;	Check parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  check_readme"
	print
	print, "	Check that ASP README file is up to date."
	print
	print, "	Arguments"
	print, "		(none)"
	print
	print, "	Keywords"
	print, "		dir	- directory to check"
	print, "			  (def='~stokes/src/idl-new')"
	print
	return
endif
;-
;
;	Set to return to caller on error.
;
on_error, 2
;
;	Set general parameters.
;
names_readme = ['']
readme = 'README'	; name of file to check
if n_elements(dir) eq 0 then dir = '~stokes/src/idl-new'
line = ''
;
;	'Push to' directory to check.
;
pushd, dir
;
;	Find names of *.pro files.
;
names_actual = findfile('*.pro', count=count)
if count lt 1 then message, 'no files found'
;
;	Open file; get the procedure names; close file and free unit number.
;
openr, unit, readme, /get_lun
while not eof(unit) do begin
	readf, unit, line
	len = strlen(line)
	if len gt 2 then begin
		c = strmid(line, 1, 1)
		if (c ne ' ') and (c ne '_') then begin
			w = (get_words(strmid(line, 1, len-1)))(0)
			names_readme = [names_readme, w]
			if not in_set(names_actual, w) then $
				print, 'Extra in README:  ' + w
		endif
	endif
endwhile
free_lun, unit
;
;	Check that all names are in the README.
;
for i = 0, n_elements(names_actual) - 1 do $
	if not in_set(names_readme, names_actual(i)) then $
		print, 'Not in README:  ' + names_actual(i)
;
;	Pop back to original directory.
;
pushd, dir
end

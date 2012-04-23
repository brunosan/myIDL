function read_x, file
;+
;
;	function:  read_x
;
;	purpose:  return an X matrix from a file as output from xxx.f
;
;	authors:  rob@ncar, 1/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  X = read_x(file)"
	print
	print, "	Return an X matrix from a file."
	print
	print, "	Arguments"
	print, "		file        - file containing X matrix"
	print
	print
	print, "   ex:  X = read_x('03.fa.X.15')"
	print
	return, 0
endif
;-
;
;	Read X matrix part of file.
;
s = ''
x = fltarr(6, 4, /nozero)
openr, unit, file, /get_lun
for i = 1, 6 do readf, unit, s		; skip 1st 6 lines
readf, unit, x
return, x(0:3, *)			; return 1st 4 columns
end

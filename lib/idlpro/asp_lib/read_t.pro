function read_t, file
;+
;
;	function:  read_t
;
;	purpose:  return a telescope matrix from a file as output from ttt.f
;
;	authors:  rob@ncar, 1/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  T = read_t(file)"
	print
	print, "	Return a telescope matrix from a file."
	print
	print, "	Arguments"
	print, "		file        - file containing T matrix"
	print
	print
	print, "   ex:  T = read_t('T.92.03.25.f.4')"
	print
	return, 0
endif
;-
;
;	Read T matrix part of file.
;
s = ''
t = fltarr(4, 4, /nozero)
openr, unit, file, /get_lun
for i = 1, 17 do readf, unit, s		; skip 1st 17 lines
readf, unit, t
return, t
end

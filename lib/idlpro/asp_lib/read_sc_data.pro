function read_sc_data, filenum
;+
;
;	function:  read_sc_data
;
;	purpose:  read ASP scan data into common
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ret = read_sc_data(filenum)"
	print
	print, "	Read ASP scan data into common."
	print
	print, "	On error, error message is printed and 1 is returned;"
	print, "	else 0 is returned."
	print
	return, 1
endif
;-
;
;	Specify I,Q,U,V common block.
;
@iquv.com
;
;	Set up to catch I/O error (i.e, goto 'ioerror' label).
;
on_ioerror, ioerror
;
;	Read scan.
;
readu, filenum, i_int, q_int, u_int, v_int
;
;	Convert values to floating point:
;		'i' was originally 'unsigned short';
;		'q, u, v' were originally 'short'.
;
i = i2float(i_int)
;
q = float(q_int)
u = float(u_int)
v = float(v_int)
;
;	Return 0 on success, or 1 on error.
;
return, 0
ioerror: print
	 print, "*** I/O error in 'read_sc_data.pro' ***"
	 print
	 return, 1
end

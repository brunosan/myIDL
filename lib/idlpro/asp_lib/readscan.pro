pro readscan, infile, seq_scan, ii, qq, uu, vv, ignore=ignore, $
	x1=x1, y1=y1, x2=x2, y2=y2, nohead=nohead, v101=v101
;+
;
;	function:  readscan
;
;	purpose:  read a specified sequential scan from an ASP file
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() lt 2) or (n_params() gt 6) then begin
	print
	print, "usage:  readscan, infile, seq_scan, i, q, u, v"
	print
	print, "	Read a specified sequential scan from an ASP file."
	print
	print, "	Arguments"
	print, "	    infile	- input file name"
	print, "	    seq_scan	- sequential scan (starting with 0)"
	print, "	    i,q,u,v	- output I,Q,U,V arrays"
	print
	print, "	Keywords"
	print, "	    x1,y1	- starting col,row indices (defs=0)"
	print, "	    x2,y2	- ending col,row indices (defs=last)"
	print, "	    nohead	- if set, do not print scan header"
	print, "	    ignore	- if set, ignore scan hdr error"
	print, "		          (scan header will not be printed)"
	print, "	    v101	- set to force version 101"
	print, "		          (def=use version # in op hdr)"
	print
	return
endif
;-
;
;	Specify common blocks.
;
@op_hdr.com
@scan_hdr.com
@iquv.com
;
;	Set types and sizes of common block variables.
;
@op_hdr.set
@scan_hdr.set
;
;	Set general parameters.
;
true = 1
false = 0
stdout_unit = -1
do_list = true
do_ignore = false
if keyword_set(nohead) then do_list = false
if keyword_set(ignore) then do_ignore = true
ans = string(' ',format='(a2)')
;
;	Set input file.
;
openr, infile_unit, infile, /get_lun
;
;	Read and possibly list operation header.
;
if read_op_hdr(infile_unit, stdout_unit, false) eq 1 then return
;
;	Set I,Q,U,V arrays
;	(This is put after the op header is read because
;	 dnumx and dnumy are needed; see op_hdr common block.)
;
set_iquv
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Set subset of scan to return.
;	(This is put after the op header is read in case
;	 dnumx and dnumy are to be used.)
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
x_len = x2 - x1 + 1
y_len = y2 - y1 + 1
if (x_len lt 1) or (y_len lt 1) or $
   (x2 gt dnumx - 1) or (y2 gt dnumy - 1) then begin
	print
	print, 'Error in specifying the X,Y range.'
	print
	return
endif
;
;	Jump to location of the sequential scan.
;
skip_scan, infile_unit, fscan=seq_scan
;
;	Read scan header.
;
if read_sc_hdr(infile_unit, stdout_unit, do_list, $
		ignore=do_ignore, version=version) eq 1 then return
;
;	Read scan data.
if read_sc_data(infile_unit) eq 1 then return
;
;	Chop out middle to use.
ii = i(x1:x2, y1:y2)
qq = q(x1:x2, y1:y2)
uu = u(x1:x2, y1:y2)
vv = v(x1:x2, y1:y2)
;
;	Close and free the input unit.
;
free_lun, infile_unit
;
;	Done.
;
if do_list then print
end

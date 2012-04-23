function aspmeanv, infile, x1=x1, y1=y1, x2=x2, y2=y2, $
	fscan=fscan, lscan=lscan, v101=v101, verbose=verbose
;+
;
;	function:  aspmeanv
;
;	purpose:  return max of mean-of-V-extrema of input ASP op
;
;	author:  rob@ncar, 11/92
;
;	note:  This was written to help choose a thold for avgprof_st.pro.
;
;==============================================================================
;
;	Check number of parameters.
;
error_ret = 0.0
;
if n_params() ne 1 then begin
	print
	print, "usage:  mean_v = aspmeanv(infile)"
	print
	print, "	Return return max of mean-of-V-extrema of input op."
	print
	print, "	Arguments"
	print, "		infile	  - input operation file name"
	print
	print, "	Keywords"
	print, "		x1	  - starting column index (def=0)"
	print, "		y1	  - starting row index (def=0)"
	print, "		x2	  - ending column index (def=last one)"
	print, "		y2	  - ending row index (def=last one)"
	print, "		fscan	  - first sequential scan to consider"
	print, "			    (def = 0 = first scan)"
	print, "		lscan	  - last sequential scan to consider"
	print, "			    (def = last scan)"
	print, "		v101	  - set to force version 101; this"
	print, "			    keyword is not needed at this time"
	print, "			    (def=use version # in op hdr)"
	print, "		verbose	  - set to print info. per scan"
	print
	print
	print, "   ex:  m = aspmeanv('map', x1=80, x2=90)"
	print
	return, error_ret
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
do_verbose = false
if keyword_set(verbose) then do_verbose = true
;
;	Set input file.
;
openr, infile_unit, infile, /get_lun
;
;	Read and list operation header.
;
if read_op_hdr(infile_unit, stdout_unit, false) eq 1 then return, error_ret
;
;	Set I,Q,U,V arrays.
;	(This is put after the op header is read because
;	 dnumx and dnumy are needed; see op_hdr common block.)
;
set_iquv
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Set X and Y ranges.
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
	print, 'Error in specifying the X,Y range -- check your typing.'
	print
	return, error_ret
endif
;
;	Set scan ranges.
;	(This is put after the op header is read because
;	 nmstep is used.)
;
if n_elements(fscan) eq 0 then fscan = 0
if fscan lt 0 then begin
	print
	print, 'fscan must be >= 0'
	print
	return, error_ret
endif
max_scan = get_nscan() - 1
if n_elements(lscan) eq 0 then begin
	lscan = max_scan
endif else if lscan gt max_scan then begin
	print
	print, 'lscan must not be greater than ' + stringit(max_scan)
	print
	return, error_ret
endif
nscan = lscan - fscan + 1
if nscan lt 1 then begin
	print
	print, 'lscan must be >= than fscan'
	print
	return, error_ret
endif
;
;	Jump to location of first scan to view.
;
skip_scan, infile_unit, fscan=fscan
;
;	Initialize maximum mean V value.
;
meanv_max = 0.0
print
;
;----------------------------------------------
;
;	LOOP FOR EACH SCAN
;
for iscan = 0, nscan - 1 do begin
;
;	Read scan header.
	if read_sc_hdr(infile_unit, stdout_unit, false, $
		version=version) eq 1 then return, error_ret
;
;	Read scan data.
	if read_sc_data(infile_unit) eq 1 then return, error_ret
;
;	Find the maximum mean V for this scan.
	meanv_m = 0.0
	for y = y1, y2 do begin
		minv = min( v(x1:x2, y), max=maxv )
		meanv = 0.5 * (abs(minv) + abs(maxv))
		meanv_m = meanv_m > meanv
	endfor
;
;	Print scan number and max mean V of the scan.
	if do_verbose then $
		print, 'Scan ' + stringit(s_snum) + ':  largest mean V is ' $
			+ stringit(meanv_m)
;
;	Select the maximum mean V so far.
	meanv_max = meanv_max > meanv_m
;
endfor
;----------------------------------------------
;
;	Close input file and free unit number.
;
free_lun, infile_unit
;
;	Print results.
;
if do_verbose then begin
	print
	print, 'Largest mean V of the entire operation is ' + $
		stringit(meanv_max)
	print
endif
;
;	Return maximum mean V.
;
return, meanv_max
end

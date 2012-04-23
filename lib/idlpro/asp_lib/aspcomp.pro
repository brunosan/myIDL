pro aspcomp, infile1, infile2, prompt=prompt
;+
;
;	procedure:  aspcomp
;
;	purpose:  compare two ASP files
;
;	author:  rob@ncar, 12/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  aspcomp, infile1 ,infile2"
	print
	print, "	Compare two ASP files."
	print
	print, "	Arguments"
	print, "		infile1   - name of 1st input file"
	print, "		infile2   - name of 2nd input file"
	print
	print, "	Keywords"
	print, "		prompt    - if set, prompt for quit after"
	print, "			    each scan"
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
done = false
do_prompt = false
if keyword_set(prompt) then do_prompt = true
ans = string(' ',format='(a1)')
stdout_unit = -1
;
;	Set input files.
;
openr, in1_unit, infile1, /get_lun
openr, in2_unit, infile2, /get_lun
;
;	Check if operation headers are different.
;
h1 = intarr(256)
h2 = h1
readu, in1_unit, h1
readu, in2_unit, h2
;
if equal(h1, h2, /noverb) then begin
	print
	print, 'Op headers are equal.'
endif else begin
	print
	print, 'Op headers are NOT equal.'
	print
	print, 'Will stop so you can look at h1 and h2 ...'
	print
	stop
endelse
;
;	Get op header values into common block.
;	(A rewind is done in read_op_hdr).
;
if read_op_hdr(in1_unit, stdout_unit, false) eq 1 then return
;
;	Set number of scans.
;
nscan = get_nscan()
seq_scan = 0
;
;	Set I,Q,U,V arrays
;	(must have set 'dnumx' and 'dnumy' in 'op_hdr'
;	 common block first -- from read_op_hdr).
;
set_iquv
;
;	Set version number (from operation header).
;
version = get_version()
;
;----------------------------------------------
;
;	LOOP TO READ AND LIST SCANS
;
while (not (EOF(in1_unit) or done)) do begin
;
;	Print sequential scan number.
	print, 'SEQ SCAN:  ' + stringit(seq_scan)
;
;	Read and compare scan headers.
	readu, in1_unit, h1
	readu, in2_unit, h2
	if equal(h1, h2, /noverb) then begin
		print, 'Scan headers are equal.'
	endif else begin
		print, 'Scan headers are NOT equal.'
		print
		print, 'Will stop so you can look at h1 and h2 ...'
		print
		stop
	endelse
;
;	Read scan data.
	if read_sc_data(in2_unit) eq 1 then return
	ii = i
	qq = q
	uu = u
	vv = v
	if read_sc_data(in1_unit) eq 1 then return
;
;	Compare scan data.
	if equal(i, ii, /noverb) then begin
		print, 'I''s are equal.'
	endif else begin
		print, 'I''s are NOT equal.'
		print
		print, 'Will stop so you can look i and ii ...'
		print
		stop
	endelse
	if equal(q, qq, /noverb) then begin
		print, 'Q''s are equal.'
	endif else begin
		print, 'Q''s are NOT equal.'
		print
		print, 'Will stop so you can look q and qq ...'
		print
		stop
	endelse
	if equal(u, uu, /noverb) then begin
		print, 'U''s are equal.'
	endif else begin
		print, 'U''s are NOT equal.'
		print
		print, 'Will stop so you can look u and uu ...'
		print
		stop
	endelse
	if equal(v, vv, /noverb) then begin
		print, 'V''s are equal.'
	endif else begin
		print, 'V''s are NOT equal.'
		print
		print, 'Will stop so you can look v and vv ...'
		print
		stop
	endelse
;
;	Check if done.
	seq_scan = seq_scan + 1
	if seq_scan eq nscan then begin
		done = true
;
;	Pause with option to quit.
	endif else if do_prompt then begin
		print, ' '
		read, 'Pause...  (Hit ''q'' to quit.)  ', ans
		if ans eq 'q' then done = true
	endif
endwhile
;
;----------------------------------------------
;
;	Close input files and free unit numbers.
;
free_lun, in1_unit, in2_unit
;
;	Done.
;
print
end

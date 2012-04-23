pro asplist, infile, outfile, fscan=fscan, nscan=nscan, v101=v101
;+
;
;	procedure:  asplist
;
;	purpose:  list operation header and scan headers of a raw ASP
;		  operation file
;
;	author:  rob@ncar, 1/92
;
;	notes:  1. modify this so that don't actually do 'read' of data
;		   (thus making it faster)
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() lt 1) or (n_params() gt 2) then begin
	print
	print, "usage:  asplist, infile [,outfile]"
	print
	print, "	List op and scan headers of ASP operation file."
	print
	print, "	Arguments"
	print, "		infile	 - input file name"
	print, "		outfile	 - output file name, other than stdout"
	print, "			   (def=stdout)"
	print, "	Keywords"
	print, "		fscan	 - first sequential scan to list"
	print, "			   (def=0=first sequential scan)"
	print, "		nscan	 - number of scans to list (def=all;"
	print, "			   use when outputting to a file)"
	print, "		v101	 - set to force version 101"
	print, "			   (def=use version # in op hdr)"
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
ans = string(' ',format='(a1)')
;
;	Set input file.
;
openr, infile_unit, infile, /get_lun
;
;	Set output file.
;
if n_params() eq 1 then begin
	use_stdout = true			; use stdout for output
	outfile_unit = -1
endif else begin
	use_stdout = false			; use file for output
	openw, outfile_unit, outfile, /get_lun
endelse
;
;	Read and list operation header.
;
if read_op_hdr(infile_unit, outfile_unit, true) eq 1 then return
;
;	Pause with option to quit.
;
if use_stdout eq true then begin
	print, ' '
	read, 'Pause...  (Hit ''q'' to quit.)  ', ans
	if ans eq 'q' then done = true
endif
;
;	Get operation type [uses op header variables].
;
op_type = get_optype()
;
;	Set number of scans.
;
nscan_avail = get_nscan()
if (op_type eq 'Map') and (nfstep gt 1) then begin
	print
	print, '**************************************************************'
	print
	print, 'This is a movie containing ' + stringit(nfstep) + ' maps,' + $
	       ' with '+ stringit(nscan_avail) + ' scans each.'
	print
	print, '**************************************************************'
	nscan_avail = nscan_avail * nfstep
endif
if n_elements(fscan) eq 0 then fscan = 0
if n_elements(nscan) eq 0 then nscan = nscan_avail
fscan = fscan > 0			; just "correct" user's typo's
nscan = nscan > 1
nscan = nscan < (nscan_avail - fscan)
seq_scan = 0				; sequential scan of this listing
seq_scan_abs = fscan			; absolute seq. scan (of input op)
;
;	Set I,Q,U,V arrays
;	(must have set 'dnumx' and 'dnumy' in 'op_hdr'
;	 common block first -- from read_op_hdr).
;
set_iquv
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Jump to location of first scan to list.
;
skip_scan, infile_unit, fscan=fscan
;
;----------------------------------------------
;
;	LOOP TO READ AND LIST SCANS
;
while (not (EOF(infile_unit) or done)) do begin
;
;	Read and list scan header.
	if read_sc_hdr(infile_unit, outfile_unit, true, seq_scan_abs, $
		version=version) eq 1 then return
;
;	Read scan data.
	if read_sc_data(infile_unit) eq 1 then return
;
;	Print prompt if outputting to stdout.
	if use_stdout then begin
again:		print
		read, 'Enter sequential scan number (0 to ' + $
			stringit(nscan - 1) + ')  ' + $
			'[OR n=next scan, q=quit]: ', ans
		if ans eq 'q' then begin		; quit
			done = true
		endif else if ans eq 'n' then begin	; get next scan
			seq_scan_abs = seq_scan_abs + 1
		endif else if (ans ge 0) and $
			      (ans lt nscan) then begin ; skip to scan
			skip_scan, infile_unit, fscan=ans
			seq_scan_abs = ans
		endif else begin			; error
			goto, again
		endelse
;
;	Not outputting to stdout, so check if done.
	endif else begin
		seq_scan = seq_scan + 1
		seq_scan_abs = seq_scan_abs + 1
		if seq_scan eq nscan then done = true
	endelse
;
endwhile
;
;----------------------------------------------
;
;	Close input file and free unit number.
;
free_lun, infile_unit
;
;	Close output file and free unit number.
;
if use_stdout eq false then  free_lun, outfile_unit
;
;	Done.
;
print
end

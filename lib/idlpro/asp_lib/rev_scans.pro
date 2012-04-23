pro rev_scans, infile, outfile, verbose=verbose
;+
;
;	procedure:  rev_scans
;
;	purpose:  reverse the scan order and numbering of an operation
;
;	author:  rob@ncar, 10/94
;
;	note:  - this routine could be made faster by replacing readscan()...
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  rev_scans, infile, outfile"
	print
	print, "	Reverse the scan order and numbering of an operation."
	print
	print, "	Arguments"
	print, "	    infile	- name of input file"
	print, "	    outfile	- name of output file"
	print
	print, "	Keywords"
	print, "	    verbose	- if set, print verbose information"
	print, "			  (def=no print)"
	print
	print
	print, "   ex:  rev_scans, '10.fab.cmap', '10.fab.cmap.rev'
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;       Specify and set common blocks.
;
@op_hdr.com
@scan_hdr.com
@iquv.com
@op_hdr.set
@scan_hdr.set
;
;	Set general parameters.
;
snum = 0L			; initial output scan number
do_verb = keyword_set(verbose)
if do_verb then print
;
;	Open input and output units.
;
openr, in_unit, infile, /get_lun
openw, out_unit, outfile, /get_lun
;
;	Read op header.
;
if read_op_hdr(in_unit, -1, 0) eq 1 then $
	message, 'Error reading op header in "read_op_hdr".'
;
;	Write op header.
;
if writ_op_hdr(out_unit) eq 1 then $
	message, 'Error writing op header in "writ_op_hdr".'
;
;	Get number of scans from op header common.
;
nscan = get_nscan()
;
;-----------------------------------------
;
;	PROCESS EACH SCAN.
;
for iscan = nscan - 1, 0, -1 do begin

;	Read scan.
	readscan, infile, iscan, i, q, u, v, /nohead

;	Reset scan number in header.
	if do_verb then print, 'I/P scan:  ' + stringit(iscan) + '    ' + $
			       'O/P scan:  ' + stringit(snum)

;	Reset scan number in header.
	s_snum = snum
	snum = snum + 1L

;	Write scan.
	writscan, out_unit, i, q, u, v

endfor
;-----------------------------------------
;
;       Close files and free unit numbers.
;
free_lun, in_unit, out_unit
if do_verb then print
;
;
end

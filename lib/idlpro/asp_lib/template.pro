pro template, infile, outfile
;+
;
;	procedure:  template
;
;	purpose:  simple template for processing ASP data
;
;	author:  rob@ncar, 1/93
;
;	notes:  - details are omitted for early 10/92 data
;		- scans are read the easy (but slow) way
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 2 then begin
	print
	print, "usage:  template, infile, outfile"
	print
	print, "	Process ASP data."
	print
	print, "	Arguments"
	print, "		infile	   - input file name"
	print, "		outfile	   - output file name"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  template, '02.fa.map', '02.fa.map.new'"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Set common blocks.
;
@op_hdr.com
@op_hdr.set
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
for iscan = 0, nscan - 1 do begin

;	Read scan.
	readscan, infile, iscan, i, q, u, v


;	Process scan.


;	Write scan.
	writscan, out_unit, i, q, u, v

endfor
;-----------------------------------------
;
;       Close files and free unit numbers.
;
free_lun, in_unit, out_unit
;
;
end

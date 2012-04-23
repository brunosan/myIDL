pro listop, infile
;+
;
;	function:  listop
;
;	purpose:  list operation header of a file
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  listop, infile"
	print
	print, "	List operation header of a file."
	print
	return
endif
;-
;
;	Set common block.
;
@op_hdr.com
@op_hdr.set
;
;	Set general parameters.
;
infile_num = 1
;
;	Set input file.
;
close, infile_num
openr, infile_num, infile
;
;	Read and list operation header.
;
if read_op_hdr(infile_num, -1, 1) eq 1 then return
;
;	Done.
;
print
end

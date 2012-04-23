pro fix_rec, infile, outfile, nmap=nmap
;+
;
;	procedure:  fix_rec
;
;	purpose:  fix the record (scan) headers of an operation
;
;	author:  rob@ncar, 2/93
;
;	assumptions:  - all data is present; only record headers are messed up
;		      - the first record header is correct
;		      - for Maps uses 'nfstep' as default number of frames of
;			movie to process
;
;	notes:  - the header error happened during instrument pauses in 6/92
;		  and 10/92
;
;	ex:  fix_rec, '21.fa.map', '21.fa.map.fixed'
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 2 then begin
	print
	print, "usage:  fix_rec, infile, outfile"
	print
	print, "	Fix the record (scan) headers of an operation."
	print
	print, "	Arguments"
	print, "		infile	   - input file name"
	print, "		outfile	   - output file name"
	print
	print, "	Keywords"
	print, "		nmap	   - number of movie maps to process"
	print, "			     (def=use 'nfstep' in Map header)"
	print
	print
	print, "   ex:  fix_rec, '02.fa.map', '02.fa.map.fixed'"
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
;	Get number of scans from op header common.
;
nscan = get_nscan()
;
;	Set number of maps of movie to process [uses op header common].
;
if (get_optype() eq 'Map') then begin
	if n_elements(nmap) eq 0 then nmap = nfstep
endif else begin
	if n_elements(nmap) ne 0 then message, 'Use "nmap" only for MAPs.'
	nmap = 1
endelse
;
;	Set other parameters.
;
true = 1
false = 0
header = lonarr(128)				; record header (512 bytes)
block = header					; generic block
nblocks = 1024					; (2*4*256*256)/512 blocks/rec
lscan = nscan - 1
seq_scan  = 0
last_scan = nmap * nscan - 1
label = ' (' + stringit(nscan) + ' total)'
;
;	Fix number of movie maps in operation header.
;
nfstep = long(nmap)
;
;	Write op header.
;
if writ_op_hdr(out_unit) eq 1 then $
	message, 'Error writing op header in "writ_op_hdr".'
;
;	Read first record header; grab and check date
;	(assuming first header is correct).
;
readu, in_unit, header
ryear = stringit(header(2))
if (ryear ne '92') and $
   (ryear ne '93') and $
   (ryear ne '94') and $
   (ryear ne '95') and $
   (ryear ne '96') and $
   (ryear ne '97') and $
   (ryear ne '98') and $
   (ryear ne '99') then $
	message, 'unacceptable date in 1st scan header (92-99):  ' + ryear
print, format='(/"... assuming run date is ''", A, "''"/)', ryear
;
;	Write first record header.
;
writeu, out_unit, header
;
;	****************************
;	LOOP FOR EACH MAP OF A MOVIE
;	****************************
;
for imap = 1, nmap do begin

;   Print sequential map number.
    if nmap gt 1 then print, '*************** Seq. MAP ' + stringit(imap) + $
			    ' ***************', format='(/A/)'
;
;	   ---------------------------
;	   LOOP FOR EACH SCAN OF A MAP
;	   ---------------------------
;
    for iscan = 0, lscan do begin
;
;	Print scan number.
	print, 'SCAN ' + stringit(iscan) + label
;
;	Process "nblocks" of data.---------------------------------------------
;
	seq_block = 0
	repeat begin 
;
;		Read a block.
		readu, in_unit, block
;
;		Grab the year field.
		year = stringit(block(2))
;
;		Process the block.
		if year eq ryear then begin		; a header, so save it
			print, $
				'   header out of place at seq block ' + $
				stringit(seq_block)
			header = block
		endif else begin			; data, so write it
			writeu, out_unit, block
			nblocks = nblocks - 1
		endelse
;
		seq_block = seq_block + 1
	endrep until (nblocks eq 0)
;
;	Process next block (should be a header).-------------------------------
;
	if seq_scan ne last_scan then begin
;
;		Read the block.
		readu, in_unit, block
;
;		Grab the year field.
		year = stringit(block(2))
;
;		Process the block.
		if year eq ryear then begin		; --- header ---
			header = block			; save header
			writeu, out_unit, header	; write header
			nblocks = 1024
		endif else begin			; --- data ---
			print, '   inserting old header'
			header(11) = iscan + 1		; fix scan number
			writeu, out_unit, header	; write header
			writeu, out_unit, block		; write data
			nblocks = 1023
		endelse
	endif
;
;	Increment sequential scan number.
	seq_scan = seq_scan + 1
;
    endfor
;
endfor
;-----------------------------------------
;
;	Close files and free unit numbers.
;
free_lun, in_unit, out_unit
print
;
end

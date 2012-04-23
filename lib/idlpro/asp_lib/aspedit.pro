pro aspedit, infile1, outfile, infile2,	             fscan0=fscan0,	$
	fscan1=fscan1, lscan1=lscan1, fscan2=fscan2, lscan2=lscan2,	$
	fmap1=fmap1,   lmap1=lmap1,   fmap2=fmap2,   lmap2=lmap2,	$
	version=version, new_scan=new_scan, movie=movie, exten=exten,	$
	verbose=verbose
;+
;
;	procedure:  aspedit
;
;	purpose:  edit ASP header values and/or concatenate ASP files
;
;	author:  rob@ncar, 11/92
;
;	notes:  - This routine assumes both inputs (on two input jobs) are
;		  of the same type and version (e.g., both maps, version 102),
;		  and in the case of movies, the number of scans/map is
;		  constant.
;
;		- The 'movie' keyword explicitly needed when creating a
;		  movie from two single-framed files.
;
;		- Normally, the original number of scans is automatically
;		  saved in the 'orig_nscan' operation header extension if
;		  that field is zero on entry (for use by the inversion code).
;		  Unfortunately, version 100 raw data has random garbage in
;		  the extension part of the header, thus the 'exten' keyword
;		  is provided with the following possible actions.
;
;	  'exten'		 version 100		 other versions
;	-----------		-------------		----------------
;
;	0 (not set)		extension zero'ed;	extension not zero'ed
;				orig_nscan = nscan	if orig_nscan eq 0 then
;							   orig_nscan = nscan
;	-1			extension not zero'ed
;				orig_nscan not set	(same as above)
;
;	[orig_nscan,		extension zero'ed	extension not zero'ed
;	 input_x1, input_y1]	entire triplet set	entire triplet set
;
;		- This routine can be expanded later as needed; right now
;		  it does only that which is currently needed (see usage
;		  and examples below).
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() lt 2) or (n_params() gt 3) then begin
	print
	print, "usage:  aspedit, infile1, outfile [, infile2]"
	print
	print, "	Edit ASP header values and/or concatenate ASP files."
	print
	print, "	Arguments"
	print, "	    infile1	- name of (first) input file"
	print, "	    outfile	- name of output file"
	print, "	    infile2	- name of optional second input file"
	print
	print, "	Keywords"
	print, "	    fscan0	- number to give first output scan"
	print, "			  (and to start each movie frame;
	print, "			  def=do not renumber scans)"
	print, "	    fscan1,	- first and last sequential scans of"
	print, "	     lscan1	  'infile1' to process (defs=all)"
	print, "	    fscan2,	- first and last sequential scans of"
	print, "	     lscan2	  'infile2' (if present; defs=all)"
	print, "	    fmap1,	- first and last sequential maps of"
	print, "	     lmap1	  'infile1' to process (defs=all)"
	print, "	    fmap2,	- first and last sequential maps of"
	print, "	     lmap2	  'infile2' (if present; defs=all)"
	print, "	    movie	- set to process double input job"
	print, "			  in movie mode; this mode set auto-"
	print, "			  matically if either input contains"
	print, "			  multiple maps (def=double input"
	print, "			  job concatenates scans into one"
	print, "			  single-framed operation)"
	print, "	    version	- version number to put in op header"
	print, "			  (def=assume version # in hdr is OK)"
	print, "	    exten	- 3-element vector to force setting"
	print, "			  of header extension values"
	print, "			  [orig_nscan, input_x1, input_y1]"
	print, "			  (see notes and examples)"
	print, "	    verbose	- if set print header information"
	print, "			  (def=do not print it)"
	print
	print
	print, "  ex1:  ; Fix version 100 op header extension and filler."
	print, "	aspedit,'10.fa.map','10.fa.OK'"
	print, "        ; Do not touch version 100 header extension/filler."
	print, "	aspedit,'11.fa.map','11.fa.OK',exten=-1"
	print, "        ; Explicitly set op header extension values."
	print, "	aspedit,'12.fa.map','12.fa.OK',exten=[100,2,0]"
	print
	print, "  ex2:  ; Fix short operation."
	print, "	aspedit,'13.fa.map','13.fa.OK',lscan1=144"
	print
	print, "  ex3:  ; Fix version number (as well as scan numbers)."
	print, "	aspedit,'15.fa.map','15.fa.OK',version=101"
	print, "        ; Same as before but only do 3 frames of the movie."
	print, "	aspedit,'15.fa.map','15.fa.OK',version=101,lmap1=2"
	print
	print, "  ex4:  ; Concatenate scans of two op's into one op."
	print, "	;  Use first 51 scans of the first map;"
	print, "	;  use all but the first scan of the second map."
	print, "	aspedit, '12.fa.part1','12.fa.whole','12.fa.part2',$"
	print, "		 'lscan1=50, fscan2=1"
	print
	print, "  ex5:  ; Concatenate frames of two movies into one movie."
	print, "	;  Use first three frames of movie1;"
	print, "	;  use only the fifth frame of movie2."
	print, "	aspedit, '12.fa.movie1','12.fa.out','12.fa.movie2',$"
	print, "		 'lmap1=2, fmap2=4, lmap2=4, /movie"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;       Specify common blocks.
;
@op_hdr.com
@scan_hdr.com
@iquv.com
;
;       Set types and sizes of common block variables.
;
@op_hdr.set
@scan_hdr.set
;
;	Set general variables.
;
false = 0
true  = 1
stdout_unit = -1
two_inputs = (n_params() eq 3)
do_verb = keyword_set(verbose)
do_renum = n_elements(fscan0) ne 0
;
;	Set up for exten keyword.
;
do_exten = true
do_triplet = false
case n_elements(exten) of
    0:  					; not set = default action
    1:  begin
	    if exten eq -1 then $		; -1 = leave extension
		do_exten = false $
	    else if exten ne 0 then message, $	; 0 = default; other = error
		"incorrect 'exten' keyword"
	end
    3:  do_triplet = true 			; triplet entered
 else:  message, "incorrect 'exten' keyword"
endcase
;
;==============================================================================
;
;	PROCESS (FIRST) INPUT OPERATION HEADER
;
;==============================================================================
;
;       Open and read (first) operation header.
;
openr, in_unit1, infile1, /get_lun
if read_op_hdr(in_unit1, stdout_unit, do_verb) eq 1 then begin
	close, in_unit1
	traceback & stop
endif
;
;       Set I,Q,U,V arrays, operation type, and version number
;	for general use [using operation header variables].
;
set_iquv
op_type = get_optype()
if n_elements(version) eq 0 then version = get_version()
;
;	Set scan numbers for (first) operation [uses op header variables].
;
nscan_avail = get_nscan()
if n_elements(fscan1) eq 0 then fscan1 = 0
if n_elements(lscan1) eq 0 then lscan1 = nscan_avail - 1
nscan1 = lscan1 - fscan1 + 1
if (fscan1 lt 0) or (lscan1 ge nscan_avail) or (nscan1 lt 1) then $
	message, 'Error specifying fscan1,lscan1 (' + $
		 stringit(fscan1) + ',' + stringit(lscan1) + ').'
;
;	Set map numbers for (first) operation [uses op header variables].
;
nmap_avail = get_nmap()
if n_elements(fmap1) eq 0 then fmap1 = 0
if n_elements(lmap1) eq 0 then lmap1 = nmap_avail - 1
nmap1 = lmap1 - fmap1 + 1
if (fmap1 lt 0) or (lmap1 ge nmap_avail) or (nmap1 lt 1) then $
	message, 'Error specifying fmap1,lmap1 (' + $
		 stringit(fmap1) + ',' + stringit(lmap1) + ').'
do_movie1 = (nmap1 gt 1)
;
;==============================================================================
;
;	PROCESS (SECOND) INPUT OPERATION HEADER
;
;==============================================================================
;
if two_inputs then begin
;
;       Open and read (second) operation header.
;
openr, in_unit2, infile2, /get_lun
if read_op_hdr(in_unit2, stdout_unit, do_verb) eq 1 then begin
	close, in_unit2
	traceback & stop
endif
;
;	Set scan numbers for (second) operation [uses op header variables].
;
nscan_avail = get_nscan()
if n_elements(fscan2) eq 0 then fscan2 = 0
if n_elements(lscan2) eq 0 then lscan2 = nscan_avail - 1
nscan2 = lscan2 - fscan2 + 1
if (fscan2 lt 0) or (lscan2 ge nscan_avail) or (nscan2 lt 2) then $
	message, 'Error specifying fscan2,lscan2 (' + $
		 stringit(fscan2) + ',' + stringit(lscan2) + ').'
;
;	Set map numbers for (second) operation [uses op header variables].
;
nmap_avail = get_nmap()
if n_elements(fmap2) eq 0 then fmap2 = 0
if n_elements(lmap2) eq 0 then lmap2 = nmap_avail - 1
nmap2 = lmap2 - fmap2 + 1
if (fmap2 lt 0) or (lmap2 ge nmap_avail) or (nmap2 lt 1) then $
	message, 'Error specifying fmap2,lmap2 (' + $
		 stringit(fmap2) + ',' + stringit(lmap2) + ').'
do_movie2 = (nmap2 gt 1)
;
endif
;
;==============================================================================
;
;	FINISH SETTING UP INPUTS
;
;==============================================================================
;
;	Determine total scans, total maps, and if in movie mode.
;
movie_mode = false
if two_inputs then begin
	if do_movie1 or do_movie2 or keyword_set(movie) then movie_mode = true
	if movie_mode then begin
		if nscan1 ne nscan2 then message, $
			'Movie frames not same size (' + stringit(nscan1) + $
			',' + stringit(nscan2) + ').'
		tnscan = nscan1
		tnmap = nmap1 + nmap2		; multiple-frame output
	endif else begin
		tnscan = nscan1 + nscan2
		tnmap = 1			; single-frame output
	endelse
endif else begin
	if do_movie1 then movie_mode = true
	tnscan = nscan1
	tnmap = nmap1
endelse
;
;	Jump to starting location(s) in input(s);
;	check that not using fscan/lscan in movie mode.
;
if movie_mode then begin
		if (fscan1 ne 0) or (lscan1 ne nscan_avail - 1) then $
			message, 'fscan1/lscan1 unsupported for movie mode.'

			skip_scan, in_unit1, fscan=fmap1*fscan1

	if two_inputs then begin
		if (fscan2 ne 0) or (lscan2 ne nscan_avail - 1) then $
			message, 'fscan2/lscan2 unsupported for movie mode.'

			skip_scan, in_unit2, fscan=fmap2*fscan2
	endif
endif else begin
			skip_scan, in_unit1, fscan=fscan1

	if two_inputs then $
			skip_scan, in_unit2, fscan=fscan2
endelse
;
;==============================================================================
;
;	PRINT OVERVIEW FOR USER
;
;==============================================================================
;
print
print, '**********************************************************************'
if movie_mode then begin
	print, ' - MOVIE MODE -'
	print
	print, " Number of maps to process from '" + infile1 + "':  " + $
		stringit(nmap1)
endif else begin
	print, ' - SINGLE OPERATION MODE -'
	print
	print, " Number of scans to process from '" + infile1 + "':  " + $
		stringit(nscan1)
endelse
if two_inputs then begin
    if movie_mode then begin
	print, " Number of maps to process from '" + infile2 + "':  " + $
		stringit(nmap2)
    endif else begin
	print, " Number of scans to process from '" + infile2 + "':  " + $
		stringit(nscan2)
    endelse
endif
print
if movie_mode then begin
	print, ' Total number of scans/map to output:  ' + stringit(tnscan)
	print, ' Total number of maps to output:       ' + stringit(tnmap)
endif else begin
	print, ' Total number of scans to output:  ' + stringit(tnscan)
endelse
print, '**********************************************************************'
;
;==============================================================================
;
;	SET UP OUTPUT FILE
;
;==============================================================================
;
;	Open output file.
;
openw, out_unit, outfile, /get_lun
;
;	Optionally zero filler and op header extension for version 100.
;
if (version eq 100) and do_exten then begin
	ofiller(*) = 0B
	orig_nscan=0L	& input_x1=0L	& input_y1=0L
endif
;
;	Set regular output header values.
;
put_version, version			; insert version number
put_nscan, tnscan			; insert number of scans
put_nmap, tnmap				; insert number of maps
;
;	Set header extension values.
;
if do_triplet then begin		; set with user-provied values
	orig_nscan = long(exten(0))
	input_x1   = long(exten(1))
	input_y1   = long(exten(2))
endif else if version ne 100 then begin	; not version 100
	if orig_nscan eq 0 then $	; (set if not already set)
		orig_nscan = nscan_avail
endif else begin			; version 100
	if do_exten then $		; (set unless told not to)
		orig_nscan = nscan_avail
endelse
;
;       Write out operation header.
;
if writ_op_hdr(out_unit) eq 1 then begin
	close, in_unit1, out_unit
	if two_inputs then close, in_unit2
	traceback & stop
endif
;
;==============================================================================
;
;	PROCESS FIRST INPUT DATA
;
;==============================================================================
;
;
if two_inputs then print, $
	format='(/"PROCESSING FIRST INPUT ...")'
;
;	****************************************
;	LOOP FOR EACH MAP OF A MOVIE (1ST INPUT)
;	****************************************
;
for seq_map = fmap1, lmap1 do begin
;
;  Initialize the first output scan number.
   if do_renum then snum_output = fscan0
;
;  Print map number for a movie.
   if movie_mode then print, stringit(seq_map), $
	format='(/"MAP ", A, " ------------------------------")'
;
;  Print title for scan number print.
   print, format='(/2A14)', 'Input Scan', 'Output Scan'
;
;	   ---------------------------------------
;	   LOOP FOR EACH SCAN OF A MAP (1ST INPUT)
;	   ---------------------------------------
;
   for seq_scan = 0, nscan1 - 1 do begin
;
;	Read scan header.
	if read_sc_hdr(in_unit1, stdout_unit, do_verb, $
		version=version) eq 1 then begin
		close, in_unit1, out_unit
		traceback & stop
	endif
;
;	Get input scan number.
	snum_input = s_snum
;
;	Edit scan header and print scan information.
	if do_renum then begin
		s_snum = long(snum_output)
		print, snum_input, snum_output, format='(2I14)'
		snum_output = snum_output + 1
	endif else $
		print, snum_input, snum_input,  format='(2I14)'
;
;	Write scan header.
        if writ_sc_hdr(out_unit, version=version) eq 1 then begin
		close, in_unit1, out_unit
		traceback & stop
	endif
;
;       Read scan data.
        if read_sc_data(in_unit1) eq 1 then begin
		close, in_unit1, out_unit
		traceback & stop
	endif
;
;	Write scan data.
	if writ_sc_data(out_unit, i, q, u, v) eq 1 then begin
		close, in_unit1, out_unit
		traceback & stop
	endif
;
   endfor
;
endfor
;
;---------------------------------------------
;
;	Close (first) input file and free unit number.
;
free_lun, in_unit1
;
;==============================================================================
;
;	PROCESS SECOND INPUT DATA
;
;==============================================================================
;
if two_inputs then begin
;
print, format='(/"PROCESSING SECOND INPUT ...")'
;
;
;	****************************************
;	LOOP FOR EACH MAP OF A MOVIE (2ND INPUT)
;	****************************************
;
for seq_map = fmap2, lmap2 do begin
;
;  Initialize the first output scan number if in movie mode.
   if movie_mode and do_renum then snum_output = fscan0
;
;  Print map number for a movie.
   if movie_mode then print, stringit(seq_map), $
	format='(/"MAP ", A, " ------------------------------")'
;
;  Print title for scan number print.
   print, format='(/2A14)', 'Input Scan', 'Output Scan'
;
;	   ---------------------------------------
;	   LOOP FOR EACH SCAN OF A MAP (2ND INPUT)
;	   ---------------------------------------
;
   for seq_scan = 0, nscan2 - 1 do begin
;
;	Read scan header.
	if read_sc_hdr(in_unit2, stdout_unit, do_verb, $
		version=version) eq 1 then begin
		close, in_unit2, out_unit
		traceback & stop
	endif
;
;	Get input scan number.
	snum_input = s_snum
;
;	Edit scan header and print scan information.
	if do_renum then begin
		s_snum = long(snum_output)
		print, snum_input, snum_output, format='(2I14)'
		snum_output = snum_output + 1
	endif else $
		print, snum_input, snum_input,  format='(2I14)'
;
;	Write scan header.
        if writ_sc_hdr(out_unit, version=version) eq 1 then begin
		close, in_unit2, out_unit
		traceback & stop
	endif
;
;       Read scan data.
        if read_sc_data(in_unit2) eq 1 then begin
		close, in_unit2, out_unit
		traceback & stop
	endif
;
;	Write scan data.
	if writ_sc_data(out_unit, i, q, u, v) eq 1 then begin
		close, in_unit2, out_unit
		traceback & stop
	endif
;
   endfor
;
endfor
;
;---------------------------------------------
;
;	Close (second) input file and free unit number.
;
free_lun, in_unit2
;
endif
;
;==============================================================================
;
;	Close output file and free unit number.
;
print
print, "Output to file:  '", outfile, "'"
print
free_lun, out_unit
;
;	Done.
;
end

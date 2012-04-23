pro split_spec, infile, outfile1, outfile2, $
		x1=x1, x2=x2, x3=x3, x4=x4, p1=p1, p2=p2, y1=y1, y2=y2, $
		fscan=fscan, lscan=lscan, noverb=noverb
;+
;
;	procedure:  split_spec
;
;	purpose:  split ASP spectra by wavelength into two files
;
;	author:  rob@ncar, 8/94
;
;	ex:  split_spec,'file.106','fileC.106','/dev/null',$
;			x1=15,x2=100,x3=101,x4=200
;
;	notes:  - Currently, the x1-x2 & x3-x4 ranges are allowed to overlap;
;		  however, the preamble may not overlap with either.
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 3 then begin
	print
	print, "usage:  split_spec, infile, outfile1, outfile2"
	print
	print, "	Split ASP spectra by wavelength into two files."
	print
	print, "	Arguments"
	print, "	      infile	- input filename"
	print, "	      outfile1	- first output filename"
	print, "	      outfile2	- second output filename"
	print
	print, "	Keywords"
	print, "	      x1, x2	- column range for outfile1"
	print, "			  (no defaults yet)"
	print, "	      x3, x4	- column range for outfile2"
	print, "			  (no defaults yet)"
	print, "	      p1, p2	- column range for preamble"
	print, "			  (defs=0, 14; p1=-1 means"
	print, "			  don't output preamble columns)"
	print, "	      y1, y2	- row range for both outputs"
	print, "			  (defs=all rows)"
	print, "	      fscan	- first seq. scan to output (def=0)"
	print, "	      lscan	- last seq. scan to output (def=last)"
	print, "	      noverb	- if set, turn off listing (def=list)"
	print
	print, " note:  If you don't want a second output, you may put"
	print, "        '/dev/null' for outfile2."
	print
	print
	print, "   ex:  split_spec, '02.ta.map', '02A.ta.map', '02B.ta.map', $"
	print, "                    x1=15, x2=100, x3=101, x4=200"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Set some parameters.
;
true  = 1
false = 0
stdout_unit = -1
do_verb = not keyword_set(noverb)
;
;	Set common blocks.
;
@op_hdr.com
@scan_hdr.com
@iquv.com
@op_hdr.set
@scan_hdr.set
;
;	Open input and output units.
;
openr, in_unit, infile, /get_lun
openw, out_unit1, outfile1, /get_lun
openw, out_unit2, outfile2, /get_lun
;
;	Read op header.
;
if read_op_hdr(in_unit, stdout_unit, 0) eq 1 then $
	message, 'Error reading op header in "read_op_hdr".'
;
;	Set I,Q,U,V arrays
;	(This is put after the op header is read because
;	 dnumx and dnumy are needed; see op_hdr common block.)
;
set_iquv
;
;	Get number of scans from op header common;
;	save original X and Y dimensions.
;
orig_nscan = get_nscan()
orig_dnumx = dnumx
orig_dnumy = dnumy
;
if n_elements(fscan) eq 0 then fscan = 0
if n_elements(lscan) eq 0 then lscan = orig_nscan - 1
if (fscan lt 0) or (lscan gt orig_nscan - 1) or (fscan gt lscan) then $
	message, 'Error specifying fscan/lscan.'
nscan = lscan - fscan + 1	; calculate number of output scans
if do_verb then print, format='(/A/)', $
	'Total number of scans to process is ' + stringit(nscan) + '.'
;
;	Set range of values to process.
;       (This is put after the op header is read because
;        dnumx and dnumy are needed.)
;
if (n_elements(x1) eq 0) or $
   (n_elements(x2) eq 0) or $
   (n_elements(x3) eq 0) or $
   (n_elements(x4) eq 0) then message, 'Error specifying x1,x2,x3,x4.'
if n_elements(y1) eq 0 then y1 = 0
if n_elements(y2) eq 0 then y2 = dnumy - 1
if n_elements(p1) eq 0 then p1 = 0
if n_elements(p2) eq 0 then p2 = 14
xlen1 = x2 - x1 + 1
xlen2 = x4 - x3 + 1
ylen  = y2 - y1 + 1
if (xlen1 lt 1) or (x1 lt 0) or (x2 gt dnumx-1) then $
	message, 'Error in specifying x1,x2.'
if (xlen2 lt 1) or (x3 lt 0) or (x4 gt dnumx-1) then $
	message, 'Error in specifying x3,x4.'
if (ylen  lt 1) or (y1 lt 0) or (y2 gt dnumy-1) then $
	message, 'Error in specifying y1,y2.'
;
;	Set number of output columns, including optional preamble.
;
if p1 eq -1 then do_pream = false $
	    else do_pream = true
if do_pream then begin
	plen = p2 - p1 + 1
	if (plen lt 1) or (p1 lt 0) then $
		message, 'Error in specifying p1,p2.'
	if (p2 ge x1) or (p2 ge x3) then message, $
		'Preamble (p1,p2) overlaps with data (x1,x2) or (x3,x4).'
	dnumx1 = plen + x2 - x1 + 1
	dnumx2 = plen + x4 - x3 + 1
endif else begin
	dnumx1 = x2 - x1 + 1
	dnumx2 = x4 - x3 + 1
endelse
;
;	Set general output op header values.
;
dnumy = long(ylen)
put_nscan, nscan
;
;	Write first op header.
;
dnumx = long(dnumx1)
if writ_op_hdr(out_unit1) eq 1 then $
	message, 'Error writing op header in "writ_op_hdr".'
;
;	Write second op header.
;
dnumx = long(dnumx2)
if writ_op_hdr(out_unit2) eq 1 then $
	message, 'Error writing op header in "writ_op_hdr".'
;
;       Jump to location of first scan to process.
;
dnumx = orig_dnumx	; restore original op header for skip_scan
dnumy = orig_dnumy
put_nscan, orig_nscan
skip_scan, in_unit, fscan=fscan
;
;-----------------------------------------
;
;	PROCESS EACH SCAN.
;
for iscan = fscan, lscan do begin

;	Read scan header.
	if read_sc_hdr(in_unit, stdout_unit, false) eq 1 then return

;	Optionally print scan number.
	if do_verb then print, $
		format='("(seq. ", A, ")  Scan: ", A)', $
		stringit(iscan), stringit(s_snum)

;	Read scan data.
	if read_sc_data(in_unit) eq 1 then return

;	Write scan headers.
	if writ_sc_hdr(out_unit1) eq 1 then return
	if writ_sc_hdr(out_unit2) eq 1 then return

;	Split and write scan data.
	if do_pream then begin
		if writ_sc_data(out_unit1, $
			[i(p1:p2, y1:y2), i(x1:x2, y1:y2)], $
			[q(p1:p2, y1:y2), q(x1:x2, y1:y2)], $
			[u(p1:p2, y1:y2), u(x1:x2, y1:y2)], $
			[v(p1:p2, y1:y2), v(x1:x2, y1:y2)]) eq 1 then return
		if writ_sc_data(out_unit2, $
			[i(p1:p2, y1:y2), i(x3:x4, y1:y2)], $
			[q(p1:p2, y1:y2), q(x3:x4, y1:y2)], $
			[u(p1:p2, y1:y2), u(x3:x4, y1:y2)], $
			[v(p1:p2, y1:y2), v(x3:x4, y1:y2)]) eq 1 then return
	endif else begin
		if writ_sc_data(out_unit1, $
			i(x1:x2, y1:y2), q(x1:x2, y1:y2), $
			u(x1:x2, y1:y2), v(x1:x2, y1:y2)) eq 1 then return
		if writ_sc_data(out_unit2, $
			i(x3:x4, y1:y2), q(x3:x4, y1:y2), $
			u(x3:x4, y1:y2), v(x3:x4, y1:y2)) eq 1 then return
	endelse

endfor
;-----------------------------------------
;
;       Close files and free unit numbers.
;
free_lun, in_unit, out_unit1, out_unit2
;
;
end

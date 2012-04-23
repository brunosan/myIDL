pro avgscans_i, infile, savefile, scans, aflag, $
	x1=x1, x2=x2, y1=y1, y2=y2, verbose=verbose, v101=v101
;+
;
;	function:  avgscans_i
;
;	purpose:  average the I spectra of the specified scans and write to
;		  IDL save file
;
;	author:  rob@ncar, 5/93
;
;	notes:  - write an 'avgscans.pro' to accompany this if needed
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  avgscans_i, infile, savefile, scans, aflag"
	print
	print, "	Average the I spectra of the specified scans and"
	print, "	write to IDL save file."
	print
	print, "	Arguments"
	print, "	    infile	- input ASP file"
	print, "	    savefile	- output save file"
	print, "	    scans	- array containing seq. scan numbers"
	print, "		          or a single scan # (0 = first scan)"
	print, "	    aflag	- flag indicating name of saved array"
	print, "			    0 = 'dark'"
	print, "			    1 = 'clear'"
	print
	print, "	Keywords"
	print, "	    x1, x2	- column range (defs=0 to last)"
	print, "	    y1, y2	- row range (defs=0 to last)"
	print, "	    verbose	- flag to print run-time info"
	print, "		              0 = no print (def)"
	print, "		              1 = print everything (/verbose)"
	print, "		              2 = print all but headers"
	print, "	    v101	- set to force version 101"
	print, "			  (def=use version # in op hdr)"
	print
	print
	print, "   ex:  avgscans_i, '01.fa.cal', '01.fa.clear.sav', $"
	print, "		    [1,2,3,5,7,8], 1, x1=1, y2=228"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Specify and set common blocks.
;
@op_hdr.com
@scan_hdr.com
@op_hdr.set
@scan_hdr.set
;
;	Set general parameters.
;
true = 1
false = 0
stdout_unit = -1
if (aflag lt 0) or (aflag gt 1) then $
	message, "'aflag' out of range 0 to 1"
;
;	Set verbose variables.
;
do_verb = false
do_head = false
if n_elements(verbose) ne 0 then $
	case verbose of
	   0:	  ; no verbose
	   1:	  begin  & do_verb=true  & do_head=true  & end
	   2:	  begin  & do_verb=true                  & end
	   else:  message, "invalid 'verbose'"
	endcase
;
;	Set scan list.
;
if sizeof(scans, 0) eq 0 then begin			; scalar
	scan_list = [scans]
	navg = 1
endif else if sizeof(scans, 0) eq 1 then begin		; array
	scan_list = scans
	navg = n_elements(scans)
	if navg eq 0 then message, 'no scans'
endif else begin					; error
	message, "'scans' must be a scalar or 1D array"
endelse
;
;	Set input file.
;
openr, infile_unit, infile, /get_lun
;
;	Read (and optionally list) operation header.
;
if read_op_hdr(infile_unit, stdout_unit, do_head) eq 1 then return
;
;	Set I,Q,U,V arrays
;	(must have set 'dnumx' and 'dnumy' in 'op_hdr'
;	 common block first -- from read_op_hdr).
;
set_iquv
;
;	Set X and Y ranges
;	(uses dnumx and dnumy from op header common block).
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
nx = x2 - x1 + 1
ny = y2 - y1 + 1
if (x1 gt x2) or (y1 gt y2) or $
   (x1 lt 0) or (y1 lt 0) or $
   (x2 gt dnumx-1) or (y2 gt dnumy-1) then $
	message, 'Error in specifying x1,y1,x2,y2.'
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then begin
	version = 101
	do_v101 = true
endif else begin
	version = get_version()
	do_v101 = false
endelse
;
;       Initialize (zero) array for averaging.
;
iav = fltarr(nx, ny)
;
;----------------------------------------------
;
;	LOOP FOR ALL SCANS
;
for iscan = 0, navg-1 do begin
;
;	Read scan (optionally print scan header).
	readscan, infile, scan_list(iscan), i, q, u, v, $
		x1=x1, x2=x2, y1=y1, y2=y2, v101=do_v101, nohead=1-do_head
;
;	Sum in I.
	iav = iav + i
;
endfor
;
;----------------------------------------------
;
;	Close input file.
;
free_lun, infile_unit
;
;	Save average.
;
case aflag of
	0: begin
		dark = iav / float(navg)
		save, file=savefile, dark
		if do_verb then print, format='(/A/)', $
			"Saving 'dark' to file " + savefile + ' ...'
	   end
	1: begin
		clear = iav / float(navg)
		save, file=savefile, clear
		if do_verb then print, format='(/A/)', $
			"Saving 'clear' to file " + savefile + ' ...'
	   end
	else: message, "error specifying 'aflag'"
endcase
;
;	Done.
;
end

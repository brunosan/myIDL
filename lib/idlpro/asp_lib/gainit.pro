pro gainit, infile, darkfile, clearfile, $
	x1=x1, x2=x2, y1=y1, y2=y2, ixst=ixst, fscan=fscan, lscan=lscan, $
	filtfile=filtfile, gainfile=gainfile, outfile=outfile, $
	xfile=xfile, tfile=tfile, verbose=verbose, $
	v101=v101
;+
;
;	procedure:  gainit
;
;	purpose:  calibrate ASP spectra (e.g., a map)
;
;	author:  rob@ncar, 5/92
;
;	usage:  From FLAT's (* = op #, e.g., 15 - 19):
;		- run flatavg to get 'clear.a.*'
;		- run flatavg to get 'dark.a.*'
;		- run flatavg to get a.nd.* from FLAT's (nd = neutral density)
;		- run buildgn to generate 'gaintable.save' (gaintbl)
;		- run gain_check to check if that gaintable is OK
;
;		Do for each CAL:
;		- run flatavg to get 'op#.fa.dark' (dark)
;		- run flatavg to get 'op#.fa.clear' (clear)
;			(e.g., op# = 01 from 01.fa.cal)
;		- run genfiltd to generate 'filtd' (filtd)
;
;		Do for each MAP:
;		- now run gainit
;
;	notes:  - THIS PROCEDURE HAS BEEN MADE OBSOLETE BY CALIBRATE.PRO
;
;		- flatavg is hardwired to chop out bad parts of the data,
;		  thus one should use x1=1, y2=228 here in gainit
;		- if neither xfile nor tfile are specified, then aspcal
;		  will be *not* invoked (i.e., no speed penalty)
;		- 'icross' has been removed from this code
;
;	WARNING - 'ixst' assumes wavelengths have NOT been flipped !!!
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 3 then begin
usage:
	print
	print, "usage:  gainit, infile, darkfile, clearfile"
	print
	print, "	Calibrate ASP spectra (e.g., a map)."
	print
	print, "	Arguments"
	print, "	    infile	- input file name"
	print, "	    darkfile	- input dark save file (from cal)"
	print, "	    clearfile	- input clear save file (from cal)"
	print
	print, "	Keywords"
	print, "	    x1, x1	- start/end columns (defs=0 to last)"
	print, "	    y1, y2	- start/end rows    (defs=0 to last)"
	print, "	    ixst	- index of first active X (def=15)"
	print, "	    fscan	- first scan to process (def=0)"
	print, "	    lscan	- last scan to process  (def=last)"
	print, "	    filtfile	- input filt table save file"
	print, "		          (def='filtd.save')"
	print, "	    gainfile	- input gain table save file"
	print, "		          (def='gaintable.save')"
	print, "	    xfile	- polarimeter response matrix file"
	print, "		          (def=do not apply an X)"
	print, "	    tfile	- T matrix parameter file"
	print, "		          (def=do not apply a T)"
	print, "	    outfile	- output file (def=op#.gainit.map,"
	print, "		          e.g., 2.gainit.map)"
	print, "	    verbose	- set to print extra run-time info"
	print, "	    v101	- set to force version 101"
	print, "	  	          (def=use version # in op hdr)"
	print
	print, "  ex1:  gainit, '18.fa.map', 'darka.16', 'cleara.16', $"
	print, "		x1=1, y2=228"
	print
	print, "  ex2:  gainit, '18.fa.map', 'darka.16', 'cleara.16', $"
	print, "		10, 22, 213, 228, x1=1, y2=228"
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
;	Set variables.
;
false = 0
true  = 1
stdout_unit = -1
do_verb = false
if keyword_set(verbose) then do_verb = true
if n_elements(ixst) eq 0 then ixst = 15
if n_elements(filtfile) eq 0 then filtfile = 'filtd.save'
if n_elements(gainfile) eq 0 then gainfile = 'gaintable.save'
;
;	Set up for X matrix.
;
do_xfile = true
if n_elements(xfile) eq 0 then begin
	xfile = 'nada'	& do_xfile = false
endif
;
;	Set up for T matrix.
;
do_tfile = true
if n_elements(tfile) eq 0 then begin
	tfile = 'nada'	& do_tfile = false
endif
;
;	Check if have to apply aspcal (i.e., X and/or T).
;
do_aspcal = false
if (do_xfile or do_tfile) then do_aspcal = true
;
;       Open, read, and possibly list input file.
;
openr, infile_unit, infile, /get_lun
if read_op_hdr(infile_unit, stdout_unit, true) eq 1 then return
;
;       Set I,Q,U,V arrays
;       (This is put after the op header is read because
;        dnumx and dnumy are needed; see op_hdr common block.)
;
set_iquv
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Get scan numbers.
;       (This is put after the op header is read because
;        need to get the number of scans in the operation.)
;
;	('orig_nscan' is a new op header value for inversion code.)
orig_nscan = get_nscan()
;
if n_elements(fscan) eq 0 then fscan = 0
if n_elements(lscan) eq 0 then lscan = orig_nscan - 1
if (fscan lt 0) or (lscan gt orig_nscan - 1) or (fscan gt lscan) then $
	message, 'Error specifying fscan/lscan.'
nscan = lscan - fscan + 1	; calculate output number of scans
;
;	Set range of values to process.
;       (This is put after the op header is read because
;        dnumx and dnumy are needed.)
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1

if x2 eq -1 then x2 = dnumx - 1		; (-1 means "use default")
if y2 eq -1 then y2 = dnumy - 1

xlen = x2 - x1 + 1
ylen = y2 - y1 + 1
if (xlen lt 1) or (ylen lt 1) or (x2 gt dnumx-1) or (y2 gt dnumy-1) then $
	message, 'Error in specifying x1,y1,x2,y2.'
;
;	Restore values from previous procedures.
;
gaintbl = 0
avgprof = 0
fitshft = 0
dark = 0
clear = 0
filtd = 0
print
restore, gainfile, verbose=do_verb		; gaintbl
print
restore, darkfile, verbose=do_verb		; dark
print
restore, clearfile, verbose=do_verb		; clear
print
restore, filtfile, verbose=do_verb		; filtd
print
;
;	Define output arrays.
;
iiout = fltarr(xlen, ylen, /nozero)
qqout = fltarr(xlen, ylen, /nozero)
uuout = fltarr(xlen, ylen, /nozero)
vvout = fltarr(xlen, ylen, /nozero)
;
;	Define grand multiplicative array.
;
gnarr = iiout
gnarr(*,*) = 1.0
;
;       Jump to location of first scan to process.
;
skip_scan, infile_unit, fscan=fscan
;
;	Set name of output file and open it.
;
if n_elements(outfile) eq 0 then outfile = stringit(opnum) + '.gainit.map'
openw, outfile_unit, outfile, /get_lun
;
;       Write out operation header.
;	(Changing:  dnumx, dnumy, optype;
;	   Adding:  orig_nscan, input_x1, input_y1;
;	     Also: 'nscan' [nmstep] changed via 'put_nscan')
;
dnumx = long(xlen)		; change dimensions of output data
dnumy = long(ylen)
if do_aspcal then put_optype, 'GainXT' $     ; change operation type
	     else put_optype, 'Gain'
put_nscan, nscan		; insert nscan in output op header (via optype)
input_x1 = long(x1)		; save x1 and y1 parameters used
input_y1 = long(y1)
if writ_op_hdr(outfile_unit) eq 1 then return
;
; --------------------------------------------
;
;	LOOP FOR EACH SCAN.
;
seq_scan = 0
;
for iscan = fscan, lscan do begin
;
;	Read scan header.
	if read_sc_hdr(infile_unit, stdout_unit, true, $
		version=version) eq 1 then return
;
;	Write scan header.
	if do_verb then print, '>>>>>>> write scan header (writ_sc_hdr) ...'
        if writ_sc_hdr(outfile_unit, version=version) eq 1 then return
;
;       Read scan data.
	if do_verb then print, '>>>>>>> read scan data (read_sc_data) ...'
        if read_sc_data(infile_unit) eq 1 then return
;
;       Chop out middle to use.
        ii = i(x1:x2, y1:y2)
        qq = q(x1:x2, y1:y2)
        uu = u(x1:x2, y1:y2)
        vv = v(x1:x2, y1:y2)
;
;	Remove dark.
	ii = ii - dark
;
;	Correct for RGB variations.
	if do_verb then print, '>>>>>>> correct for RGB (ofstc3) ...'
	ofstc3, ii, qq, uu, vv
;
;	Gain-correct clear port, results in out.
	if do_verb then print, '>>>>>>> gain-correct (gncorr) ...'
;;	gncorr, ii, gaintbl, out, ixst	; old routine, Rob 10/92
	if gncorr(ii, gaintbl, out, ixst) then $
		message, 'Fatal error in gncorr.'
;
;	Calculate output I.
	iiout = ii
	iiout(ixst:*,*) = out(ixst:*,*) * filtd(ixst:*,*)
;
;	Calculate grand multiplicative array.
	gnarr(ixst:*,*) = iiout(ixst:*,*) / (ii(ixst:*,*) > 1.0)
;
;	Multiply the G.M.A. by Q, U, and V.
	qqout(*,*) = qq(*,*) * gnarr(*,*)
	uuout(*,*) = uu(*,*) * gnarr(*,*)
	vvout(*,*) = vv(*,*) * gnarr(*,*)
;
;	Calibrate.
	if do_aspcal then begin
		if do_verb then print, '>>>>>>> calibrate (aspcal) ...'
        	aspcal, iiout, qqout, uuout, vvout, $
        		float(s_vtt(0)), float(s_vtt(1)), float(s_vtt(2)), $
			xtype, ttype, xfile=xfile, tfile=tfile
	endif
;
;	Flip the wavelengths left to right.
	if do_verb then print, '>>>>>>> flipping wavelength order (filpx) ...'
	flipx, iiout
	flipx, qqout
	flipx, uuout
	flipx, vvout
;
;	Write output scan.
	if do_verb then print, '>>>>>>> write scan (writ_sc_data) ...'
	if writ_sc_data(outfile_unit, iiout, qqout, uuout, vvout) eq 1 then $
		return
;
;	Increment sequential scan counter.
	seq_scan = seq_scan + 1
;
endfor
;
; --------------------------------------------
;
;	Close files and free unit numbers.
;
print
print, 'Output to ', outfile, '.'
print
free_lun, infile_unit, outfile_unit
;
;	Done.
;
end

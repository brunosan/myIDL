pro gain_merge_xt3,							$
	infile_a, infile_b, dark_a, dark_b, clear_a, clear_b,		$
	xmats, xlocs, xc1, xc2, xst, xend, yst, yend, outfile,		$
	yh1, yh2, yh3, yh4,						$
	gain_a=gain_a, gain_b=gain_b, filtd_a=filtd_a, filtd_b=filtd_b,	$
	x1=x1,x2=x2,y1=y1,y2=y2, ixst=ixst, fscan=fscan, lscan=lscan,	$
	bad_a=bad_a, bad_b=bad_b, sslope=sslope, tmat=tmat,		$
	plot=plot, verbose=verbose, time=time, v101=v101, keep=keep
;+
;
;	procedure:  gain_merge_xt3
;
;	purpose:  do 'gainit', 'abmerge', and 'gain_xt3', i.e.,
;		  flat-fielding, spectra merging, and calibration
;
;	author:  rob@ncar, 7/93
;
;	notes:  - THIS PROCEDURE HAS BEEN MADE OBSOLETE BY CALIBRATE.PRO
;		  (faster and doesn't output temporary files)
;
;	WARNING - 'ixst' assumes wavelengths have NOT been flipped for
;		  'gainit', and HAVE been flipped for 'abmerge' and 'gain_xt3'
;
;==============================================================================
;
;	Check number of parameters.
;
slope_no = 15
slope_yes = slope_no + 4
if (n_params() ne slope_no) and (n_params() ne slope_yes) then begin
usage:
	print
	print, "usage:  gain_merge_xt3, infile_a, infile_b,		$"
	print, "			dark_a, dark_b,			$"
	print, "		        clear_a, clear_b,		$"
	print, "		        xmats, xlocs, xc1, xc2,		$"
	print, "		        xst, xend, yst, yend,		$"
	print, "		        outfile [,yh1,yh2,yh3,yh4]"
	print
	print, "	Do 'gainit', 'abmerge', and 'gain_xt3', i.e.,"
	print, "	flat-fielding, spectra merging, and calibration."
	print
	print, "	Arguments"
	print, "	    infile_a,	- input data files for both cameras"
	print, "	     infile_b"
	print, "	    dark_a,	- input dark files for both cameras"
	print, "	     dark_b"
	print, "	    clear_a,	- input clear files for both cameras"
	print, "	     clear_b"
	print, "	    xmats	- array of X files to apply"
	print, "			  (see example below)"
	print, "	    xlocs	- array of corresponding Y locations"
	print, "			  (along slit) of matrices in 'xmats'"
	print, "	    xc1, xc2	- X (wavelength) range for continuum"
	print, "	    xst, xend	- wavelen. pixel range for merge corr"
	print, "	    yst, yend	- vertical pixel range for merge corr"
	print, "	    outfile	- name of output file for calib. data"
	print
	print, "	    yh1, yh2	- Y range of 1st hairline"
	print, "	    yh3, yh4	- Y range of 2nd hairline"
	print, "		          (see 'sslope' below)"
	print
	print, "	Keywords"
	print, "	    x1, x1	- start/end columns (defs=0 to last)"
	print, "	    y1, y2	- start/end rows    (defs=0 to last)"
	print, "	    tmat	- name of T matrix parameter file"
	print, "			  (def='T')"
	print, "	    sslope	- slope for use in de-skewing"
	print, "		              111  = use slope of bottom hair"
	print, "		              222  = avg slopes of both hairs"
	print, "		             other = use 'sslope' value"
	print, "		          (def=do not apply de-skewing)"
	print, "	    gain_a,	- input gaintable files"
	print, "	     gain_a	  (defs='gaintable.a','gaintable.b')"
	print, "	    filtd_a,	- input filtd files"
	print, "	     filtd_b	  (defs='filtd.a','filtd.b')"
	print, "	    bad_a,	- integer arrays containing sequential"
	print, "	     bad_b	  scan numbers of bad scans"
	print, "			  (defs=no bad scans)"
	print, "	    ixst	- index of first active X (def=15)"
	print, "	    fscan	- first scan to process (def=0)"
	print, "	    lscan	- last scan to process  (def=last)"
	print, "	    plot	- if set, produce 'abmerge.pro' plots"
	print, "			  (def=don't produce plots)"
	print, "	    verbose	- if set, print run-time info"
	print, "			  (def=don't print)"
	print, "	    time	- if set, print timing info (def=not)"
	print, "	    v101	- set to force version 101"
	print, "		          (def=use version # in op hdr)"
	print, "	    keep	- set to keep temporary files"
	print, "		          (def=remove them)"
	print
	print, "   ex:	; Note that *.a and *.b X matrices filenames will be"
	print, "	; generated automatically from 'xmats' entries.  Use"
	print, "	; the exact same format as the 'xmats' below."
	print
	print, "	xmats = [ 'X.19.xt_15.mrg'  , 'X.19.xt_85.mrg', $"
	print, "	          'X.19.xt_155.mrg' , 'X.19.xt_200.mrg' ]"
	print, "	xlocs = [15, 85, 155, 200]"
	print, "	gain_merge_xt3, '10.fa.map', '10.fb.map',	     $"
	print, "			'caldarka.00', 'caldarkb.00',	     $"
	print, "			'calcleara.00', 'calclearb.00',	     $"
	print, "			xmats, xlocs, 90,100, 70,100,15,215, $"
	print, "			'10.f.calib', 17,28,218,227, /verb,  $"
	print, "			x1=1, y2=228, sslope=222, bad_a=[12]"
	print
	return
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
do_time = keyword_set(time)
if do_time then void, timer(/init)	; start timer
;
temp_a = 'gainit_a'
temp_b = 'gainit_b'
temp_c = 'merge_ab'
;
do_plot = keyword_set(plot)
do_verb = keyword_set(verbose)
do_v101 = keyword_set(v101)
do_keep = keyword_set(keep)
;
if n_elements(ixst) eq 0 then ixst = 15
;
if n_elements(gain_a) eq 0 then gain_a = 'gaintable.a'
if n_elements(gain_b) eq 0 then gain_b = 'gaintable.b'
;
if n_elements(filtd_a) eq 0 then filtd_a = 'filtd.a'
if n_elements(filtd_b) eq 0 then filtd_b = 'filtd.b'
;
if n_elements(bad_a) eq 0 then bad_a = [-1]
if n_elements(bad_b) eq 0 then bad_b = [-1]
;
if n_elements(tmat) eq 0 then tmat = 'T'
;
if n_elements(sslope) eq 0 then sslope = 0.0
if (sslope eq 111) or (sslope eq 222) then $
	if n_params() ne slope_yes then begin
		print
		print, "Must specify 'yh1, yh2, yh3, yh4' to get slope!"
		print
		goto, usage
	endif
;
;	Get operation header for use below.
;
@op_hdr.com
@op_hdr.set
openr, unit, infile_a, /get_lun
if read_op_hdr(unit, -1, false) eq 1 then return
free_lun, unit
;
;	Get scan numbers.
;       (This is put after the op header is read because
;        need to get the number of scans in the operation.)
;
nscan_avail = get_nscan()
;
if n_elements(fscan) eq 0 then fscan = 0
if n_elements(lscan) eq 0 then lscan = nscan_avail - 1
if (fscan lt 0) or (lscan gt nscan_avail - 1) or (fscan gt lscan) then $
	message, 'Error specifying fscan/lscan.'
nscan = lscan - fscan + 1	; calculate output number of scans
;
;	Set spectral image dimensions (use 'dnumx','dnumy' frop op header).
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
;
;	Correct X (wavelength) indices for cropping & flipping during 'gainit'.
;
xc1_use  = x2 - xc2
xc2_use  = x2 - xc1
xst_use  = x2 - xend
xend_use = x2 - xst
;
;	Correct Y (along slit) indices for cropping during 'gainit'.
;
yst_use  = yst - y1
yend_use = yend - y1
yh1_use  = yh1 - y1
yh2_use  = yh2 - y1
yh3_use  = yh3 - y1
yh4_use  = yh4 - y1
;
;	Correct bad scan numbers for use in 'abmerge'.
;	Note that we are always dealing with sequential (not actual)
;	scan numbers, but that removal of scans via fscan/lscan
;	occurs in 'gainit', thus they are gone before 'abmerge'.
;
bad_a_use = bad_a
bad_b_use = bad_b
if fscan gt 0 then begin
	if n_elements(bad_a) gt 0 then bad_a_use = bad_a - fscan
	if n_elements(bad_b) gt 0 then bad_b_use = bad_b - fscan
endif
;
;-----------------------------------------------------
;
;	Do flat-fielding (apply bias and gain corrections).
;
gainit, infile_a, dark_a, clear_a, gain=gain_a, filt=filtd_a, $
	out=temp_a, x1=x1, x2=x2, y1=y1, y2=y2, fscan=fscan, $
	lscan=lscan, verbose=do_verb, v101=do_v101
gainit, infile_b, dark_b, clear_b, gain=gain_b, filt=filtd_b, $
	out=temp_b, x1=x1, y2=y2, fscan=fscan, lscan=lscan, $
	verbose=do_verb, v101=do_v101

;-----------------------------------------------------
;
;	Merge Camera A and B spectra.
;
abmerge, temp_a, temp_b, ixst, xst_use, xend_use, yst_use, yend_use, temp_c, $
	bada=bad_a_use, badb=bad_b_use, plot=do_plot, verbose=do_verb

;-----------------------------------------------------
;
;	Remove 1st 2 temporary files.
;
if not do_keep then spawn, '/bin/rm ' + temp_a + ' ' + temp_b

;-----------------------------------------------------
;
;	Do calibration, remove skew, remove residual I->QUV crosstalk.
;
if (sslope eq 111) or (sslope eq 222) then begin
	gain_xt3, temp_c, outfile, xmats, xlocs, 0, tmat=tmat, $
		ixst, xc1_use, xc2_use, yh1_use, yh2_use, yh3_use, yh4_use, $
		sslope=sslope, verbose=do_verb, v101=do_v101
endif else begin
	gain_xt3, temp_c, outfile, xmats, xlocs, 0, tmat=tmat, $
		ixst, xc1_use, xc2_use, $
		sslope=sslope, verbose=do_verb, v101=do_v101
endelse

;-----------------------------------------------------
;
;	Remove last temporary file.
;
if not do_keep then spawn, '/bin/rm ' + temp_c

;-----------------------------------------------------
;
;	Optionally print timing info.
;
if do_time then begin
	print, "Total elapsed time (" + stringit(nscan) + " scans):  ", $
		stringit(timer(tmin)), $
		format='(A, A, " hours, ", A, " mins, ", A, " secs", /)'
	print, "Minutes per scan:  " + float_str(tmin/nscan, 2), format='(A/)'
endif
;
;	Done.
;
end

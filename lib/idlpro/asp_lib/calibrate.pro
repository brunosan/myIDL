pro calibrate, map_a,map_b, dark_a,dark_b, filtd_a,filtd_b, gain_a,gain_b, $
	xfiles_a, xlocs, xc1,xc2, xst,xend, yst,yend, outfile, yh1,yh2,    $
	yh3,yh4, x1=x1,x2=x2,y1=y1,y2=y2, ixst=ixst, sslope=sslope,        $
	fscan=fscan,lscan=lscan, bad_a=bad_a,bad_b=bad_b, tfile=tfile,     $
	plot=plot, nsearch=nsearch, verbose=verbose, time=time, 	   $
	cameras=cameras, rev_scan=rev_scan, raw_nscan=raw_nscan, v101=v101
;+
;
;	procedure:  calibrate
;
;	purpose:  calibrate an ASP map (bias, RGB, and gain correct; flip
;		  wavelength order; merge A and B; apply Xs and T; remove
;		  skew and residual I->QUV crosstalk)
;
;	author:  rob@ncar, 8/93
;
;	notes:  - this program supersedes gain_merge_xt3.pro
;		- ('ixst' assumes wavelengths have NOT been flipped
;		   for 'calib_gain', and HAVE been for 'hair,wlcross,shftquv')
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() ne 17) and (n_params() ne 19) and (n_params() ne 21) then begin
	print
	print, "usage:  calibrate, map_a, map_b,		$"
	print, "		   dark_a, dark_b,		$"
	print, "		   filtd_a, filtd_b,		$"
	print, "		   gain_a, gain_b,		$"
	print, "		   xfiles_a, xlocs, xc1, xc2,	$"
	print, "		   xst, xend, yst, yend,	$"
	print, "		   outfile [,yh1,yh2 [,yh3,yh4]]"
	print
	print, "	Calibrate an ASP map (bias, rgb, and gain correct;"
	print, "	flip wavelength order; merge A and B; apply Xs and T;"
	print, "	remove skew and residual I->QUV crosstalk)."
	print
	print, "	Arguments"
	print, "	    map_a,	- input maps files for both cameras"
	print, "	     map_b	  (ASP data format)"
	print, "	    dark_a,	- input dark files for both cameras"
	print, "	     dark_b	  (IDL save files)"
	print, "	    filtd_a,	- input filtd files for both cameras"
	print, "	     filtd_b	  (IDL save files)"
	print, "	    gain_a,	- input gaintbl files for both cameras"
	print, "	     gain_b	  (IDL save files)"
	print, "	    xfiles_a	- array of camera A X files to apply"
	print, "			  (see example below)"
	print, "	    xlocs	- array of corresponding Y locations"
	print, "			  (along slit) of mat's in 'xfiles_a'"
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
	print, "	    tfile	- name of T matrix parameter file"
	print, "			  (def='T')"
	print, "	    sslope	- slope for use in de-skewing"
	print, "		              111  = use slope of one hair"
	print, "		                     (uses 'yh1' and 'yh2')"
	print, "		              222  = avg slopes of two hairs"
	print, "		                     ('yh1,yh2' & 'yh3,yh4')"
	print, "		             other = use 'sslope' value"
	print, "		          (def=do not apply de-skewing)"
	print, "	    bad_a,	- integer arrays containing sequential"
	print, "	     bad_b	  scan numbers of bad scans"
	print, "			  (defs=no bad scans)"
	print, "	    ixst	- index of first active X (def=15)"
	print, "	    fscan	- first seq. scan to process (def=0)"
	print, "	    lscan	- last seq. scan to process (def=last)"
	print, "	    plot	- flag to produce plots"
	print, "		              0 = no plots (def)"
	print, "		              1 = produce plots (/plot)"
	print, "		              2 = pause after each plot"
	print, "	    nsearch	- search range for cross-corr. maximum"
	print, "			  (def=5)"
	print, "	    verbose	- flag to print run-time info"
	print, "		              0 = no print (def)"
	print, "		              1 = print everything (/verbose)"
	print, "		              2 = print all but headers"
	print, "	    time	- flag to print timing info"
	print, "		              0 = no print (def)"
	print, "		              1 = print for every scan (/time)"
	print, "		              2 = print only at end of job"
	print, "	    cameras	- choice of cameras to process"
	print, "		             'a_only' = process only camera A"
	print, "		             'b_only' = process only camera B"
	print, "		             'both' = process both A & B (def)"
	print, "	    rev_scan	- beginning date [year, month, day]"
	print, "			  of runs when scan order must be"
	print, "			  reversed (def=[93,11,1])"
	print, "	    raw_nscan	- original no. of scans in raw data;"
	print, "			  used in setting 'orig_nscan' in the"
	print, "			  op hdr extension for the inversion"
	print, "			  code; set for version 100 short ops"
	print, "		          (v100 def=use nscan from header;"
	print, "		           else def=use nscan if orig_nscan=0)"
	print, "	    v101	- set to force version 101"
	print, "		          (def=use version # in op hdr)"
	print
	print, "   ex:	; Note that 'b' (Camera B) and 'ab' (Merged A & B)"
	print, "	; X matrices filenames will be generated automatically"
	print, "	; from 'xfiles_a' entries by substitution for 'a'."
	print
	print, "	xfiles_a = [ '19.fa.15.X'  , '19.fa.85.X', $"
	print, "	             '19.fa.155.X' , '19.fa.200.X' ]"
	print, "	xlocs    = [ 15, 85, 155, 200 ]"
	print, "	calibrate, '10.fa.map',        '10.fb.map',         $"
	print, "		   '03.fa.dark.sav',   '03.fb.dark.sav',    $"
	print, "		   '03.fa.filtd.sav',  '03.fb.filtd.sav',   $"
	print, "		   'gaintbl.fa.sav',   'gaintbl.fb.sav',    $"
	print, "		    xfiles_a, xlocs,    90, 100,            $"
	print, "		    115,190,  10,228,  '10.fab.cmap',       $"
	print, "		    10,20,    0,0,      x1=1, y2=228,       $"
	print, "		    sslope=111, bad_a=[12], verb=2, /time"
	print
	return
endif
;-
;
;       Specify and set common blocks.
;
@op_hdr.com
@scan_hdr.com
@iquv.com
@op_hdr.set
@scan_hdr.set
;
;	Set general variables.
;
false = 0
true  = 1
do_quit = false
stdout_unit = -1
if n_elements(ixst) eq 0 then ixst = 15
if n_elements(nsearch) eq 0 then nsearch = 5
if n_elements(rev_scan) eq 0 then rev_scan = [93, 11, 1]
if not equal(size(rev_scan), size([0,0,0]), /noverb) then $
	message, 'rev_scan must be a 3-D integer array'
a_good = true
b_good = true
;
;	Set timing variables.
;
do_time = false
do_time_end = false
if n_elements(time) ne 0 then $
	case time of
	   0:	  ; no timing done
	   1:	  begin  & do_time=true  & do_time_end=true  & end
	   2:	  do_time_end = true
	   else:  message, "invalid 'time'"
	endcase
if (do_time or do_time_end) then void, timer(/init)	; start timer
;
;	Set verbose variables.
;
do_verb = false
do_head = false
do_line = false
if n_elements(verbose) ne 0 then $
	case verbose of
	   0:	  ; no verbose
	   1:	  begin  & do_verb=true  & do_head=true  & end
	   2:	  begin  & do_verb=true  & do_line=true  & end
	   else:  message, "invalid 'verbose'"
	endcase
;
;	Set cameras to process.
;
if n_elements(cameras) eq 0 then cameras = 'both'
if (cameras ne 'a_only') and $
   (cameras ne 'b_only') and $
   (cameras ne 'both') then $
	message, "invalid 'cameras' ('a_only', 'b_only', or 'both')"
;
;	Set skew variables.
;
do_skew = false
if (n_elements(sslope) ne 0) then if (sslope ne 0.0) then do_skew = true
if do_skew then begin
	do_hair = false
	if (sslope eq 111) then begin
		do_hair = true
		if (n_params() ne 19) and (n_params() ne 21) then $
			message, "Specify 'yh1, yh2' for sslope=111!"
		yh3_use = 0
		yh4_use = 0
		onehair = true
	endif else if (sslope eq 222) then begin
		do_hair = true
		if n_params() ne 21 then $
			message, "Specify 'yh1, yh2, yh3, yh4' for sslope=222!"
		yh3_use = yh3
		yh4_use = yh4
		onehair = false
	endif
endif
;
;       Open files and read op headers for both cameras.
;	(Read camera A last so working with that op header, e.g.,
;	 tape number is different.)
;
if cameras ne 'a_only' then begin
	openr, map_b_unit, map_b, /get_lun
	if read_op_hdr(map_b_unit, stdout_unit, do_head) eq 1 then return
endif
if cameras ne 'b_only' then begin
	openr, map_a_unit, map_a, /get_lun
	if read_op_hdr(map_a_unit, stdout_unit, do_head) eq 1 then return
endif
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
hdr_nscan = get_nscan()
;
if n_elements(fscan) eq 0 then fscan = 0
if n_elements(lscan) eq 0 then lscan = hdr_nscan - 1
if (fscan lt 0) or (lscan gt hdr_nscan - 1) or (fscan gt lscan) then $
	message, 'Error specifying fscan/lscan.'
nscan = lscan - fscan + 1	; calculate output number of scans
if do_verb then print, format='(/A)', $
	'Total number of scans to process is ' + stringit(nscan) + '.'
;
;	Set range of values to process.
;       (This is put after the op header is read because
;        dnumx and dnumy are needed.)
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
if x2 eq -1 then x2 = dnumx - 1			; (-1 means "use default")
if y2 eq -1 then y2 = dnumy - 1
xlen = x2 - x1 + 1
ylen = y2 - y1 + 1
if (xlen lt 1) or (ylen lt 1) or (x2 gt dnumx-1) or (y2 gt dnumy-1) then $
	message, 'Error in specifying x1,y1,x2,y2.'
;
;	Correct indices for use in merging routines
;	(since spectra will be cropped and flipped in wavelength).
;	[Note:  'wlcross.pro' and what is calls has many hardwires
;	 expecting wavelength to be flipped.]
;
xst_use  = x2   - xend
xend_use = x2   - xst
yst_use  = yst  - y1
yend_use = yend - y1
;
;	Correct indices for use in I->QUV crosstalk removal
;	(since spectra will be flipped in wavelength).
;
xc1_use  = x2 - xc2
xc2_use  = x2 - xc1
;
;	Define scratch arrays.
;
i_scr = fltarr(xlen, ylen, /nozero)
q_scr = fltarr(xlen, ylen, /nozero)
u_scr = fltarr(xlen, ylen, /nozero)
v_scr = fltarr(xlen, ylen, /nozero)
;
;	Restore values from previous procedures.
;
calib_res, dark_a,dark_b, filtd_a,filtd_b, gain_a,gain_b, $
	   a_dark, a_filtd, a_gaintbl, 			  $
	   b_dark, b_filtd, b_gaintbl, 			  $
	   cameras=cameras, verbose=do_verb
;
;	Set bad scan arrays.
;
if cameras ne 'b_only' then begin
	if n_elements(bad_a) eq 0 then bad_a = [-1]
	if sizeof(bad_a, 0) ne 1 then  message, "'bad_a' must be a 1D array"
endif
if cameras ne 'a_only' then begin
	if n_elements(bad_b) eq 0 then bad_b = [-1]
	if sizeof(bad_b, 0) ne 1 then  message, "'bad_b' must be a 1D array"
endif
;
;	Set up (optional) plotting.
;
do_pause = false
do_plot = keyword_set(plot)
if do_plot then begin
	do_pause = (plot eq 2)
	xsize = 256 * 2
	ysize = 256 * 2

	if cameras eq 'a_only' then begin
		title = outfile + ' from ' + map_a + ' (no merging)'
	endif else if cameras eq 'b_only' then begin
		title = outfile + ' from ' + map_b + ' (no merging)'
	endif else begin
		title = 'merging:   ' + outfile + ' = ' + map_a + ' + ' + map_b
	endelse

;	Open plotting window.
	window, /free, xsize=xsize, ysize=ysize, title=title
	xoff = 128
	yoff = 245
endif
;
;	Read in and interpolate X matrices for all positions along slit.
;
calib_xmat, xfiles_a, xlocs, y1, y2, xmats_a, xmats_b, xmats_ab, $
	cameras=cameras
if cameras eq 'a_only' then xmats_use = xmats_a
if cameras eq 'b_only' then xmats_use = xmats_b
;
;       Jump to location of first scan to process for both cameras.
;
if cameras ne 'b_only' then skip_scan, map_a_unit, fscan=fscan
if cameras ne 'a_only' then skip_scan, map_b_unit, fscan=fscan
;
;	Open output file.
;
openw, outfile_unit, outfile, /get_lun
;
;       Modify regular part of output header
;	(dnumx, dnumy, optype, merged, nscan|nmstep).
;
dnumx = long(xlen)		; change X dimension of output data
dnumy = long(ylen)		; change Y dimension of output data
put_optype, 'GainXT'		; change operation type
merged = 1L			; set merged flag
put_nscan, nscan		; insert nscan in output op header (via optype)
;
;	Modify extension part of output header
;	(orig_nscan, input_x1, input_y1).
;
if n_elements(raw_nscan) ne 0 then begin   ; set with user value
	orig_nscan = long(raw_nscan)
endif else if version eq 100 then begin	   ; v100 -- set with header value
	orig_nscan = hdr_nscan
endif else begin			   ; other -- set if not already set
	if orig_nscan eq 0 then $
		orig_nscan = hdr_nscan
endelse
input_x1 = long(x1)		; set with input values
input_y1 = long(y1)		; (assume no previous trimming done)
;
;       Write out operation header.
;
if writ_op_hdr(outfile_unit) eq 1 then return
;
; --------------------------------------------
;	LOOP FOR EACH SCAN.
; --------------------------------------------
;
for iscan = fscan, lscan do begin
;
;	Optionally print timing info.
	if do_time then print, stringit(timer()), $
	       format='(/"Elapsed time:  ",A," hours, ",A," mins, ",A," secs")'
;
;	Read scan headers.
	if cameras ne 'b_only' then $
		if read_sc_hdr(map_a_unit, stdout_unit, do_head, $
			version=version) eq 1 then return
	if cameras ne 'a_only' then $
		if read_sc_hdr(map_b_unit, stdout_unit, do_head, $
			version=version) eq 1 then return
;
;	Optionally print scan number.
	if do_line then print, $
		format='( /, "(seq. ", A, ")  Scan: ", A, 2X, 55A )', $
		stringit(iscan), stringit(s_snum), replicate('-', 55)
;
;	Check bad scan lists.
	if cameras ne 'b_only' then begin
		if in_set(bad_a, iscan)  then a_good=false  else a_good=true
	endif
	if cameras ne 'a_only' then begin
		if in_set(bad_b, iscan)  then b_good=false  else b_good=true
	endif
;
;	Read camera A scan; optionally bias, RGB, and gain correct,
;	and flip wavelength order; optionally plot image.
	if cameras ne 'b_only' then begin
		calib_gain, map_a_unit, a_good, a_dark, a_filtd, a_gaintbl, $
			ixst, x1,x2,y1,y2, 'A', ai,aq,au,av, verbose=do_verb
		if do_plot then begin
			erase
			x = 0		& y = 256	& tvscl, ai, x, y
			xyouts, x+xoff, y+yoff, 'Input A', align=0.5, /device
			xyouts, x, y+yoff, 'SCAN ' + stringit(iscan), /device
		endif
	endif
;
;	Read camera B scan; optionally bias, RGB, and gain correct,
;	and flip wavelength order; optionally plot image.
	if cameras ne 'a_only' then begin
		calib_gain, map_b_unit, b_good, b_dark, b_filtd, b_gaintbl, $
			ixst, x1,x2,y1,y2, 'B', bi,bq,bu,bv, verbose=do_verb
		if do_plot then begin
			x = 256		& y = 256	& tvscl, bi, x, y
			xyouts, x+xoff, y+yoff, 'Input B', align=0.5, /device
		endif
	endif
;
;	---------------
;	 MERGING START
;	---------------
;
	if (cameras eq 'a_only') and a_good then begin

; ------------- Processing A Only:  A Good ----------------------------

;		Print verbose message.
		if do_verb then print, format='(/A)', $
			'>>>>>>> processing A channel only ...'

;		Use unshifted A channel data.

;		Set merge field in scan header.
		s_merge = A_ONLY

	endif else if (cameras eq 'a_only') and (not a_good) then begin

; ------------- Processing A Only:  A Bad -----------------------------

;		Print verbose message.
		if do_verb then print, format='(/A)', $
			'>>>>>>> using previous scan (A bad) ...'

;		Use previous good scan.
		ai = ai_prev
		aq = aq_prev
		au = au_prev
		av = av_prev

;		Set merge field in scan header.
		s_merge = USED_PREV

	endif else if (cameras eq 'b_only') and b_good then begin

; ------------- Processing B Only:  B Good ----------------------------

;		Print verbose message.
		if do_verb then print, format='(/A)', $
			'>>>>>>> processing B channel only ...'

;		Use unshifted B channel data.

;		Set merge field in scan header.
		s_merge = B_ONLY

	endif else if (cameras eq 'b_only') and (not b_good) then begin

; ------------- Processing B Only:  B Bad -----------------------------

;		Print verbose message.
		if do_verb then print, format='(/A)', $
			'>>>>>>> using previous scan (B bad) ...'

;		Use previous good scan.
		bi = bi_prev
		bq = bq_prev
		bu = bu_prev
		bv = bv_prev

;		Set merge field in scan header.
		s_merge = USED_PREV

	endif else if a_good and b_good then begin

; ------------- Processing Both Channels:  Both Good ------------------

;		Print verbose message.
		if do_verb then print, format='(/A)', $
			'>>>>>>> merging A and B (both good) ...'

;		Shift and difference the B channel from A channel.
		wlcross, ai, bi, xst_use, xend_use, yst_use, yend_use, $
			ixst, nsearch, wdel, sdel, wlfit, slfit, bn, diff

;		Optionally display difference of shifted images.
		if do_plot then begin
			temm = ai - bi
			temm = (temm > (-2000)) < 2000		; clip
			x = 0   & y = 0   & tvscl, temm, x, y
			xyouts, x+xoff, y+yoff, 'Difference', align=0.5, $
				/device
		endif
;
;		Save intensity images.
;		Average the intensity images, replace into ai array.
		ai = (ai + bi) / 2.0

;		Shift q,u,v images.
		shftquv, aq, bq, ixst, wlfit, slfit, bn, diff
		shftquv, au, bu, ixst, wlfit, slfit, bn, diff
		shftquv, av, bv, ixst, wlfit, slfit, bn, diff

;		Replace a-images with differences.
		aq = (aq - bq) / 2.0
		au = (au - bu) / 2.0
		av = (av - bv) / 2.0

;		Set merge field in scan header.
		s_merge = A_AND_B

	endif else if (not a_good) and b_good then begin

; ------------- Processing Both Channels:  A Bad, B Good --------------

;		Print verbose message.
		if do_verb then print, format='(/A)', $
			'>>>>>>> using B channel only (A bad) ...'

;		Shift B channel with previous good shift
;		parameters, and use B channel only.
		shftquv, ai, bi, ixst, wlfit, slfit, bn, diff
		ai = bi

;		Shift q,u,v images.
		shftquv, aq, bq, ixst, wlfit, slfit, bn, diff
		shftquv, au, bu, ixst, wlfit, slfit, bn, diff
		shftquv, av, bv, ixst, wlfit, slfit, bn, diff
		aq = bq
		au = bu
		av = bv

;		Set merge field in scan header.
		s_merge = B_ONLY

	endif else if a_good and (not b_good) then begin

; ------------- Processing Both Channels:  A Good, B Bad --------------

;		Print verbose message.
		if do_verb then print, format='(/A)', $
			'>>>>>>> using A channel only (B bad) ...'

;		Use unshifted A channel data.

;		Set merge field in scan header.
		s_merge = A_ONLY

	endif else begin

; ------------- Processing Both Channels:  Both Bad (e.g., clouds) ----

;		Print verbose message.
		if do_verb then print, format='(/A)', $
			'>>>>>>> using previous scan (A and B bad) ...'

;		Use previous good scan.
		ai = ai_prev
		aq = aq_prev
		au = au_prev
		av = av_prev

;		Set merge field in scan header.
		s_merge = USED_PREV

	endelse
;
;	Save current scan.
	if cameras eq 'b_only' then begin
		bi_prev = bi
		bq_prev = bq
		bu_prev = bu
		bv_prev = bv
	endif else begin
		ai_prev = ai
		aq_prev = aq
		au_prev = au
		av_prev = av
	endelse
;
;	Optionally pause after plotting.
	if do_pause then begin
		pause, $
		   '(1=stop pauses; 2=stop plots; q=quit; else continue)', $
		   ans=ans
		case ans of
		   '1':	  do_pause = false
		   '2':	  begin & do_pause=false & do_plot=false & end
		   'q':	  begin & do_quit=true & goto,quit & end
		   else:  ; (continue)
		endcase
	endif

;	Optionally plot spectra.
	if do_plot then begin
		erase
		if cameras eq 'both' then title='Merged ' else title=''

		x = 0   & y=256      & tvscl, ai, x, y
		xyouts, x+xoff, y+yoff, title+'I', align=0.5, /device

		xyouts, x, y+yoff, 'SCAN ' + stringit(iscan), /device

		x = 256 & y=256      & tvscl, aq, x, y
		xyouts, x+xoff, y+yoff, title+'Q', align=0.5, /device

		x = 0   & y=0        & tvscl, au, x, y
		xyouts, x+xoff, y+yoff, title+'U', align=0.5, /device

		x = 256 & y=0        & tvscl, av, x, y
		xyouts, x+xoff, y+yoff, title+'V', align=0.5, /device
	endif
;
;	Optionally pause after plotting.
	if do_pause then begin
		pause, $
		   '(1=stop pauses; 2=stop plots; q=quit; else continue)', $
		   ans=ans
		case ans of
		   '1':	  do_pause = false
		   '2':	  begin & do_pause=false & do_plot=false & end
		   'q':	  begin & do_quit=true & goto,quit & end
		   else:  ; (continue)
		endcase
	endif
;
;	-------------
;	 MERGING END
;	-------------
;
;	Define the right X matrices according to merge status.
	if cameras eq 'both' then $
		case s_merge of
		   A_AND_B:	xmats_use = xmats_ab
		   A_ONLY:	xmats_use = xmats_a
		   B_ONLY:	xmats_use = xmats_b
		   USED_PREV:	; (do nothing -- using previous 'xmats_use')
		   else:	message, "invalid 's_merge'"
		endcase
;
;	Calculate slope for skew (optional) if first scan to process.
	if (iscan eq fscan) and (do_skew) then begin
		slope_use = sslope
		if do_hair then begin
			if do_verb then print, format='(/A)', $
				'>>>>>>> get slope of hairline(s) (hair) ...'
			if cameras eq 'b_only' then begin
				hair, bi, yh1, yh2, yh3_use, yh4_use, $
					slope_use, ixst, verb=false, $
					onehair=onehair
			endif else begin
				hair, ai, yh1, yh2, yh3_use, yh4_use, $
					slope_use, ixst, verb=false, $
					onehair=onehair
			endelse
		endif
		if do_verb then $
			print, "Slope for 'skew.pro' is:  " + $
				stringit(slope_use), format='(/A/)'
	endif
;
;	Apply Xs and T; remove skew and residual I->QUV crosstalk.
	if cameras eq 'b_only' then begin
		calib_xt, xmats_use, tfile, do_skew, slope_use, $
			xc1_use, xc2_use, bi,bq,bu,bv, $
			i_scr,q_scr,u_scr,v_scr, verbose=do_verb
	endif else begin
		calib_xt, xmats_use, tfile, do_skew, slope_use, $
			xc1_use, xc2_use, ai,aq,au,av, $
			i_scr,q_scr,u_scr,v_scr, verbose=do_verb
	endelse
;
;	Write scan header.
	if do_verb then print, '>>>>>>> write scan header (writ_sc_hdr) ...'
	if writ_sc_hdr(outfile_unit, version=version) eq 1 then return
;
;	Write scan data.
	if do_verb then print, '>>>>>>> write scan (writ_sc_data) ...'
	if cameras eq 'b_only' then begin
		if writ_sc_data(outfile_unit, bi, bq, bu, bv) eq 1 then return
	endif else begin
		if writ_sc_data(outfile_unit, ai, aq, au, av) eq 1 then return
	endelse

;	Optionally plot spectra.
	if do_plot then begin
		erase
		title='Calibrated '

		x = 0   & y=256
		if cameras eq 'b_only' then tvscl, bi, x, y $
				       else tvscl, ai, x, y
		xyouts, x+xoff, y+yoff, title+'I', align=0.5, /device

		xyouts, x, y+yoff, 'SCAN ' + stringit(iscan), /device

		x = 256 & y=256
		if cameras eq 'b_only' then tvscl, bq, x, y $
				       else tvscl, aq, x, y
		xyouts, x+xoff, y+yoff, title+'Q', align=0.5, /device

		x = 0   & y=0
		if cameras eq 'b_only' then tvscl, bu, x, y $
				       else tvscl, au, x, y
		xyouts, x+xoff, y+yoff, title+'U', align=0.5, /device

		x = 256 & y=0
		if cameras eq 'b_only' then tvscl, bv, x, y $
				       else tvscl, av, x, y
		xyouts, x+xoff, y+yoff, title+'V', align=0.5, /device
	endif
;
;	Optionally pause after plotting.
	if do_pause then begin
		pause, $
		   '(1=stop pauses; 2=stop plots; q=quit; else continue)', $
		   ans=ans
		case ans of
		   '1':	  do_pause = false
		   '2':	  begin & do_pause=false & do_plot=false & end
		   'q':	  begin & do_quit=true & goto,quit & end
		   else:  ; (continue)
		endcase
	endif
;
endfor

; --------------------------------------------
;
;	Close files and free unit numbers.
;
quit:
  if cameras ne 'b_only' then free_lun, map_a_unit
  if cameras ne 'a_only' then free_lun, map_b_unit
  free_lun, outfile_unit
if do_quit then return
;
;	Optionally reverse order of scans.
;
if (year gt rev_scan(0)) or $
   (year eq rev_scan(0) and month gt rev_scan(1)) or $
   (year eq rev_scan(0) and month eq rev_scan(1) and day ge rev_scan(2)) $
  then begin
	if do_verb then print, '>>>>>>> reversing scans (rev_scans) ...'
	outfile_temp = outfile + '.temp'
	rev_scans, outfile, outfile_temp
	spawn, '/bin/mv ' + outfile_temp + ' ' + outfile
endif
;
;	Optionally print output file name.
;
if do_verb then print, format='(/A/)', "Output to " + outfile + "."
;
;	Optionally print timing info.
;
if do_time_end then begin
	print, "Total elapsed time (" + stringit(nscan) + " scans):  ", $
		stringit(timer(tmin)), $
		format='(A, A, " hours, ", A, " mins, ", A, " secs", /)'
	print, "Minutes per scan:  " + float_str(tmin/nscan, 2), format='(A/)'
endif
;
;	Tell user the calibration is done.
;
spawn, '/home/hao/stokes/bin/calibrate.sub'
;
;	Done.
;
end

pro abmerge, infile_a, infile_b, ixst,xst,xend,yst,yend, outfile, $
	fscan=fscan, lscan=lscan, bada=bada, badb=badb, plot=plot, $
	verbose=verbose
;+
;
;	procedure:  abmerge
;
;	purpose:  Merge the a- and b-channels for a camera into a single file.
;		  Uses the two intensity images to determine shifts in both
;		  wavelength and slit directions.  Uses Fourier shifting to
;		  shift b-channel with respect to a-channel.  Outputs file
;		  with average intensity (Ia+Ib)/2, and merged polarization
;		  images: (Qa-Qb)/2, (Ua-Ub)/2, (Va-Vb)/2.  Accepts gain/dark
;		  corrected data as input.
;		  CAUTION:  SHOULD NOT BE USED ON OUT-OF-FOCUS CALIBRATION
;		  DATA!  WILL NOT FIND VERTICAL SHIFTS PROPERLY.  USE
;		  ROUTINE calmerge.pro FOR THOSE FILES.
;
;	author:  lites@ncar, 4/93	(minor mod's by rob@ncar)
;
;	notes:  - THIS PROCEDURE HAS BEEN MADE OBSOLETE BY CALIBRATE.PRO
;		- details are omitted for early 10/92 data
;		- scans are read the easy (but slow) way
;		- some 'hardwired' variables below
;
;	WARNING - 'ixst' assumes wavelengths HAVE been flipped !!!
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 8 then begin
	print
	print, "usage:  abmerge, infile_a, infile_b, ixst,xst,xend,yst,yend, $"
	print, "		 outfile"
	print
	print, "	Merge the a- and b-channels into a single file."
	print, "	(Note:  use 'calmerge' to merge calibration files.)"
	print
	print, "	Arguments"
	print, "	    infile_a	- input file name, a-channel"
	print, "	    infile_b	- input file name, b-channel"
	print, "	    ixst	- number of non-data columns on"
	print, "			  *right* side of the spectra"
	print, "	    xst, xend	- wavelength pixel range for corr"
	print, "	    yst, yend	- vertical pixel range for corr"
	print, "	    outfile	- output file name"
	print
	print, "	Keywords"
	print, "	    fscan	- first seq. scan to process (def=0)"
	print, "	    lscan	- last seq. scan to process (def=last)"
	print, "	    bada,	- integer arrays containing sequential"
	print, "	     badb	  scan numbers of bad scans for"
	print, "			  cameras a and b (defs=no bad scans)"
	print, "	    plot	- if set, produce run-time plots"
	print, "			  (def=don't produce plots)"
	print, "	    verbose	- if set, print run-time info"
	print, "			  (def=don't print)"
	print
	print
	print, "   ex:  abmerge, '02.fa.map', '02.fb.map', 15, 60, 90, $"
	print, "		 13, 215, '02.fab.map'"
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
@scan_hdr.com
@scan_hdr.set
;
;	Set general parameters.
;
true = 1
false = 0
do_plot = false
do_verb = false
if keyword_set(plot) then do_plot = true
if keyword_set(verbose) then do_verb = true
;
;	Set bad scan arrays.
;
if n_elements(bada) eq 0 then bada = [-1]
if n_elements(badb) eq 0 then badb = [-1]
if sizeof(bada, 0) ne 1 then  message, "'bada' must be a 1D array"
if sizeof(badb, 0) ne 1 then  message, "'badb' must be a 1D array"
;
;	Open input and output units.
;
openr, in_unit_a, infile_a, /get_lun
openr, in_unit_b, infile_b, /get_lun
openw, out_unit, outfile, /get_lun
;
;	Read op header, a-channel.
;
if read_op_hdr(in_unit_a, -1, 0) eq 1 then $
	message, 'Error reading op header in "read_op_hdr".'
;
;	Write op header.
;
merged = 1L			; set flag in op header
if writ_op_hdr(out_unit) eq 1 then $
	message, 'Error writing op header in "writ_op_hdr".'
;
;	Read op header, b-channel.
;
if read_op_hdr(in_unit_b, -1, 0) eq 1 then $
	message, 'Error reading op header in "read_op_hdr".'
;
;	Get number of scans from op header common.
;
nscan_avail = get_nscan()
if n_elements(fscan) eq 0 then fscan = 0
if n_elements(lscan) eq 0 then lscan = nscan_avail - 1
nscan = lscan - fscan + 1
if (fscan lt 0) or (lscan ge nscan_avail) or (nscan lt 1) then $
	message, 'Error specifying fscan/lscan.'
if do_verb then begin
	print
	print, 'Total number of scans to process is ' + stringit(nscan) + '.'
	print
endif
;
;	Set up (optional) plot window.
;
if do_plot then begin
	xsize = 256 * 2
	ysize = 256 * 2
	title = 'abmerge:   ' + outfile + ' = ' + infile_a + ' + ' + infile_b
	window, /free, xsize=xsize, ysize=ysize, title=title
	xoff = 128
	yoff = 245
endif
;
;
;-----------------------------------------
;
;	PROCESS EACH SCAN.
;
for iscan = fscan, lscan do begin

;	Read in gain corrected a-channel data.
	readscan, infile_a, iscan, ai, aq, au, av
	if do_plot then begin
		erase
		x = 0
		y = 256
		tvscl, ai, x, y
		xyouts, x+xoff, y+yoff, 'Input A', align=0.5, /device
		xyouts, x, y+yoff, 'SCAN ' + stringit(iscan), /device
	endif

;	Read in gain corrected b-channel data.
	readscan, infile_b, iscan, bi, bq, bu, bv
	if do_plot then begin
		x = 256
		y = 256
		tvscl, bi, x, y
		xyouts, x+xoff, y+yoff, 'Input B', align=0.5, /device
	endif

;	Shift and difference the b-channel from a-channel.
	aim=ai
	bim=bi
	nsearch = 5	; hardwired search range for cross-corr. maximum

;	Check for bad scans.
	if in_set(bada, iscan)  then a_good = false  else a_good = true
	if in_set(badb, iscan)  then b_good = false  else b_good = true

	if a_good and b_good then begin

; ------------- Both a- and b-channels good. process normally.

		wlcross,aim,bim,xst,xend,yst,yend,ixst,nsearch, $
			wdel,sdel,wlfit,slfit,bn,diff, plot=do_plot

;		Temporary insert to display difference of shifted images.
		temm = aim-bim
		temm = (temm < (-2000)) > 2000	; clip to range -2000 to 2000
		if do_plot then begin
			x = 0
			y = 0
			tvscl, temm, x, y
			xyouts, x+xoff, y+yoff, 'Difference', align=0.5, $
				/device
		endif

;		Save intensity images.
;		Average the intensity images, replace into ai array.
		ai = (aim+bim)/2.

;		Shift q,u,v images.
		shftquv,aq,bq,ixst,wlfit,slfit,bn,diff
		shftquv,au,bu,ixst,wlfit,slfit,bn,diff
		shftquv,av,bv,ixst,wlfit,slfit,bn,diff

;		Replace a-images with differences.
		aq = (aq-bq)/2.
		au = (au-bu)/2.
		av = (av-bv)/2.

;		Set merge field in scan header.
		s_merge = A_AND_B

	endif else if (not a_good) and b_good then begin

; ------------- a-channel bad, b-channel good.

;		Shift b-channel with previous good shift
;		parameters, and use b-channel only.
		shftquv,aim,bim,ixst,wlfit,slfit,bn,diff
		ai = bim

;		Shift q,u,v images.
		shftquv,aq,bq,ixst,wlfit,slfit,bn,diff
		shftquv,au,bu,ixst,wlfit,slfit,bn,diff
		shftquv,av,bv,ixst,wlfit,slfit,bn,diff
		aq = bq
		au = bu
		av = bv

;		Set merge field in scan header.
		s_merge = B_ONLY

	endif else if a_good and (not b_good) then begin

; ------------- a-channel good, b-channel bad.

;		Use unshifted a-channel data.

;		Set merge field in scan header.
		s_merge = A_ONLY

	endif else begin

; ------------- Both a- and b-channels bad (e.g., completely cloud covered).

;		Use previous good scan.
		ai = aisv
		aq = aqsv
		au = ausv
		av = avsv

;		Set merge field in scan header.
		s_merge = USED_PREV

	endelse
;
;	Save current scan.
	aisv = ai
	aqsv = aq
	ausv = au
	avsv = av
;
;	Optionally plot spectra.
	if do_plot then begin
		erase

		x = 0   & y=256      & tvscl, ai, x, y
		xyouts, x+xoff, y+yoff, 'Final I', align=0.5, /device

		xyouts, x, y+yoff, 'SCAN ' + stringit(iscan), /device

		x = 256 & y=256      & tvscl, aq, x, y
		xyouts, x+xoff, y+yoff, 'Final Q', align=0.5, /device

		x = 0   & y=0        & tvscl, au, x, y
		xyouts, x+xoff, y+yoff, 'Final U', align=0.5, /device

		x = 256 & y=0        & tvscl, av, x, y
		xyouts, x+xoff, y+yoff, 'Final V', align=0.5, /device
	endif
;
;	Write scan.
	writscan, out_unit, ai, aq, au, av
;
endfor
;-----------------------------------------
;
;       Close files and free unit numbers.
;
free_lun, in_unit_a, in_unit_b, out_unit
;
end

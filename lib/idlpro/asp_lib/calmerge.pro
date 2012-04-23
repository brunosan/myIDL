pro calmerge, infile_a, infile_b, xst,xend,yst,yend, outfile, $
	fscan=fscan, lscan=lscan, bada=bada, badb=badb, plot=plot, $
	verbose=verbose
;+
;
;	procedure:  calmerge
;
;	purpose:  merge the a- and b-channels calibration 
;                 data files into a single file.  OUTPUT TO BE USED ONLY
;                 FOR POLARIZATION CALIBRATION PURPOSES.  DARK FRAME, CLEAR
;		  FRAMES WILL BE ALTERED TO WORK FOR POL CAL ONLY.  MUST
; 		  USE RAW DATA TO GET FLAT-FIELD IMAGES, NOT THE RESULTS FROM
;		  FROM THIS MERGING.
;                 Unlike abmerge.pro, no shifts in wavelength or along slit
;		  direction are calculated or applied.  First (dark) image
; 		  is subtracted from all subsequent images, and first image
;  		  is replaced by zeros in output file.  Only a renormalization
;   		  of the b-channel intensity to a-channel is retained.
;                 Remainder of output images have average intensity (Ia+Ib)/2,
;                 and merged polarization images: (Qa-Qb)/2, (Ua-Ub)/2,
;                 (Va-Vb)/2. 
;                 This routine computes the renormalization of a and b
;                 channels only from the 8 clear port frames at beginning,
;                 then uses that average for the rest of the polarization
;                 frames.  CAUTION: CAL RUNS AFTER 1992 WILL NEED TO BE TREATED
;                 DIFFERENTLY.
;
;	author:  lites@ncar, 4/93	(minor mod's by rob@ncar)
;
;	notes:  - details are omitted for early 10/92 data
;		- scans are read the easy (but slow) way
;		- some 'hardwired' variables below
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 7 then begin
	print
	print, "usage:  calmerge, infile_a,infile_b, xst,xend,yst,yend, $"
	print, "		  outfile"
	print
	print, "	Merge the a- and b-channel calibration data."
	print, "	(Note:  use 'abmerge' to merge maps.)"
	print
	print, "	Arguments"
	print, "	     infile_a	- input file name, a-channel"
	print, "	     infile_b	- input file name, b-channel"
	print, "	     xst	- start wavelength pixel for corr"
	print, "	     xend	- end wavelength pixel for corr"
	print, "	     yst	- start vertical pixel for corr"
	print, "	     yend	- end vertical pixel for corr"
	print, "	     outfile	- output file name"
	print
	print, "	Keywords"
	print, "	     fscan	- first seq. scan to process (def=0)"
	print, "	     lscan	- last seq. scan to process (def=last)"
	print, "	     bada,	- integer arrays containing sequential"
	print, "	      badb	  scan numbers of bad scans for"
	print, "			  cameras a and b (defs=no bad scans)"
	print, "	     plot	- if set, produce run-time plots"
	print, "			  (def=don't produce plots)"
	print, "	     verbose	- if set, print run-time info"
	print, "			  (def=don't print)"
	print
	print
	print, "   ex:  calmerge, '02.fa.cal', '02.fb.cal', $"
	print, "		  18,238,13,215, '02.fab.cal'"
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
merged = 1L		; set flag in op header
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
	title = 'calmerge:   ' + outfile + ' = ' + infile_a + ' + ' + infile_b
	window, /free, xsize=xsize, ysize=ysize, title=title
	xoff = 128
	yoff = 245
endif
;
;-----------------------------------------
;
;	PROCESS EACH SCAN.
;
bnsv = 0.0
nsv = 0
for iscan = fscan, lscan do begin

;	Read in a-channel data.
	readscan, infile_a, iscan, ai, aq, au, av
	if do_plot then begin
		erase
		x = 0
		y = 256
		tvscl, ai, x, y
		xyouts, x+xoff, y+yoff, 'Input A', align=0.5, /device
		xyouts, x, y+yoff, 'SCAN ' + stringit(iscan), /device
	endif

	if iscan eq 0 then begin
		diffsv = ai
		diffsv(*,*) = 0.
	endif

;	Read in b-channel data.
	readscan, infile_b, iscan, bi, bq, bu, bv
	if do_plot then begin
		x = 256
		y = 256
		tvscl, bi, x, y
		xyouts, x+xoff, y+yoff, 'Input B', align=0.5, /device
	endif

	if iscan eq 0 then begin
		darka = ai
		darkb = bi
		goto, cond
	endif

;	Shift and difference the b-channel from a-channel.
	aim=ai-darka	; dark subtraction  
	bim=bi-darkb	; dark subtraction  
	xst = 18
	xend = 238
	yst = 13
	yend = 215

;	Check for bad scans.
	if in_set(bada, iscan)  then a_good = false  else a_good = true
	if in_set(badb, iscan)  then b_good = false  else b_good = true

	if a_good and b_good then begin

; ------------- Both a- and b-channels good, process normally.

;		Develop average for normalizing constants.
		if iscan eq 9 then begin
			diffsv = diffsv/float(nsv)
			bnsv = bnsv/float(nsv)
			diff = diffsv
			bn = bnsv
		endif
		if iscan ge 1 and iscan le 8 then begin
			nsv = nsv+1
			calcross,aim,bim,xst,xend,yst,yend,bn,diff, $
				plot=do_plot
			bnsv = bnsv + bn
			diffsv = diffsv + diff
		endif else begin
			bim = bim*diffsv*bnsv
		endelse

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

;		Renormalize q,u,v images.
		bq = bq*diff*bn
		bu = bu*diff*bn
		bv = bv*diff*bn

;		Replace a-images with differences.
		aq = (aq-bq)/2.
		au = (au-bu)/2.
		av = (av-bv)/2.

;		Set merge field in scan header.
		s_merge = A_AND_B

	endif else if (not a_good) and b_good then begin

; ------------- a-channel bad, b-channel good.

;		Renormalize b-channel with previous good
;		parameters, and use b-channel only.
		if iscan eq 9 then begin
			diffsv = diffsv/float(nsv)
			bnsv = bnsv/float(nsv)
			diff = diffsv
			bn = bnsv
		endif
		bim = bi*diff*bn
		ai = bim

;		Renormalize q,u,v images.
		bq = bq*diff*bn
		bu = bu*diff*bn
		bv = bv*diff*bn
		aq = bq
		au = bu
		av = bv

;		Set merge field in scan header.
		s_merge = B_ONLY

	endif else if a_good and (not b_good) then begin

; ------------- a-channel good, b-channel bad.

;		Use only a-channel data.
		if iscan eq 9 then begin
			diffsv = diffsv/float(nsv)
			bnsv = bnsv/float(nsv)
			diff = diffsv
			bn = bnsv
		endif

;		Set merge field in scan header.
		s_merge = A_ONLY

	endif else begin

; ------------- Both a- and b-channels bad (e.g., completely cloud covered).

;		Use previous good scan.
		if iscan eq 9 then begin
			diffsv = diffsv/float(nsv)
			bnsv = bnsv/float(nsv)
			diff = diffsv
			bn = bnsv
		endif
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
;	Reset dark image to zero.
cond:	if iscan eq 0 then begin
		ai(*) = 0.
		aq(*) = 0.
		au(*) = 0.
		av(*) = 0.
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

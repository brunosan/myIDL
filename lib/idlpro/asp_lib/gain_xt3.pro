pro gain_xt3, infile, outfile, xmats, xlocs, ttype, $
	ixst, xc1, xc2, yh1, yh2, yh3, yh4, $
	tmat=tmat, fscan=fscan, lscan=lscan, sslope=sslope, $
	verbose=verbose, v101=v101
;+
;
;	procedure:  gain_xt3
;
;	purpose:  Apply X's (vary along slit) and T.  X's are applied
;		  according to the merge status in the scan header.
;		  Skew correction and I->QUV crosstalk removal are also
;		  performed.
;
;	author:  rob@ncar, 3/93		(modified by vmp@hao)
;
;	notes:  - THIS PROCEDURE HAS BEEN MADE OBSOLETE BY CALIBRATE.PRO
;
;	WARNING - 'ixst' assumes wavelengths HAVE been flipped !!!
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() ne 8) and (n_params() ne 12) then begin
usage:
	print
	print, "usage:  gain_xt3, infile, outfile, xmats, xlocs, ttype"
	print, "		  ixst, xc1, xc2 [,yh1,yh2,yh3,yh4]"
	print
	print, "	Apply X's (vary along slit) and T.  X's are applied"
	print, "	according to the merge status in the scan header."
	print, "	Skew correction and I->QUV crosstalk removal are also"
	print, "	performed."
	print
	print, "	Arguments"
	print, "	    infile	- name of file to calibrate"
	print, "	    outfile	- name of output file"
	print, "	    xmats	- array of X files to apply"
	print, "			  (see example below)"
	print, "	    xlocs	- array of corresponding Y locations"
	print, "			  (along slit) of matrices in 'xmats'"
	print, "	    ttype	- type of T matrix to apply"
	print, "		          (see get_t.pro for choices)"
	print, "	    ixst	- number of non-data columns on"
	print, "			  *right* side of the spectra"
	print, "	    xc1, xc2	- X (wavelength) range for continuum"
	print
	print, "	    yh1, yh2	- Y range of 1st hairline"
	print, "	    yh3, yh4	- Y range of 2nd hairline"
	print, "		          (see 'sslope' below)"
	print
	print, "	Keywords"
	print, "	    tmat	- name of T parameter file"
	print, "		          (for ttype of 0)"
	print, "	    fscan	- first seq. scan to process (def=0)"
	print, "	    lscan	- last seq. scan to process (def=last)"
	print, "	    sslope	- slope for use in de-skewing"
	print, "		              111  = use slope of bottom hair"
	print, "		              222  = avg slopes of both hairs"
	print, "		             other = use 'sslope' value"
	print, "		          (def=do not apply de-skewing)"
	print, "	    verbose	- if set, print run-time information"
	print, "			  (def=don't print it)"
	print, "	    v101	- set to force version 101"
	print, "		          (def=use version # in op hdr)"
	print
	print, "   ex:	; Note that *.a and *.b X matrices filenames will be"
	print, "	; generated automatically from 'xmats' entries.  Use"
	print, "	; the exact same format as the 'xmats' below."
	print
	print, "	in    = '01.merge'"
	print, "	out   = '01.merge_xt'"
	print, "	xmats = [ 'X.19.xt_15.mrg'  , 'X.19.xt_85.mrg'  , $"
	print, "	          'X.19.xt_155.mrg' , 'X.19.xt_200.mrg' ]"
	print, "	xlocs = [15, 85, 155, 200]"
	print, "	tmat  = 'part_3.6302los4'"
	print, "	gain_xt3, in, out, xmats, xlocs, 0, 15, 155, 175, $"
	print, "		17, 28, 218, 227, sslope=222, tmat=tmat, /verb"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
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
true = 1
false = 0
stdout_unit = -1
do_verb = keyword_set(verbose)
;
;	Set skew variables.
;
do_skew = false
if (n_elements(sslope) ne 0) then if (sslope ne 0.0) then do_skew = true
if do_skew then begin
	do_hair = false
	if (sslope eq 111) or (sslope eq 222) then begin
		do_hair = true
		if n_params() ne 12 then begin
			print
			print, "Specify 'yh1, yh2, yh3, yh4' to get slope!"
			print
			goto, usage
		endif
		if (sslope eq 111) then onehair=true  else onehair=false
	endif
endif
;
;	Set up X matrices arrays.
;
x_mat = fltarr(4, 4, /nozero)
n_xmats = sizeof(xmats, 1)
xmats_ab = fltarr(n_xmats, 4, 4, /nozero)
xmats_a = fltarr(n_xmats, 4, 4, /nozero)
xmats_b = fltarr(n_xmats, 4, 4, /nozero)
xmatsa = xmats
xmatsb = xmats

cc = xmats(0)			; ex: 'X.19.xt_15.mrg'	-> 'X.19.xt_15.a'
strput, cc, 'a', 11
xmatsa(0) = strmid(cc, 0, 12)
cc = xmats(0)			;			-> 'X.19.xt_15.b'
strput, cc, 'b', 11
xmatsb(0) = strmid(cc, 0, 12)

cc = xmats(1)			; ex: 'X.19.xt_85.mrg'	-> 'X.19.xt_85.a'
strput, cc, 'a', 11
xmatsa(1) = strmid(cc, 0, 12)
cc = xmats(1)			;			-> 'X.19.xt_85.b'
strput, cc, 'b', 11
xmatsb(1) = strmid(cc, 0, 12)

cc = xmats(2)			; ex: 'X.19.xt_155.mrg'	-> 'X.19.xt_155.a'
strput, cc, 'a', 12
xmatsa(2) = strmid(cc, 0, 13)
cc = xmatsb(2)			;			-> 'X.19.xt_155.b'
strput, cc, 'b', 12
xmatsb(2) = strmid(cc, 0, 13)

cc = xmats(3)			; ex: 'X.19.xt_200.mrg'	-> 'X.19.xt_200.a'
strput, cc, 'a', 12
xmatsa(3) = strmid(cc, 0, 13)
cc = xmatsb(3)			;			-> 'X.19.xt_200.b'
strput, cc, 'b', 12
xmatsb(3) = strmid(cc, 0, 13)

;
;	Read in X matrices:  merged data.
;
str = ' '
for m = 0, n_xmats - 1 do begin
	openr, unit, xmats(m), /get_lun
	readf,unit,str  & readf,unit,str  & readf,unit,str  & readf,unit,str
	readf, unit, x_mat
	free_lun, unit
	xmats_ab(m, *, *) = invert(transpose(x_mat))
endfor
;
;	Read in X matrices:  camera a only.
;
for m = 0, n_xmats - 1 do begin
	openr, unit, xmatsa(m), /get_lun
	readf,unit,str  & readf,unit,str  & readf,unit,str  & readf,unit,str
	readf, unit, x_mat
	free_lun, unit
	xmats_a(m, *, *) = invert(transpose(x_mat))
endfor
;
;	Read in X matrices:  camera b only.
;
for m = 0, n_xmats - 1 do begin
	openr, unit, xmatsb(m), /get_lun
	readf,unit,str  & readf,unit,str  & readf,unit,str  & readf,unit,str
	readf, unit, x_mat
	free_lun, unit
	xmats_b(m, *, *) = invert(transpose(x_mat))
endfor
;
;	Set T parameters.
;
if ttype eq 0 then begin
	if n_elements(tmat) eq 0 then begin
		print
		print, 'ttype/tmat error ...'
		goto, usage
	endif
	do_tmat = true
endif else begin
	if n_elements(tmat) ne 0 then begin
		print
		print, 'ttype/tmat error ...'
		goto, usage
	endif
	do_tmat = false
endelse
;
;       Open, read, and possibly list input file.
;
openr, in_unit, infile, /get_lun
if read_op_hdr(in_unit, stdout_unit, do_verb) eq 1 then return
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
;	Interpolate X matrices for all positions along slit.
;
ny = dnumy				; (dnumy is from op header)
ny1 = ny - 1
xmats_all = fltarr(ny, 4, 4, /nozero)
xmats_abl = fltarr(ny, 4, 4, /nozero)
xmats_al  = fltarr(ny, 4, 4, /nozero)
xmats_bl  = fltarr(ny, 4, 4, /nozero)
;
for y = 0, ny1 do begin
	xmats_abl(y,  *, *) = interp4x4(xmats_ab, xlocs, y)
	xmats_al( y,  *, *) = interp4x4(xmats_a,  xlocs, y)
	xmats_bl( y,  *, *) = interp4x4(xmats_b,  xlocs, y)
endfor
;
;	Define more arrays.
;
ii = fltarr(dnumx, dnumy, /nozero)	; temporary variables
qq = fltarr(dnumx, dnumy, /nozero)
uu = fltarr(dnumx, dnumy, /nozero)
vv = fltarr(dnumx, dnumy, /nozero)
;
;	Get scan numbers.
;       (This is put after the op header is read because
;        need to get the number of scans in the operation.)
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
;	Jump to location of first scan to view.
;
skip_scan, in_unit, fscan=fscan
;
;	Open output file.
;
openw, out_unit, outfile, /get_lun
;
;       Write out operation header.
;
put_optype, 'GainXT'	; change operation type
put_nscan, nscan	; insert nscan in output op header (using optype)
if writ_op_hdr(out_unit) eq 1 then return
;
;---------------------------------------------
;
;	LOOP FOR EACH SCAN.
;
for iscan = fscan, lscan do begin
;
;	Read scan header.
	if read_sc_hdr(in_unit, stdout_unit, false, $
		version=version) eq 1 then return
;
;	Write scan header.
        if writ_sc_hdr(out_unit, version=version) eq 1 then return
;
;	Optionally print scan number.
	if do_verb then $
		print, '(seq. ' + stringit(iscan) + ')  Scan: ' + $
			stringit(s_snum) + $
			'  ---------------------------------------'
;
;       Read scan data.
        if read_sc_data(in_unit) eq 1 then return
;
;	Define the right X matrices according to merge status.
	case s_merge of
		A_AND_B:    xmats_all = xmats_abl
		A_ONLY:	    xmats_all = xmats_al
		B_ONLY:	    xmats_all = xmats_bl
		USED_PREV:  ; (do nothing -- using previous 'xmats_all')
		else:       message, "invalid 's_merge' in scan header"
	endcase
;
;	Get T.
	if do_tmat then begin
        	t_mat = get_t(0, float(s_vtt(0)), float(s_vtt(1)), $
			float(s_vtt(2)), tmat)
	endif else begin
        	t_mat = get_t(ttype, float(s_vtt(0)), float(s_vtt(1)), $
			float(s_vtt(2)))
	endelse
;
; -------------------
;
;	Do matrix multiplication.
;
;     Theory:
;
;	S(inst) - measured Stokes vector
;	S(cal)  - calibrated Stokes vector
;
;	S(inst) = X T S(cal)
;
;     Applied below:
;
;	S(cal)  = invert(T) invert(X) S(inst)
;
; -------------------
;
;	Apply X matrix for each position along slit.
	if do_verb then print, '>>>>>>> applying X matrices ...'
	for y = 0, ny1 do begin

		ii(*,y) = xmats_all(y,0,0) * i(*,y) + $
			  xmats_all(y,0,1) * q(*,y) + $
			  xmats_all(y,0,2) * u(*,y) + $
			  xmats_all(y,0,3) * v(*,y)

		qq(*,y) = xmats_all(y,1,0) * i(*,y) + $
			  xmats_all(y,1,1) * q(*,y) + $
			  xmats_all(y,1,2) * u(*,y) + $
			  xmats_all(y,1,3) * v(*,y)

		uu(*,y) = xmats_all(y,2,0) * i(*,y) + $
			  xmats_all(y,2,1) * q(*,y) + $
			  xmats_all(y,2,2) * u(*,y) + $
			  xmats_all(y,2,3) * v(*,y)

		vv(*,y) = xmats_all(y,3,0) * i(*,y) + $
			  xmats_all(y,3,1) * q(*,y) + $
			  xmats_all(y,3,2) * u(*,y) + $
			  xmats_all(y,3,3) * v(*,y)
	endfor
;
;	Apply T matrix.
	if do_verb then print, '>>>>>>> applying T matrix ...'
	t_mat = invert(t_mat)
	i = t_mat(0,0)*ii + t_mat(0,1)*qq + t_mat(0,2)*uu + t_mat(0,3)*vv
	q = t_mat(1,0)*ii + t_mat(1,1)*qq + t_mat(1,2)*uu + t_mat(1,3)*vv
	u = t_mat(2,0)*ii + t_mat(2,1)*qq + t_mat(2,2)*uu + t_mat(2,3)*vv
	v = t_mat(3,0)*ii + t_mat(3,1)*qq + t_mat(3,2)*uu + t_mat(3,3)*vv
;
;	Calculate slope for skew (optional) if first scan to process.
	if (iscan eq fscan) and (do_skew) then begin
		slope_use = sslope
		if do_hair then begin
			if do_verb then print, $
				'>>>>>>> get slope of hairline(s) (hair) ...'
			hair, i, yh1, yh2, yh3, yh4, slope_use, ixst, $
				verb=do_verb, onehair=onehair
		endif
		if do_verb then begin
			print
			print, 'Slope for "skew.pro" is:  ' + $
				stringit(slope_use)
			print
		endif
	endif
;
;	Optionally remove the skewness of the spectral images.
	if do_skew then begin
		if do_verb then print, '>>>>>>> remove skewness (skew) ...'
		i = skew(i, slope_use)
		q = skew(q, slope_use)
		u = skew(u, slope_use)
		v = skew(v, slope_use)
	endif
;
;	Remove residual I -> Q,U,V crosstalk.
	if do_verb then print, '>>>>>>> remove I crosstalk (icross) ...'
	icross, i, q, u, v, xc1, xc2
;
;	Write output scan.
	if do_verb then print, '>>>>>>> write scan (writ_sc_data) ...'
	if writ_sc_data(out_unit, i, q, u, v) eq 1 then $
		return
;
endfor
;
;---------------------------------------------
;
;	Close files and free unit numbers.
;
free_lun, in_unit, out_unit
;
;	Optionally print output file name.
;
if do_verb then begin
	print
	print, 'Output to ', outfile, '.'
	print
endif
;
;	Done.
;
end

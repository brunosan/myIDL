pro calib_gain, unit, good, dark, filtd, gain, ixst, $
		x1,x2,y1,y2, cam, ii,qq,uu,vv, verbose=verbose
;+
;
;	procedure:  calib_gain
;
;	purpose:  read scan; optionally bias, RGB, and gain correct,
;		  and flip wavelength order (for calibrate.pro)
;
;	author:  rob@ncar, 10/93
;
;	WARNING - 'ixst' assumes wavelengths have NOT been flipped !!!
;		  (flipping occurs after 'ixst' is used)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 15 then begin
	print
	print, "usage:  calib_gain, unit, good, dark, filtd, gain, ixst, $"
	print, "		    x1,x2,y1,y2, cam, ii,qq,uu,vv"
	print
	print, "	Read scan; optionally bias, RGB, and gain correct,"
	print, "	and flip wavelength order (for calibrate.pro)."
	print
	print, "	Arguments"
	print, "	    unit	- input file unit number"
	print, "	    good	- input boolean flag;"
	print, "			  1=good scan, 0=bad scan"
	print, "	    dark	- input dark image"
	print, "	    filtd	- input filtd array"
	print, "	    gain	- input gain table"
	print, "	    ixst	- index of first active X"
	print, "	    x1 - y2	- input start,end col,row indices"
	print, "	    cam		- input camera identifier (string)"
	print, "	    ii - vv	- output spectral images"
	print, "			  (blank if bad scan)"
	print
	print, "	Keywords"
	print, "	    verbose	- if set, print run-time info"
	print, "			  (def=don't print)"
	print
	return
endif
;-
;
;	Specify I,Q,U,V common block.
;
@iquv.com
;
;	Set general variables.
;
do_verb = keyword_set(verbose)
;
;       Read scan data.
;
if do_verb then print, cam, $
	format='(/ ">>>>>>> read scan data camera ", A, " (read_sc_data) ...")'
if read_sc_data(unit) eq 1 then stop
;
;	------------------------
;	 PROCESS IF A GOOD SCAN
;	------------------------
;
if good then begin
;
;       Chop out middle to use.
	ii_temp = i(x1:x2, y1:y2)
	qq_temp = q(x1:x2, y1:y2)
	uu_temp = u(x1:x2, y1:y2)
	vv_temp = v(x1:x2, y1:y2)
;
;	Remove dark.
	if do_verb then print, '>>>>>>> bias-correct (subtraction) ...'
	ii_temp = ii_temp - dark
;
;	Correct for RGB variations.
	if do_verb then print, '>>>>>>> RGB-correct (ofstc3) ...'
	ofstc3, ii_temp, qq_temp, uu_temp, vv_temp
;
;	Gain-correct clear port (results in 'out').
	if do_verb then print, '>>>>>>> gain-correct (gncorr) ...'
	if gncorr(ii_temp, gain, out, ixst) then stop, "Fatal 'gncorr' error."
;
;	Calculate output I.
	ii = ii_temp
	ii(ixst:*,*) = out(ixst:*,*) * filtd(ixst:*,*)
;
;	Calculate grand multiplicative array.
	gnarr = ii
	gnarr(*,*) = 1.0
	gnarr(ixst:*,*) = ii(ixst:*,*) / (ii_temp(ixst:*,*) > 1.0)
;
;	Multiply the G.M.A. by Q, U, and V.
	qq = qq_temp(*,*) * gnarr(*,*)
	uu = uu_temp(*,*) * gnarr(*,*)
	vv = vv_temp(*,*) * gnarr(*,*)
;
;	Flip the wavelengths left to right.
	if do_verb then print, '>>>>>>> flipping wavelength order (flipx) ...'
	flipx, ii
	flipx, qq
	flipx, uu
	flipx, vv
;
endif else begin
;
;	Return empty arrays since a 'bad' scan.
	ii = fltarr(x2-x1+1, y2-y1+1)
	qq = ii
	uu = ii
	vv = ii
;
endelse
;
;	Done.
;
end

pro gain_xt, infile, outfile, xold, xnew, knew, xc1, xc2, $
	ttold, ttnew, told=told, tnew=tnew, v101=v101
;+
;
;	procedure:  gain_xt
;
;	purpose:  recalibrate by removing old X,T and applying new X,T
;
;	author:  rob@ncar, 10/92
;
;	notes:  - see WARNING below
;
;	notes:  - THIS PROCEDURE HAS BEEN MADE OBSOLETE BY CALIBRATE.PRO
;
; ex1: gain_xt, '48.gainit.ex0', '48.gainit.test', 'X.29', 'X.29',
;	'48new.k.save', 80, 100, 3, 3
;
; ex2: gain_xt, '48.gainit.ex0', '48.gainit.test', 'X.29', 'X.48p',
;	'48new.k.save', 80, 100, 3, 0, tnew='T.24'
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 9 then begin
usage:
	print
	print, "usage:  gain_xt, infile, outfile, xold, xnew, knew, $"
	print, "		xc1, xc2, ttold, ttnew"
	print
	print, "	Recalibrate by removing old X,T and applying new X,T."
	print
	print, "	Arguments"
	print, "	    infile	- name of file to recalibrate"
	print, "	    outfile	- name of output file"
	print, "	    xold, xnew	- names of old and new X files"
	print, "	    knew	- name of output k file"
	print, "	    xc1, xc2	- wavelength range for continuum"
	print, "		          as set in gainit.pro"
	print, "	    ttold,ttnew	- types of old and new T matrices"
	print, "		          (see get_t.pro for choices)"
	print
	print, "	Keywords"
	print, "	    told	- name of old T parameter file"
	print, "		          (for ttold of 0)"
	print, "	    tnew	- name of new T parameter file"
	print, "		          (for ttnew of 0)"
	print, "	    v101	- set to force version 101"
	print, "		          (def=use version # in op hdr)"
	print
	print, "   ex:  gain_xt, '48.gainit.map', '48.gainit.new', $"
	print, "	'X.29', 'X.48', '48new.k.save', $"
	print, "	80, 100, 3, 0, tnew='T.48'"
	print
	return
endif
;-
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
;
;	Read old X matrix.
;
openr, unit, xold, /get_lun
x_old = fltarr(4, 4, /nozero)
readf, unit, x_old
free_lun, unit
x_old = transpose(x_old)
;
;	Read new X matrix.
;
openr, unit, xnew, /get_lun
x_new = x_old
readf, unit, x_new
free_lun, unit
x_new = transpose(x_new)
;
;	Calculate part of new master matrix to apply.
;
x_temp = invert(x_new) # x_old
MAT = x_temp
;
;	Set old T parameters.
;
if ttold eq 0 then begin
	if n_elements(told) eq 0 then begin
		print
		print, 'ttold/told error ...'
		goto, usage
	endif
	do_told = true
endif else begin
	if n_elements(told) ne 0 then begin
		print
		print, 'ttold/told error ...'
		goto, usage
	endif
	do_told = false
endelse
;
;	Set new T parameters.
;
if ttnew eq 0 then begin
	if n_elements(tnew) eq 0 then begin
		print
		print, 'ttnew/tnew error ...'
		goto, usage
	endif
	do_tnew = true
endif else begin
	if n_elements(tnew) ne 0 then begin
		print
		print, 'ttnew/tnew error ...'
		goto, usage
	endif
	do_tnew = false
endelse
;
;       Open, read, and possibly list input file.
;
openr, in_unit, infile, /get_lun
if read_op_hdr(in_unit, stdout_unit, true) eq 1 then return
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
nscan = get_nscan()
;
;	Set up to output k values (dnumy from op header).
;
ksi = fltarr(nscan, dnumy, /nozero)
ksq = ksi
ksu = ksi
ksv = ksi
ksiii = fltarr(dnumy, /nozero)
ksqqq = ksiii
ksuuu = ksiii
ksvvv = ksiii
ksi_new = fltarr(nscan, dnumy, /nozero)
ksq_new = ksi_new
ksu_new = ksi_new
ksv_new = ksi_new
;
;	Jump to location of first scan to view.
;
skip_scan, in_unit, fscan=0
;
;	Open output file.
;
openw, out_unit, outfile, /get_lun
;
;       Write out operation header.
;
put_optype, 'GainXT'				; change operation type
if writ_op_hdr(out_unit) eq 1 then return
;
;---------------------------------------------
;
;	LOOP FOR EACH SCAN.
;
for iscan = 0, nscan - 1 do begin
;
;	Read scan header.
	if read_sc_hdr(in_unit, stdout_unit, false, $
		version=version) eq 1 then return
;
;	Write scan header.
        if writ_sc_hdr(out_unit, version=version) eq 1 then return
;
;	Print scan number.
	print, '(seq. ' + stringit(iscan) + ')  Scan: ' + stringit(s_snum)
;
;       Read scan data.
        if read_sc_data(in_unit) eq 1 then return
;
;	Get old T.
	if do_told then begin
        	tt_old = get_t(0, float(s_vtt(0)), float(s_vtt(1)), $
			float(s_vtt(2)), told)
	endif else begin
        	tt_old = get_t(ttold, float(s_vtt(0)), float(s_vtt(1)), $
			float(s_vtt(2)))
	endelse
;
;	Get new T.
	if do_tnew then begin
        	tt_new = get_t(0, float(s_vtt(0)), float(s_vtt(1)), $
			float(s_vtt(2)), tnew)
	endif else begin
        	tt_new = get_t(ttnew, float(s_vtt(0)), float(s_vtt(1)), $
			float(s_vtt(2)))
	endelse
;
;	Calculate master matrix.
	MAT = invert(tt_new) # x_temp # tt_old
;
; -------------------
;
;	Do matrix multiplication.
;

;	WARNING:  OLD K IS NO LONGER REMOVED !!!!!!!!!!!!!!!!!!!
;
;

;
;   THE PLAN:
;
;	S(inst) - measured Stokes vector
;	S(cal)  - calibrated Stokes vector
;	S(new)  - new calibrated Stokes vector
;	I       - identity matrix
;	K       - ( 0   0  0  0 )
;		  ( kq  0  0  0 )
;		  ( ku  0  0  0 )
;		  ( kv  0  0  0 )
;     Theory:
;
;	S(inst) = X T invert(I-K) S(cal)		-or-
;	S(cal)  = (I-K) invert(T) invert(X) S(inst)
;
;     Applied in gainit (i.e., aspcal):
;
;	S(cal)  = (I-Kold) invert(Told) invert(Xold) S(inst)
;                 ^^^^^^^^
;		Andy's icross does not apply this
;
;     Applied below:
;
;	S(new)  = (I-Knew) invert(Tnew) invert(Xnew) Xold Told
;			   invert(I-Kold) S(cal)
;                 ^^^^^^^^
;		Andy's icross does not apply this
;
; -------------------
;
	ii = MAT(0,0)*i + MAT(0,1)*q + MAT(0,2)*u + MAT(0,3)*v
	qq = MAT(1,0)*i + MAT(1,1)*q + MAT(1,2)*u + MAT(1,3)*v
	uu = MAT(2,0)*i + MAT(2,1)*q + MAT(2,2)*u + MAT(2,3)*v
	vv = MAT(3,0)*i + MAT(3,1)*q + MAT(3,2)*u + MAT(3,3)*v
;
;	Calculate and apply new k's.
	flipx, ii
	flipx, qq		; flip to raw data wavelength order for icross
	flipx, uu
	flipx, vv
	icross, ii, qq, uu, vv, xc1, xc2, ksiii, ksqqq, ksuuu, ksvvv
	ksi_new(iscan, *) = ksiii
	ksq_new(iscan, *) = ksqqq
	ksu_new(iscan, *) = ksuuu
	ksv_new(iscan, *) = ksvvv
	flipx, ii
	flipx, qq		; flip back to correct/final wavelength order
	flipx, uu
	flipx, vv
;
;	Write output scan.
	if writ_sc_data(out_unit, ii, qq, uu, vv) eq 1 then $
		return
;
endfor
;
;---------------------------------------------
;
;	Save new k's.
;
ksi = ksi_new
ksq = ksq_new
ksu = ksu_new
ksv = ksv_new
save, ksi, ksq, ksu, ksv, file=knew
;
;	Close files and free unit numbers.
;
print
print, 'Output to ', outfile, '.'
print
free_lun, in_unit, out_unit
;
;	Done.
;
end

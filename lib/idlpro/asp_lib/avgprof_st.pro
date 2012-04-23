pro avgprof_st, infile, kfile, ttype, ii, qq, uu, vv, $
	tt, kk, as, ay, nsumy, barray, fscan=fscan, lscan=lscan, v101=v101, $
	x1=x1, x2=x2, y1=y1, y2=y2, xe1=xe1, xe2=xe2, tfile=tfile, $
	thold=thold, title=title, xyfile=xyfile, noplot=noplot, noverb=noverb
;+
;
;	procedure:  avgprof_st
;
;	purpose:  calculate average profile in a spot, St version
;
;	author:  rob@ncar, 9/92
;
;	ex:  avgprof_st,'48.gainit.242','48.k.save.242',3,i,q,u,v,t,k,s,y,n,b,
;		thold=660.0,xe1=200,xe2=250,x1=0,x2=254,y1=50,y2=175,
;		title='48.gainit.242',xyfile='rob.xy'
;
;	ex:  avgprof_st,'48.gainit.242','48.k.save.242',3,
;		ii,qq,uu,vv,tt,kk,ss,yy,nn,bb,
;		title='48.gainit.242',xyfile='rob.xy'
;
;	notes:  1) This procedure is based on avgprof.pro, but outputs
;		   more information for calculating <St>.
;
;		      <St> = <T> * invert(<K>) * <S_calib>
;
;		      <xx> = average xx in spot		[6149 data]
;
;		         T = 4x4 telescope matrix, tt (dim = 4x4)
;		         K = 4x4 k matrix, made from kk (dim = 4)
;		   S_calib = average calibrated Stokes profiles, ii-vv
;
;		2) <St> info will be used in program ttt (see get_st).
;
;	notes for 6149 data:
;
;		- try 6151 line for extremum [defined in xe1,xe2 below]
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 13 then begin
usage:
	print
	print, "usage:  avgprof_st, infile, kfile, ttype, $"
	print, "	  ii, qq, uu, vv, tt, kk, as, ay, nsum, barray"
	print
	print, "	Calculate average prof. in a spot, St version."
	print
	print, "	Arguments"
	print, "		infile	 - input file"
	print, "		kfile	 - k save file from gainit.pro"
	print, "			   containing ksq, ksu, ksv"
	print, "		ttype	 - T matrix type (see get_t.pro)"
	print, "		ii-vv	 - output average I, Q, U, V profiles"
	print, "		tt	 - output average T matrix"
	print, "		kk	 - output average k 4-vector"
	print, "		as	 - output avg. scan (spot center)"
	print, "		ay	 - output avg. Y of 'as' (spot center)"
	print, "		nsum	 - output # of profiles summed"
	print, "		barray	 - output binary image of spot"
	print
	print, "	Keywords"
	print, "		tfile	 - T matrix parameter file"
	print, "			   (set it if ttype is 0)"
	print, "		xyfile	 - file for X,Y's of spot, where"
	print, "			   X = scan, and Y = pixels along slit"
	print, "			   (def = op#.xy; see 'thold')"
	print, "		x1, x2	 - column indices (wavelength) to use"
	print, "			   (defs=0,last)"
	print, "		title	 - window title (def=let IDL choose)"
	print, "		noplot	 - if set, do not plot the profiles"
	print, "		noverb	 - if set, do not print run-time info"
	print, "		v101	 - set to force version 101"
	print, "			   (def=use version # in op hdr)"
	print
	print, "	    Use the following only if setting 'thold':"
	print
	print, "		thold	 - profiles with [(mean of V extrema"
	print, "			   in range xe1 to xe2) > thold] will"
	print, "			   be averaged, and corresponding"
	print, "			   X,Y's will be written to 'xyfile'"
	print, "			   (def=read 'xyfile' of points to"
	print, "			   average)"
	print, "		fscan	 - first seq. scan to check (def=0)"
	print, "		lscan	 - last seq. scan to check (def=last)"
	print, "		y1, y2	 - row range to check (defs=0,last)"
	print, "		xe1	 - starting col. for extremum (def=x1)"
	print, "		xe2	 - ending col. for extremum (def=x2)"
	print
	return
endif
;-
;
;	Get k's from gainit save file.
;
ksq = 0
ksu = 0
ksv = 0
restore, kfile
;
;	Specify common blocks.
;
@op_hdr.com
@scan_hdr.com
@iquv.com
;
;	Set types and sizes of common block variables.
;
@op_hdr.set
@scan_hdr.set
;
;	Set general parameters.
;
true = 1
false = 0
do_verb = true
if keyword_set(noverb) then do_verb = false
stdout_unit = -1
max_yps = 256		; maximum number of Y's per scan in spot
yps = intarr(max_yps)
format1 = '(256(I4, :))'
;
;	Check threshold parameters.
;
if n_elements(thold) eq 0 then begin
	if (n_elements(fscan) ne 0) or (n_elements(lscan) ne 0) or $
	   (n_elements(xe1)   ne 0) or (n_elements(xe2)   ne 0) or $
	   (n_elements(y1)    ne 0) or (n_elements(y2)    ne 0) then begin
		print
		print, 'keyword set that should not be ...'
		goto, usage
	endif
	do_thold = false
endif else begin
	do_thold = true
endelse
;
;	Set T parameters.
;
if ttype eq 0 then begin
	if n_elements(tfile) eq 0 then begin
		print
		print, 'ttype/tfile error ...'
		goto, usage
	endif
	do_tfile = true
endif else begin
	if n_elements(tfile) ne 0 then begin
		print
		print, 'ttype/tfile error ...'
		goto, usage
	endif
	do_tfile = false
endelse
;
;	Set input file.
;
openr, infile_unit, infile, /get_lun
;
;	Read and possibly list operation header.
;
if read_op_hdr(infile_unit, stdout_unit, do_verb) eq 1 then return
;
;	Set I,Q,U,V arrays.
;	(uses dnumx and dnumy from op header common block)
;
set_iquv
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Set X and Y ranges (dnumx and dnumy is in op header common block).
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
nx = x2 - x1 + 1
ny = y2 - y1 + 1
ny1 = y2 - y1
if (x1 gt x2) or (y1 gt y2) or $
   (x1 lt 0) or (y1 lt 0) or $
   (x2 gt dnumx-1) or (y2 gt dnumy-1) then begin
	print
	print, 'Error specifying x1,x2 and/or y1,y2.'
	print
	return
endif
;
;	Set extremum range.
;
if n_elements(xe1) eq 0 then xe1 = x1
if n_elements(xe2) eq 0 then xe2 = x2
if (xe1 gt xe2) or (xe1 lt x1) or (xe2 gt x2) then begin
	print
	print, 'Error specifying xe1,xe2.'
	print
	return
endif
xxe1 = xe1 - x1
xxe2 = xe2 - x1
;
;	Set XY file.
;
if n_elements(xyfile) eq 0 then xyfile = stringit(opnum) + '.xy'
;
if do_thold then begin				; XY output
	openw, xyfile_unit, xyfile, /get_lun

endif else begin				; XY input
	openr, xyfile_unit, xyfile, /get_lun
	str = ''
	readf, xyfile_unit, str			; (read 1st line)
	line = str2int(str, num_line)		; (num_line = scan + #Y's)
	fscan = line(0)
	scan_read_xy = fscan			; (scan read from XY file)
endelse
;
;	Set scan parameters (get_nscan uses op header common block).
;
nscan_avail = get_nscan()
if n_elements(fscan) eq 0 then fscan = 0
if n_elements(lscan) eq 0 then lscan = nscan_avail - 1
nscan = lscan - fscan + 1
;
if (fscan lt 0) or (nscan lt 1) or (lscan gt nscan_avail-1) then begin
	print
	print, 'Error in specifying fscan, lscan;
	print, stringit(nscan_avail) + ' scans available.'
	print
	return
endif
;
;	Set more parameters.
;
barray = bytarr(nscan_avail, dnumy)
avgy = fltarr(nscan)
isum = dblarr(nx)		; zero profiles
qsum = isum
usum = isum
vsum = isum
tsum = fltarr(4, 4)		; zero T matrix sum
ksum = fltarr(4)		; zero k vector sum
nsumy = 0			; zero total number of profiles summed
avgscan = 0L			; the scan of spot center
seq_scan = -1
if do_verb then print
;
;	Jump to location of first scan to view.
;
skip_scan, infile_unit, fscan=fscan
;
;--------------------------------------------------
;
;	LOOP FOR EACH SCAN IN SPOT.
;
for iscan = fscan, lscan do begin
;
;	Increment sequential scan number.
	seq_scan = seq_scan + 1
;
;	Read scan header.
	if read_sc_hdr(infile_unit, stdout_unit, false, $
		version=version) eq 1 then return
;
;	Read scan data.
	if read_sc_data(infile_unit) eq 1 then return
;
;	Chop out middle to use.
	ii = i(x1:x2, y1:y2)
	qq = q(x1:x2, y1:y2)
	uu = u(x1:x2, y1:y2)
	vv = v(x1:x2, y1:y2)
;
;	Initialize counter of summed profiles.
	nsy = 0
;
;	>>>>>>>>>>>>>>>>>>>>>>
;	>>> Sum in profile ...
;	>>>>>>>>>>>>>>>>>>>>>>
;
;	... if mean of V extrema is greater than threshold (for do_thold=true)
;
	if do_thold then begin
;
	    for y = 0, ny1 do begin
		minv = min( vv(xxe1:xxe2,y) , max=maxv)
		meanv = 0.5 * (abs(minv) + abs(maxv))

		if meanv gt thold then begin
;
;			Calculate actual Y.
			y_act = y + y1
;
;			Fill binary image of spot.
			barray(iscan, y_act) = 1B
;
;			Save Y's of spot for this scan.
			yps(nsy) = y_act
;
;			Sum Y's for calculating average Y.
			avgy(seq_scan) = avgy(seq_scan) + y_act
;
;			Sum profiles for calculating average profile.
			isum = isum + ii(*, y)
			qsum = qsum + qq(*, y)
			usum = usum + uu(*, y)
			vsum = vsum + vv(*, y)
;
;			Sum in k's.
			ksum(0) = ksum(0) + ksi(iscan, y_act)
			ksum(1) = ksum(1) + ksq(iscan, y_act)
			ksum(2) = ksum(2) + ksu(iscan, y_act)
			ksum(3) = ksum(3) + ksv(iscan, y_act)
;
;			Increment number of Y's summed.
			nsy = nsy + 1
		endif
	    endfor
;
;	... if xyfile says the point is in the spot (for do_thold=false)
;
	endif else begin
;
;		Read next line from XY file if necessary.
		if eof(xyfile_unit) then goto, continue
		if iscan gt scan_read_xy then begin
			readf, xyfile_unit, str
			line = str2int(str, num_line)
			scan_read_xy = line(0)
		endif
;
;		Process the scan if it's in the spot according to the XY file.
		if iscan eq scan_read_xy then begin
			nsy = num_line - 1		; # Y's to sum
;
			for i = 1, nsy do begin
;
;				Grab actual Y.
				y_act = line(i)
;
;				Fill binary image of spot.
				barray(iscan, y_act) = 1B
;
;				Set relative Y.
				y = y_act - y1
;
;				Sum Y's for calculating average Y.
				avgy(seq_scan) = avgy(seq_scan) + y_act
;
;				Sum profiles for calculating average profile.
				isum = isum + ii(*, y)
				qsum = qsum + qq(*, y)
				usum = usum + uu(*, y)
				vsum = vsum + vv(*, y)
;
;				Sum in k's.
				ksum(0) = ksum(0) + ksi(iscan, y_act)
				ksum(1) = ksum(1) + ksq(iscan, y_act)
				ksum(2) = ksum(2) + ksu(iscan, y_act)
				ksum(3) = ksum(3) + ksv(iscan, y_act)
			endfor
;
		endif
	endelse
;
;	Increment T, k, and avgscan sums.
;	(Note same T and k used for every profile of a scan.)
	if nsy gt 0 then begin
		if do_tfile then begin
			tsum = tsum + nsy * get_t(0, $
				float(s_vtt(0)), float(s_vtt(1)), $
				float(s_vtt(2)), tfile)
		endif else begin
			tsum = tsum + nsy * get_t(ttype, $
				float(s_vtt(0)), float(s_vtt(1)), $
				float(s_vtt(2)))
		endelse
		avgscan = avgscan + nsy * s_snum
;
;		Calculate average Y of the scan.
		avgy(seq_scan) = avgy(seq_scan) / nsy
;
;		Output scan and Y's of spot to file.
		if do_thold then $
			printf, xyfile_unit, s_snum, yps(0:nsy-1), $
				format=format1
	endif
;
;	Increment grand sum and print scan status.
	nsumy = nsumy + nsy
	if do_verb then print, 'Scan ' + stringit(s_snum) + $
		 ':  ' + stringit(nsy) + ' summed'
;
endfor
;--------------------------------------------------
;
continue:
;
;	Close files and free unit numbers.
;
free_lun, infile_unit, xyfile_unit
;
;	Check number of profiles averaged.
;
if nsumy eq 0 then begin
	print
	print, '	No profiles found above threshold.'
	print
	return
endif
;
;	Divide sums to get averages.
;
fnum = float(nsumy)
ii = isum / fnum
qq = qsum / fnum
uu = usum / fnum
vv = vsum / fnum
tt = tsum / fnum
kk = ksum / fnum
as = fix(avgscan/fnum + 0.5)
ay = fix(avgy(as - fscan) + 0.5)
;
;	Print status information.
;
print, '      Number of profiles summed:  ' + stringit(nsumy)
print, '      Center of spot is scan, Y:  ' + stringit(as) + ', ' + $
	stringit(ay)
;;if do_thold then print, 'Output file of spot (scan, Y)''s:  ' + xyfile
;
;	Plot profiles.
;
if not keyword_set(noplot) then begin
;
;	Open a window.
	if keyword_set(title) then begin
		window, /free, title=title
	endif else begin
		window, /free
	endelse
;
;	Plot profiles.
	!p.multi = [0, 2, 2, 0, 0]		; set to 2x2 plots
	plot, ii, title='Average I'
	plot, qq, title='Average Q'
	plot, uu, title='Average U'
	plot, vv, title='Average V'
	!p.multi = 0				; reset to one plot per page
endif
;
;	Done.
;
end

pro get_st, ttype, bspot, olist, cal_suf, k_suf, xy_suf, $
	x1=x1, x2=x2, y1=y1, y2=y2, xx1=xx1, xx2=xx2, xe1=xe1, xe2=xe2, $
	yr1=yr1, yr2=yr2, yr3=yr3, yr4=yr4, outp=outp, outn=outn, $
	wr1=wr1, wr2=wr2, wr3=wr3, wr4=wr4, $
	k_sufps=k_sufps, a_sufps=a_sufps, b_sufps=b_sufps, $
	tfile=tfile, v101=v101, fscan=fscan, lscan=lscan, $
	verbose=verbose, vfile=vfile, tfact=tfact, thold=thold
;+
;
;	procedure:  get_st
;
;	purpose:  calculate St info for use in 'ttt'
;
;	author:  rob@ncar, 9/92
;
;	notes:	1) run gainit before running get_st
;
;		2) remember that fscan/lscan parameters are "sequential scan"
;		   numbers of the file in question (important if scans were
;		   eliminated during gainit, for example)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 6 then begin
usage:
	print
	print, "usage:  get_st, ttype, bspot, olist, cal_suf, k_suf, xy_suf"
	print
	print, "	Calculate St info for use in 'ttt'."
	print
	print, "	Arguments"
	print, "	    ttype	- T matrix type (see get_t.pro)"
	print, "	    bspot	- output binary image of spot"
	print, "		          (e.g., display it with tvwin)"
	print, "	    olist	- array of operation numbers to use"
	print, "	    cal_suf	- suffix of input calibrated maps"
	print, "	    k_suf	- suffix of input K save files"
	print, "	    xy_suf	- suffix of input XY files"
	print
	print, "	Keywords"
	print, "	    x1, x2	- column indices (wavelength) to use"
	print, "		          in avgprof_st (defs=0,last)"
	print, "	    y1, y2	- row indices to use"
	print, "		          in avgprof_st (defs=85,155)"
	print, "	    xx1, xx2	- wavelength range for 6149 V"
	print, "		          (defs=30,70)"
	print, "	    xe1, xe2	- column range for V extremum"
	print, "		          in avgprof_st (defs=210,235)"
	print, "	    outp, outn	- output file names of neg. and pos."
	print, "	     	          extrema (defs="614[+|-]v.st")"
	print, "	    fscan,lscan	- scan range to consider"
	print, "	     	          (defs=first to last)"
	print, "	    tfile	- T matrix parameter file"
	print, "		          (set this if ttype is 0)"
	print, "	    tfact	- factor used in generating thold"
	print, "		          via 'thold = tfact * meanV'"
	print, "		          where meanV is calculated by"
	print, "		          aspmeanv.pro (default tfact=0.3)"
	print, "	    thold	- threshold to use in avgprof_st.pro"
	print, "		          (def=use tfact to generate thold)"
	print, "	    v101	- set to force version 101 --"
	print, "		          used in call to avgprof_st.pro"
	print, "		          (def=use version # in op hdr)"
	print
	print, "	    verbose	- if set, print much run-time"
	print, "		          info to 'vfile' and make plots"
	print, "	    vfile	- file for 'verbose' prints"
	print, "		          (def='get_st.verb')"
	print, "	    yr1 to yr4	- y ranges for Ki, Kq, Ku, Kv plot"
	print, "	     	          (defs=[0.,3.e4],[-.006,.006],"
	print, "		           yr2,[-.006,.006])"
	print, "	    wr1 to wr4	- y ranges for 6149 I,Q,U,V plot"
	print, "	      	          (defs=[0,20000],[-40,40],"
	print, "		           [-40,40],[-600,600])"
	print, "	    k_sufps	- suffix of K PostScript plot"
	print, "		          (def='.k.ps')"
	print, "	    a_sufps	- suffix of 1st avg prof PS plot"
	print, "		          (def='.avg.ps')"
	print, "	    b_sufps	- suffix of 2nd avg prof PS plot"
	print, "		          (def='.avg2.ps')"
	print
	print
	print, "   ex:  get_st, 3, bspot, [48,49], '.gainit', $"
	print, "		'.k.save', '.xy', /verb"
	print
	return
endif
;-

;
;	Set operations to process.
;
nops = n_elements(olist)
nops1 = nops - 1
;
;	Set general parameters.
;
true = 1
false = 0
do_verbose = false
if keyword_set(verbose) then do_verbose = true
if n_elements(vfile) eq 0 then vfile = 'get_st.verb'
if n_elements(thold) gt 0 then begin
	use_thold = true
endif else begin
	use_thold = false
	if n_elements(tfact) eq 0 then tfact = 0.215
endelse
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
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
;	Set output files.
;
; negative extremum for entrance V
if n_elements(outn) eq 0 then outn = '614-v.st'
;
; positive extremum for entrance V
if n_elements(outp) eq 0 then outp = '614+v.st'
;
openw, outn_unit, outn, /get_lun
openw, outp_unit, outp, /get_lun
if do_verbose then $
	openw, verb_unit, vfile, /get_lun	; "verbose" output file
;
;	Specify common blocks.
;
@op_hdr.com
@scan_hdr.com
;
;	Set print formats.
;
format1 = '(I4, 4F10.3, I10)'
format2 = '(4F10.5)'
format3 = '(I19, 4F13.5)'
format4 = '(4F11.5)'
format5  = '(I4,4F10.5)'
;THIS FORMAT TO BE USED FOR RAW DATA
format6  = '(4F10.3)'
format7  = '(F10.3,3F10.5)'
;
;	Set other parameters.
;
iconfig = 1000
dashes = '-----------------------------------------------'

;-----------------------------------------------------
;	DO THE FOLLOWING FOR EACH MAP
;-----------------------------------------------------

for iop = 0, nops1 do begin

;
;	Set file names.
;
op_num = olist(iop)
sopnum = stringit(op_num)			; string of op number
calibfile = sopnum + cal_suf
kfile = sopnum + k_suf
xyfile = sopnum + xy_suf
;
;	Print status header.
;
print, dashes
print, 'MAP:  ' + calibfile
if do_verbose then begin
	printf, verb_unit, dashes
	printf, verb_unit, 'MAP:  ' + calibfile
	printf, verb_unit
endif

;
;	Run gainit (see the procedure).
;
;	[DONE ALREADY]
;
;;gainit, mapfile,	..., outfile=calibfile, xfile=xfile

;
;	Get first and last sequential scans to process.
;
readscan, calibfile, 0, i, q, u, v, /nohead
nscan = get_nscan()
if n_elements(fscan) eq 0 then fscan_use = 0 $
	else fscan_use = fscan
if n_elements(lscan) eq 0 then lscan_use = nscan - 1 $
	else lscan_use = lscan
;
;	Set ranges to be used in calculating average profiles.
;
if n_elements(x1) eq 0 then x1_use = 0 $
	else x1_use = x1
if n_elements(x2) eq 0 then x2_use = sizeof(i, 1) - 1 $
	else x2_use = x2
if n_elements(y1) eq 0 then y1_use = 85 $
	else y1_use = y1
if n_elements(y2) eq 0 then y2_use = 155 $
	else y2_use = y2
if n_elements(xe1) eq 0 then xe1_use = 210 $
	else xe1_use = xe1
if n_elements(xe2) eq 0 then xe2_use = 235 $
	else xe2_use = xe2
;
;	Get threshold to be used in calculating average profiles.
;
;if not use_thold then begin
;	meanv = aspmeanv(calibfile, $
;		x1=x1_use, x2=x2_use, y1=y1_use, y2=y2_use, $
;		fscan=fscan_use, lscan=lscan_use, v101=do_v101, verbose=false)
;	thold = tfact * meanv
;	print, '                           Vmax:  ' + stringit(meanv)
;endif
;print, '                      Threshold:  ' + stringit(thold)
;
;	Get average profiles and other info used in calculating <St>.
;
;  NOTE;TO USE XY-MAP DROP THOLD=THOLD & subsequent FROM LIST
;
if do_tfile then begin
	avgprof_st, calibfile, kfile, 0,  $
		is, qs, us, vs, tt, kk, as, ay, nsum, bspot, v101=do_v101, $
		title=calibfile, /noplot, /noverb, tfile=tfile,xyfile=xyfile, $
		x1=x1_use, x2=x2_use ;  $
		;,thold=thold, y1=y1_use, y2=y2_use, $
		;,xe1=xe1_use, xe2=xe2_use, $
		;fscan=fscan_use, lscan=lscan_use
endif else begin
	avgprof_st, calibfile, kfile, ttype, $
		is, qs, us, vs, tt, kk, as, ay, nsum, bspot, v101=do_v101, $
		title=calibfile, /noplot, /noverb,xyfile=xyfile, $
		x1=x1_use, x2=x2_use ; $
		;,thold=thold, y1=y1_use, y2=y2_use, $
		;xe1=xe1_use, xe2=xe2_use, $
		;fscan=fscan_use, lscan=lscan_use
endelse
;
;	Get geometry of center scan of spot.
;
readscan, calibfile, as, i, q, u, v, /nohead
vttaz = float(s_vtt(0))
vttel = float(s_vtt(1))
tblpos = float(s_vtt(2))
print, ' Spot center elev, azim, tblpos:  ' + $
	float_str(vttel, 3) + ', ' + float_str(vttaz, 3) + ', ' + $
	float_str(tblpos, 3)
;
;       Get mean continuum value
isc   = mean(is(140:180))
;
;if not use_thold then begin
;	nn = nsum * meanv / isc
;	print, '       Numberprof * Vmax / isc:  ' + float_str(nn, 1)
;endif
;
;       Get negative extremum of V at 6149 line and corresponding
;       values of I, Q, and U for Sapp (=(1-K)(xt)^-1*Ppol where Ppol
;       is POLARIMETER RESPONSE 4-params)
if n_elements(xx1) eq 0 then xx1_use = 30 $
	else xx1_use = xx1
if n_elements(xx2) eq 0 then xx2_use = 70 $
	else xx2_use = xx2
vmin = min(vs(xx1_use:xx2_use), ixmin)
ixmin = ixmin + xx1_use
vsmin = mean(vs(ixmin-1:ixmin+1))
ismin = mean(is(ixmin-1:ixmin+1))
qsmin = mean(qs(ixmin-1:ixmin+1))
usmin = mean(us(ixmin-1:ixmin+1))
;
;       Get positive extremum of V at 6149 line and corresponding
;       values of I, Q, and U for Sapp( =(1-K)(xt)^-1*p ) where
;       p=polarimeter 4-response
vmax = max(vs(xx1_use:xx2_use), ixmax)
ixmax = ixmax + xx1_use
vsmax = mean(vs(ixmax-1:ixmax+1))
ismax = mean(is(ixmax-1:ixmax+1))
qsmax = mean(qs(ixmax-1:ixmax+1))
usmax = mean(us(ixmax-1:ixmax+1))
;
;
;	Output verbose info, including K and average profile plots.
;
if do_verbose then begin
;
;	Set names of plot files.
	if n_elements(k_sufps) eq 0 then k_sufps_use = '.k.ps' $
		else k_sufps_use = k_sufps
	if n_elements(a_sufps) eq 0 then a_sufps_use = '.avg.ps' $
		else a_sufps_use = a_sufps
	if n_elements(b_sufps) eq 0 then b_sufps_use = '.avg2.ps' $
		else b_sufps_use = b_sufps
	fileps1 = sopnum + k_sufps_use
	fileps2 = sopnum + a_sufps_use
	fileps3 = sopnum + b_sufps_use
;
;	Print spot info.
	s = ', '
;	if use_thold then begin
;		printf, verb_unit, ' Threshold used = ' + stringit(thold)
;	endif else begin
;		printf, verb_unit, ' Trshold  = ' + stringit(thold) + $
;			'  (tfact = ' + stringit(tfact) + ', Vmax = ' + $
;			stringit(meanv) + ')'
;	endelse
; 	printf, verb_unit, ' Num of profs summed = ' + stringit(nsum)+ $
;	     ',' + '  Numprof * Vmax / Ic =   ' + float_str(nn, 1)
;
;	printf, verb_unit, ' Center of spot is scan, Y = ' + $
;		stringit(as) + ', ' + stringit(ay)
;	printf, verb_unit, ' Output file of spot (scan, Y)''s = ' + xyfile
;	printf, verb_unit, ' Plot files = ' + fileps1 + s + fileps2 + s + $
;		fileps3
;	printf, verb_unit, ' Spot center elev, azim, tblpos = ' + $
;		float_str(vttel, 3) + s + float_str(vttaz, 3) + s + $
;		float_str(tblpos, 3)
	printf, verb_unit, 'S(614)- Max/Min = '
	printf, verb_unit, ixmax, ismax, qsmax, usmax, vsmax,$
				      format=format1
	printf, verb_unit, ixmin, ismin, qsmin, usmin, vsmin,$
				      format=format1
;
;  Calculate & printf normalized S-vector for QUALITY test of XT solution
        qsmin = qsmin / ismin
        usmin = usmin / ismin
        vsmin = vsmin / ismin
        qsmax = qsmax / ismax
        usmax = usmax / ismax
        vsmax = vsmax / ismax
        ismin = 1.0
        ismax = 1.0
	printf, verb_unit, ixmax, ismax, qsmax, usmax, vsmax,$
				      format=format5
	printf, verb_unit, ixmin, ismin, qsmin, usmin, vsmin,$
				      format=format5
;
;	Restore K file.
	ksi=0	&	ksq=0     & ksu=0     & ksv = 0
	restore, kfile
	ksi_m = fltarr(nscan, /nozero)
	ksq_m = ksi_m
	ksu_m = ksi_m
	ksv_m = ksi_m
;
;	Calculate a mean k for each scan by averaging over Y.
	ay1 = ay - 5
	ay2 = ay + 5
	for jscan = 0, nscan-1 do begin
		ksi_m(jscan) = mean(ksi(jscan, ay1:ay2))
		ksq_m(jscan) = mean(ksq(jscan, ay1:ay2))
		ksu_m(jscan) = mean(ksu(jscan, ay1:ay2))
		ksv_m(jscan) = mean(ksv(jscan, ay1:ay2))
	endfor
;
;	Plot K(q), K(u), and K(v).
	t1 = 'Ki'
	t2 = 'Kq'
	t3 = 'Ku'
	t4 = 'Kv'
	title = 'Mean K ' + s +strdate() + s + $
		'Op ' + sopnum + s + strcam()+ s +'X&Tit4'
	if n_elements(yr1) eq 0 then yr1_use = [0.0, 2.0e5] $
		else yr1_use = yr1
	if n_elements(yr2) eq 0 then yr2_use = [-.006, .006] $
		else yr2_use = yr2
	if n_elements(yr3) eq 0 then yr3_use = yr2_use $
		else yr3_use = yr3
	if n_elements(yr4) eq 0 then yr4_use = [-.006, .006] $
		else yr4_use = yr4
	plot_m4, ksi_m, ksq_m, ksu_m, ksv_m, $
		t1=t1, t2=t2, t3=t3, t4=t4, $
		yr1=yr1_use, yr2=yr2_use, yr3=yr3_use, yr4=yr4_use, $
		title=title, fileps=fileps1, /ps,/noverb
;
;	Plot average profiles.
 	title = 'Avg s(614-5) ' + s +  strdate() + s +  $
 		'Op ' + sopnum + s + strcam()+ s +'X&Tit4'
 	plot_m4, is, qs, us, vs, t1='I', t2='Q', t3='U', t4='V', $
 		title=title, fileps=fileps2, /ps,/noverb
;
; 	Plot 6149 region of average profiles.
 	title = 'Avg s(6149) ' + s + strdate() + s + $
 		'Op ' + sopnum + s + strcam()+ s +'X&Tit4'
 	if n_elements(wr1) eq 0 then wr1_use = [0,20000] $
 		else wr1_use = wr1
 	if n_elements(wr2) eq 0 then wr2_use = [-20,20] $
 		else wr2_use = wr2
 	if n_elements(wr3) eq 0 then wr3_use = [-20,20] $
 		else wr3_use = wr3
 	if n_elements(wr4) eq 0 then wr4_use = [-600,600] $
 		else wr4_use = wr4
 	plot_m4, title=title, fileps=fileps3, /ps,/noverb, $
 		is(20:80), t1='I', yr1=wr1_use, $
 		qs(20:80), t2='Q', yr2=wr2_use, $
 		us(20:80), t3='U', yr3=wr3_use, $
 		vs(20:80), t4='V', yr4=wr4_use
endif
;
;	Calculate average St.
;
;      <St> = <T> * invert(<K>) * <S_calib>
;
;	Note:  Since the K's are small, and (1-K)^(-1) = (1 + K)
;	       to first order, we will not have to invert K.
;

;;K = [ [1.0, kk(1), kk(2), kk(3)], $	; transpose of K for IDL
;;      [0.0, 1.0,   0.0,   0.0  ], $
;;      [0.0, 0.0,   1.0,   0.0  ], $
;;      [0.0, 0.0,   0.0,   1.0  ] ]
K = get_imat(4)

;
iiii = K(0,0)*is + K(0,1)*qs + K(0,2)*us + K(0,3)*vs
qqqq = K(1,0)*is + K(1,1)*qs + K(1,2)*us + K(1,3)*vs
uuuu = K(2,0)*is + K(2,1)*qs + K(2,2)*us + K(2,3)*vs
vvvv = K(3,0)*is + K(3,1)*qs + K(3,2)*us + K(3,3)*vs
;
ii = tt(0,0)*iiii + tt(0,1)*qqqq + tt(0,2)*uuuu + tt(0,3)*vvvv
qq = tt(1,0)*iiii + tt(1,1)*qqqq + tt(1,2)*uuuu + tt(1,3)*vvvv
uu = tt(2,0)*iiii + tt(2,1)*qqqq + tt(2,2)*uuuu + tt(2,3)*vvvv
vv = tt(3,0)*iiii + tt(3,1)*qqqq + tt(3,2)*uuuu + tt(3,3)*vvvv
;
;	Get  St @ negative extremum of 6149 line .Use ixmin from S_app
;
vmin = mean(vv(ixmin-1:ixmin+1))
imin = mean(ii(ixmin-1:ixmin+1))
qmin = mean(qq(ixmin-1:ixmin+1))
umin = mean(uu(ixmin-1:ixmin+1))
;
;	Get  St @ positive extremum of 6149 line .Use  ixmax from S_app
;
vmax = mean(vv(ixmax-1:ixmax+1))
imax = mean(ii(ixmax-1:ixmax+1))
qmax = mean(qq(ixmax-1:ixmax+1))
umax = mean(uu(ixmax-1:ixmax+1))
;
;	Print verbose min and max St values.
;
if do_verbose then begin
 	printf, verb_unit, ' St-(0) = ',  imin,' St+(0) = ', imax
endif
;
;	Normalize by the I component.
;       COMMENT OUT THIS NORMALIZATION IF DERIVING  RAW CALIB VECTORS
qmin = qmin / imin
umin = umin / imin
vmin = vmin / imin
qmax = qmax / imax
umax = umax / imax
vmax = vmax / imax
imin = 1.0
imax = 1.0
;
;	Print remaining verbose information.
;
if do_verbose then begin
;	printf, verb_unit, ' St- (norm) ='
;	printf, verb_unit, ixmin, imin, qmin, umin, vmin, format=format3

;	printf, verb_unit, ' St+ (norm) ='
;	printf, verb_unit, ixmax, imax, qmax, umax, vmax, format=format3
	printf, verb_unit, ' K '
 	printf, verb_unit, kk(0),kk(1),kk(2),kk(3),format=format7
endif
;
 	print, ' T ='
 	print, transpose(tt), format=format4
 	print, ' K ='
	print,kk(0),kk(1),kk(2),kk(3), format=format7
;	Write info into files to be read by ttt.
;
printf, outn_unit, iconfig, vttel, vttaz, tblpos, 0.0, nsum, format=format1
printf, outn_unit, imin, qmin, umin, vmin, format=format2
;printf, outn_unit, imin, qmin, umin, vmin, format=format6
printf, outp_unit, iconfig, vttel, vttaz, tblpos, 0.0, nsum, format=format1
printf, outp_unit, imax, qmax, umax, vmax, format=format2
;printf, outp_unit, imax, qmax, umax, vmax, format=format6
;
;
endfor
;-----------------------------------------------------
;
;	Free output units.
;
free_lun, outn_unit, outp_unit
if do_verbose then free_lun, verb_unit
;
;	Done.
;
end


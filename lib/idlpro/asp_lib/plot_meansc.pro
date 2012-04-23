pro plot_meansc, infile, array, $
	         noplot=noplot, v101=v101, noverbose=noverbose, $
		 fact=fact
;+
;
;	procedure:  plot_meansc
;
;	purpose:  Plot and/or return an average value for each scan in
;		  I, Q, U, and V.  Use it for detecting bad scans.
;
;	author:  vmp@ncar + rob@ncar, 7/93
;
;	notes:  - may have to use /v101 option for early Oct/Nov 92 run
;		  if aspedit hasn't been run to fix the version numbers
;
;==============================================================================
;
;	Check number of arguments.
;
if (n_params() lt 1) or (n_params() gt 2) then begin
	print
	print, "usage:  plot_meansc, infile [, array]"
	print
	print, "	Plot and/or return an average value for each scan in"
	print, "	I, Q, U, and V.  Use it for detecting bad scans."
	print
	print, "	Arguments"
	print, "		infile	- input file name"
	print, "		array	- optional output array name"
	print, "			  (floating point)"
	print
	print, "	Keywords"
	print, "		fact	- factor for RMS check (def=3.0)"
	print, "		noplot	- if set, do not plot the value"
	print, "			  (def=plot it)"
	print, "		v101	- set to force version 101"
	print, "			  (def=use version # in op hdr)"
	print, "		noverb	- if set, don't print scan #s"
	print, "			  (def=print them)"
	print
	print
	print, "   ex:  plot_meansc, '02.fa.map', data"
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
@scan_hdr.com
@iquv.com
@op_hdr.set
@scan_hdr.set
;
;	Set general parameters.
;
true = 1
false = 0
stdout_unit = -1
seq_scan = 0
do_ignore = false		; want this for bad data ??
do_verb = true
if keyword_set(noverbose) then do_verb = false


x1 = 15
x2 = 255
y1 = 0
y2 = 228



;
;	Open input unit.
;
openr, in_unit, infile, /get_lun
;
;	Read op header.
;
if read_op_hdr(in_unit, stdout_unit, false) eq 1 then $
	message, 'Error reading op header in "read_op_hdr".'
;
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
;	Get number of scans from op header common.
;
nscan = get_nscan()
;
;	Create floating point output array.
;
array = fltarr(4, nscan)
;
;	Optionally print number of scans.
;
if do_verb then begin
	print
	print, 'Number of scans:  ' + stringit(nscan)
	print
endif
;
;-----------------------------------------
;
;	PROCESS EACH SCAN.
;
for iscan = 0, nscan - 1 do begin

;	Read scan header.
	if read_sc_hdr(in_unit, stdout_unit, false, $
		ignore=do_ignore, version=version) eq 1 then return

;	Print scan number.
	if do_verb then print, 'Scan ' + stringit(s_snum)

;	Read scan data.
        if read_sc_data(in_unit) eq 1 then return

;	Chop out middle to use.
	i = i(x1:x2, y1:y2)
	q = q(x1:x2, y1:y2)
	u = u(x1:x2, y1:y2)
	v = v(x1:x2, y1:y2)

;	Calculate average values.
	array(0, iscan) = mean(i)
	array(1, iscan) = mean(q)
	array(2, iscan) = mean(u)
	array(3, iscan) = mean(v)

endfor
;-----------------------------------------
;
;	Optionally plot values.
;
!p.multi=[0,2,2]
if not keyword_set(noplot) then begin
	title = 'plot_meansc  of  ' + infile
	window, /free, title=title
	xtitle = 'sequential scan'
	ytitle = 'ADU'
	plot, array(0,*), title='I', xtitle=xtitle, ytitle=ytitle, $
		psym=1,xticklen=1
	plot, array(1,*), title='Q', xtitle=xtitle, ytitle=ytitle, $
		psym=1,xticklen=1
	plot, array(2,*), title='U', xtitle=xtitle, ytitle=ytitle, $
		psym=1,xticklen=1
	plot, array(3,*), title='V', xtitle=xtitle, ytitle=ytitle, $
		psym=1,xticklen=1
endif
!p.multi=0
;
;	Try to determine the bad scans.
;
factor = 3.0
if n_elements(fact) ne 0 then factor = fact
print
print, 'Possible bad (sequential) scans looking at I ...'
list = array(0,*)
rms = calc_rms(list)
mm = mean(list)
w = where(abs(list - mm) gt rms*factor)
if sizeof(w, 0) gt 0 then print, w	else print, '     (none found)'

print
print, 'Possible bad (sequential) scans looking at Q ...'
list = array(1,*)
rms = calc_rms(list)
mm = mean(list)
w = where(abs(list - mm) gt rms*factor)
if sizeof(w, 0) gt 0 then print, w	else print, '     (none found)'

print
print, 'Possible bad (sequential) scans looking at U ...'
list = array(2,*)
rms = calc_rms(list)
mm = mean(list)
w = where(abs(list - mm) gt rms*factor)
if sizeof(w, 0) gt 0 then print, w	else print, '     (none found)'

print
print, 'Possible bad (sequential) scans looking at V ...'
list = array(3,*)
rms = calc_rms(list)
mm = mean(list)
w = where(abs(list - mm) gt rms*factor)
if sizeof(w, 0) gt 0 then print, w	else print, '     (none found)'

print
;
;	Close input file and free unit number.
;
free_lun, in_unit
;
end

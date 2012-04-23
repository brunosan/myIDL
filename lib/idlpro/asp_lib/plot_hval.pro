pro plot_hval, infile, array, type=type, noplot=noplot, v101=v101
;+
;
;	procedure:  plot_hval
;
;	purpose:  plot and/or return a record (scan) header value
;
;	author:  rob@ncar, 3/93
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
	print, "usage:  plot_hval, infile [, array]"
	print
	print, "	Plot and/or return a record (scan) header value."
	print
	print, "	Arguments"
	print, "		infile	   - input file name"
	print, "		array	   - optional output array name"
	print, "			     (floating point)"
	print
	print, "	Keywords"
	print, "		type	   - string describing header value"
	print, "			       'light'  (light level; def)"
	print, "			       'time'   (time in hours)"
	print, "			       'xsee'   (X-seeing for v100)"
	print, "			       'ysee'   (Y-seeing for v100)"
	print, "			       'vttaz'  (azimuth)"
	print, "			       'vttel'  (elevation)"
	print, "			       'tblpos' (table position)"
	print, "		noplot	   - if set, do not plot the value"
	print, "			     (def=plot it)"
	print, "		v101	   - set to force version 101"
	print, "			     (def=use version # in op hdr)"
	print
	print
	print, "   ex:  plot_hval, '02.fa.map'	; plot light level"
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
stdout_unit = -1
seq_scan = 0
do_ignore = false		; want this for bad data ??
if n_elements(type) eq 0 then type = 'light'
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
array = fltarr(nscan, /nozero)
;
;-----------------------------------------
;
;	PROCESS EACH SCAN.
;
for iscan = 0, nscan - 1 do begin

;	Skip to scan position.
	skip_scan, in_unit, fscan=iscan

;	Read scan header.
	if read_sc_hdr(in_unit, stdout_unit, false, $
		ignore=do_ignore, version=version) eq 1 then return

;	Grab header value.
	case type of

	  ; light value (same location in both versions)
	  'light': array(iscan) = s_vtt(22)

	  ; time (same location in both versions)
	  'time': array(iscan) = float(s_hour) + s_min/60.0 + s_sec/3600.0

	  ; X See for V100
	  'xsee': array(iscan) = s_see1/17.0

	  ; Y See for V100
	  'ysee': array(iscan) = s_see2/17.0

	  ; VTTAZ
	  'vttaz': array(iscan) = s_vtt(0)

	  ; VTTEL
	  'vttel': array(iscan) = s_vtt(1)

	  ; TBLPOS
	  'tblpos': array(iscan) = s_vtt(2)

	  ; error
	  else: message, '"type" error'

	endcase


endfor
;-----------------------------------------
;
;	Optionally plot values.
;
if not keyword_set(noplot) then begin
	window, /free
	title = infile
	xtitle = 'sequential scan'
	ytitle = type
	plot, array, ystyle=1, title=title, xtitle=xtitle, ytitle=ytitle
endif
;
;	Close input file and free unit number.
;
free_lun, in_unit
;
end

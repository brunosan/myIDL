pro aspview, infile, fscan=fscan,				$
	x1=x1, y1=y1, x2=x2, y2=y2, title=title, only1=only1,	$
	xs1=xs1, ys1=ys1, xs2=xs2, ys2=ys2,			$
	i_scl=i_scl, q_scl=q_scl, u_scl=u_scl, v_scl=v_scl,	$
	xpos=xpos, ypos=ypos,					$
	ignore=ignore, ngray=ngray, auto=auto, noverb=noverb, v101=v101
;+
;
;	procedure:  aspview
;
;	purpose:  display ASP I,Q,U,V specta in X Windows
;
;	author:  rob@ncar, 1/92
;
;	notes:  - i_scl, q_scl, u_scl, and v_scl are not used for special
;		  red/gray/blue colormap (invoked by tvasp.pro)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
usage:
	print
	print, "usage:  aspview, infile"
	print
	print, "	Display ASP I,Q,U,V specta in X Windows."
	print, "	(See plot_4.pro for creating PostScript plots.)"
	print
	print, "	Arguments"
	print, "		infile	- input ASP data file"
	print
	print, "	Keywords"
	print, "		fscan	- first sequential scan to plot"
	print, "			  (def=0=first sequential scan)"
	print, "		x1,x2	- column range (defs=0 to last)"
	print, "		y1,y2	- row range (defs=0 to last)"
	print, "		xs1,ys1	- indices used for scaling;"
	print, "		xs2,ys2	  values outside this rectangle"
	print, "			  will be truncated to the max/min"
	print, "			  values inside the rectangle"
	print, "			  (defs=x1, y1, x2, y2)"
	print, "		i_scl,	- data value ranges at which to scale"
	print, "		q_scl,	  I, Q, U, and V, respectively"
	print, "		u_scl,	  (defs=[min, max] of the data"
	print, "		v_scl	   inside points xs1,ys1 to xs2,ys2)"
	print, "		xpos,	- position of lower left corner of"
	print, "		 ypos	  window (pixels; def=let IDL decide)"
	print, "		ngray	- percent gray to insert in" 
	print, "			  special red-gray-blue colormap;"
	print, "			  1% is about 1.2 color indices"
	print, "			  (def=7)"
	print, "		title	- title of window (def=op and tape #s)"
	print, "		only1	- if set, do only one scan and quit"
	print, "			  (no prompt given; window left up)"
	print, "		ignore	- if set, ignore scan hdr error"
	print, "			  (scan header will not be printed)"
	print, "		auto	- if set, do not prompt between images"
	print, "		noverb	- if set, do not print op/scan headers"
	print, "		v101	- set to force version 101"
	print, "			  (def=use version # in op hdr)"
	print
	print, "		Note:  (x1,y1) is the lower left corner."
	print
	print, "   ex:  aspview, '02.fa.map', q_scl=[-75.0, 75.0], /auto"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Specify common blocks.
;
@op_hdr.com
@scan_hdr.com
@iquv.com
@iquv_label.com
@cbars.com
common profile4, p4_qu_range, p4_v_range, p4_ngray
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
done = false
special = false
do_keep = false
do_auto = false
do_ignore = false
do_verb = true
if keyword_set(ignore) then do_ignore = true
if keyword_set(auto) then do_auto = true
if keyword_set(noverb) then do_verb = false
stdout_unit = -1
ans = string(' ',format='(a1)')
if n_elements(fscan) eq 0 then fscan = 0
if fscan lt 0 then fscan = 0
seq_scan = fscan
if n_elements(ngray) eq 0 then ngray = 7
ngray = fix(ngray)
!p.font = 0				; use hardware font
newct, 10, /noverb, /spec    		; start out with normal grayscale
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
;	Use defaults file if present.
;
defaults_file = '$HOME/.aspviewrc'
void, findfile(defaults_file, count=count)
if count eq 1 then begin
	openr, unit, defaults_file, /get_lun
	vals = strarr(8)
	readf, unit, vals
	if not is_raw() then begin	; use second set for calibrated data
		s = ''
		readf, unit, s		; skip blank line
		readf, unit, vals
	endif
	free_lun, unit
	n = 80
	x1_def  = fix(strmid(vals(0), 3, n))
	x2_def  = fix(strmid(vals(1), 3, n))
	y1_def  = fix(strmid(vals(2), 3, n))
	y2_def  = fix(strmid(vals(3), 3, n))
	xs1_def = fix(strmid(vals(4), 3, n))
	xs2_def = fix(strmid(vals(5), 3, n))
	ys1_def = fix(strmid(vals(6), 3, n))
	ys2_def = fix(strmid(vals(7), 3, n))
	if (n_elements(x1)  eq 0) and (x1_def  ge 0) then x1  = x1_def
	if (n_elements(x2)  eq 0) and (x2_def  ge 0) then x2  = x2_def
	if (n_elements(y1)  eq 0) and (y1_def  ge 0) then y1  = y1_def
	if (n_elements(y2)  eq 0) and (y2_def  ge 0) then y2  = y2_def
	if (n_elements(xs1) eq 0) and (xs1_def ge 0) then xs1 = xs1_def
	if (n_elements(xs2) eq 0) and (xs2_def ge 0) then xs2 = xs2_def
	if (n_elements(ys1) eq 0) and (ys1_def ge 0) then ys1 = ys1_def
	if (n_elements(ys2) eq 0) and (ys2_def ge 0) then ys2 = ys2_def
endif
;
;	Set X and Y ranges
;	(uses dnumx and dnumy from op header common block).
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
x_len = x2 - x1 + 1
y_len = y2 - y1 + 1
if (x1 gt x2) or (y1 gt y2) or $
   (x1 lt 0) or (y1 lt 0) or $
   (x2 gt dnumx-1) or (y2 gt dnumy-1) then $
	message, 'Error in specifying x1,y1,x2,y2.'
;
;	Set scaling X and Y ranges.
;
if n_elements(xs1) eq 0 then xs1 = x1
if n_elements(ys1) eq 0 then ys1 = y1
if n_elements(xs2) eq 0 then xs2 = x2
if n_elements(ys2) eq 0 then ys2 = y2
if (xs1 lt x1) or (xs1 gt xs2) or (xs2 gt x2) $
   (ys1 lt y1) or (ys1 gt ys2) or (ys2 gt y2) then $
	message, 'Error in specifying xs1,ys1,xs2,ys2.'
do_trunc = false
if (xs1 ne x1) or (ys1 ne y1) or $
   (xs2 ne x2) or (ys2 ne y2) then do_trunc = true
xxs1 = xs1 - x1				; get relative range
xxs2 = xs2 - x1
yys1 = ys1 - y1
yys2 = ys2 - y1
;
;	Set plotting parameters.
;
border_width = 20
text_width = 75
space_width = 8
text_shift = 8
label_x_offset = 10
label_y_offset = 10
text_x_offset = 10
text_y_offset = 15
x_bar_len = 30
y_bar_len = y_len
;
x_i = 0
x_q = x_len + border_width
x_u = x_i
x_v = x_q
y_i = y_len + border_width
y_q = y_i
y_u = 0
y_v = y_u
;
x_i_bar = x_q + x_len + border_width + space_width
y_i_bar = y_q
x_quv_bar = x_i_bar
y_quv_bar = y_v
;
x_iquv_text = x_i_bar + x_bar_len + text_x_offset
y_i_text1 = y_i_bar
y_i_text2 = y_i_bar + y_bar_len - text_y_offset
y_v_text1 = y_quv_bar + text_shift
y_u_text1 = y_v_text1 + text_y_offset
y_q_text1 = y_u_text1 + text_y_offset
y_q_text2 = y_quv_bar + y_bar_len - text_y_offset
y_u_text2 = y_q_text2 - text_y_offset
y_v_text2 = y_u_text2 - text_y_offset
;
x_i_label = x_i + x_len + label_x_offset
x_q_label = x_q + x_len + label_x_offset
x_u_label = x_i_label
x_v_label = x_q_label
y_i_label = y_i + label_y_offset
y_q_label = y_i_label
y_u_label = y_u + label_y_offset
y_v_label = y_u_label
;
xsize = (x_len + border_width) * 2 + space_width + x_bar_len + $
	text_width
ysize = y_len * 2 + border_width
;
;	Get number of scans [uses op header variables].
;
nscan = get_nscan()
;
;	Get operation type [uses op header variables].
;
op_type = get_optype()
;
;	Check if this is a movie.
;
if (op_type eq 'Map') and (nfstep gt 1) then begin
	print
	print, '**************************************************************'
	print
	print, 'This is a movie containing ' + stringit(nfstep) + ' maps,' + $
	       ' with '+ stringit(nscan) + ' scans each.'
	print
	print, '**************************************************************'
	nscan = nscan * nfstep
endif
;
;	Jump to location of first scan to view.
;
skip_scan, infile_unit, fscan=fscan
;
;	Create a window with a title.
;
if n_elements(title) eq 0 then title = 'Operation ' + stringit(opnum) + $
				       ' from Tape ' + stringit(tapename)
if (n_elements(xpos) eq 0) and (n_elements(ypos) eq 0) then begin
	window, /free, xsize=xsize, ysize=ysize, title=title
endif else if (n_elements(xpos) ne 0) and (n_elements(ypos) ne 0) then begin
	window, /free, xsize=xsize, ysize=ysize, title=title, $
		xpos=xpos, ypos=ypos
endif else begin
	message, "Set *both* 'xpos' and 'ypos' or *neither*."
endelse
win_index = !d.window
;
;----------------------------------------------------------------
;
;	LOOP FOR ALL SCANS
;
while (not (EOF(infile_unit) or done)) do begin
;
;	Read and list scan header.
	if do_ignore then begin
		print
		print, 'SEQ. SCAN ' + stringit(seq_scan)
	endif
	if read_sc_hdr(infile_unit, stdout_unit, do_verb, seq_scan, $
		ignore=do_ignore, version=version) eq 1 then return
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
;	Truncate values outside scale range to the max/min of the range.
	if do_trunc then asp_trunc, ii, qq, uu, vv, xxs1, yys1, xxs2, yys2
;
;	Calculate and print ranges.
	min_i = min(ii, max=max_i)
	min_q = min(qq, max=max_q)
	min_u = min(uu, max=max_u)
	min_v = min(vv, max=max_v)
	min_qu = min_q < min_u			; minimim of Q and U
	max_qu = max_q > max_u			; maximum of Q and U
	qu_range = max_qu > (-min_qu)		; maximum magnitude
	v_range =  max_v  > (-min_v)		; maximum magnitude
	p = ' range (' + stringit(xs1) + ':' + stringit(xs2) + $
		  ', ' + stringit(ys1) + ':' + stringit(ys2) + ') = '
	print, 'Raw I' + p + ' ' + stringit(min_i) + ' to ' + stringit(max_i)
	print, 'Raw Q' + p       + stringit(min_q) + ' to ' + stringit(max_q)
	print, 'Raw U' + p       + stringit(min_u) + ' to ' + stringit(max_u)
	print, 'Raw V' + p       + stringit(min_v) + ' to ' + stringit(max_v)
;
;	Plot I,Q,U,V.
	erase					; erase previous image
	if special then begin			; SPECIAL COLOR IS ON
		tvasp, ii, x_i, y_i, /red, center=ngray, /gray
		tvasp, qq, x_q, y_q, /red, center=ngray, $
			min=(-qu_range), max=qu_range
		tvasp, uu, x_u, y_u, /red, center=ngray, $
			min=(-qu_range), max=qu_range
		tvasp, vv, x_v, y_v, /red, center=ngray, $
			min=(-v_range), max=v_range
	endif else begin			; SPECIAL COLOR IS OFF
		newct_tvscl, ii, x_i, y_i, srange=i_scl
		newct_tvscl, qq, x_q, y_q, srange=q_scl
		newct_tvscl, uu, x_u, y_u, srange=u_scl
		newct_tvscl, vv, x_v, y_v, srange=v_scl
	endelse
;
;	Label with I,Q,U,V.
	label_iquv, special
;
;	Plot the colorbars.
	plot_cbars, special, ngray, s_snum, seq_scan, $
		i_scl=i_scl, q_scl=q_scl, u_scl=u_scl, v_scl=v_scl
;
;	Go to end if 'only1' specified.
	if keyword_set(only1) then begin
		do_keep = true
		goto, afterwhile
	endif
;
;	Skip prompt for auto mode.
	if do_auto then goto, afterprompt
;
;	Give user option to select next scan to view, change colormap,
;	toggle special scale, do profiling, or quit.
again:		print

    print, 'Enter sequential scan number (0 to ' + stringit(nscan - 1) + ') or'
    print, '  n = next scan             b = back (previous) scan'
    print, '  p = profiles              z = zoom'
    print, '  g = grayscale             r = reverse grayscale' 
    print, '  s = special cmap (toggle) c = other colormap' 
    read,  '  x = exit (keep window)    q = quit (kill window)  : ', ans
		if ans eq 'q' then begin		; quit
			done = true
		endif else if ans eq 'x' then begin	; exit
			done = true
			do_keep = true
		endif else if ans eq 'g' then begin	; grayscale colormap
			if special then begin		; (turn special off)
				erase
				special = false
				newct, 10, /noverb, /spec
				newct_tvscl, ii, x_i, y_i, srange=i_scl
				newct_tvscl, qq, x_q, y_q, srange=q_scl
				newct_tvscl, uu, x_u, y_u, srange=u_scl
				newct_tvscl, vv, x_v, y_v, srange=v_scl
				print
				print, 'SPECIAL COLOR is now OFF'
			endif else newct, 10, /noverb, /spec
			label_iquv, special
			plot_cbars, special, ngray, s_snum, seq_scan, $
				i_scl=i_scl, q_scl=q_scl, $
				u_scl=u_scl, v_scl=v_scl
			goto, again
		endif else if ans eq 'r' then begin	; reverse grayscale
			if special then begin		; (turn special off)
				erase
				special = false
				newct, 11, /noverb, /spec
				newct_tvscl, ii, x_i, y_i, srange=i_scl
				newct_tvscl, qq, x_q, y_q, srange=q_scl
				newct_tvscl, uu, x_u, y_u, srange=u_scl
				newct_tvscl, vv, x_v, y_v, srange=v_scl
				print
				print, 'SPECIAL COLOR is now OFF'
			endif else newct, 11, /noverb, /spec
			label_iquv, special
			plot_cbars, special, ngray, s_snum, seq_scan, $
				i_scl=i_scl, q_scl=q_scl, $
				u_scl=u_scl, v_scl=v_scl
			goto, again
		endif else if ans eq 'c' then begin	; change colormap
			if special then begin		; (turn special off)
				erase
				special = false
				newct_tvscl, ii, x_i, y_i, srange=i_scl
				newct_tvscl, qq, x_q, y_q, srange=q_scl
				newct_tvscl, uu, x_u, y_u, srange=u_scl
				newct_tvscl, vv, x_v, y_v, srange=v_scl
				print
				print, 'SPECIAL COLOR is now OFF'
			endif
			label_iquv, special
			plot_cbars, special, ngray, s_snum, seq_scan, $
				i_scl=i_scl, q_scl=q_scl, $
				u_scl=u_scl, v_scl=v_scl
			if change_cmap(/spec) eq 1 then done = true
			if not done then goto, again
		endif else if ans eq 's' then begin
			if special then begin		; turn special off
				erase
				special = false
				newct, 10, /noverb, /spec
				newct_tvscl, ii, x_i, y_i, srange=i_scl
				newct_tvscl, qq, x_q, y_q, srange=q_scl
				newct_tvscl, uu, x_u, y_u, srange=u_scl
				newct_tvscl, vv, x_v, y_v, srange=v_scl
				print
				print, 'SPECIAL COLOR is now OFF'
			endif else begin		; turn special on
				erase
				special = true
				tvasp, ii, x_i, y_i, /red, center=ngray, /gray
				tvasp, qq, x_q, y_q, /red, center=ngray, $
					min=(-qu_range), max=qu_range
				tvasp, uu, x_u, y_u, /red, center=ngray, $
					min=(-qu_range), max=qu_range
				tvasp, vv, x_v, y_v, /red, center=ngray, $
					min=(-v_range), max=v_range
				print
				print, 'SPECIAL COLOR is now ON'
			endelse
			label_iquv, special
			plot_cbars, special, ngray, s_snum, seq_scan, $
				i_scl=i_scl, q_scl=q_scl, $
				u_scl=u_scl, v_scl=v_scl
			goto, again
		endif else if ans eq 'p' then begin	; profile
;;			aspprofile, ii, qq, uu, vv, $
;;				x_i, y_i, x_q, y_q, x_u, y_u, x_v, y_v
			p4_qu_range = qu_range
			p4_v_range = v_range
			p4_ngray = ngray
			profile4, special+3, ii, qq, uu, vv, $
				x_i, y_i, x_q, y_q, x_u, y_u, x_v, y_v
			if special then begin
				tvasp, ii, x_i, y_i, /red, center=ngray, /gray
				tvasp, qq, x_q, y_q, /red, center=ngray, $
					min=(-qu_range), max=qu_range
				tvasp, uu, x_u, y_u, /red, center=ngray, $
					min=(-qu_range), max=qu_range
				tvasp, vv, x_v, y_v, /red, center=ngray, $
					min=(-v_range), max=v_range
			endif else begin
				newct_tvscl, ii, x_i, y_i, srange=i_scl
				newct_tvscl, qq, x_q, y_q, srange=q_scl
				newct_tvscl, uu, x_u, y_u, srange=u_scl
				newct_tvscl, vv, x_v, y_v, srange=v_scl
			endelse
			goto, again
		endif else if ans eq 'z' then begin	; zoom
			print
			zoom
			goto, again
		endif else if ans eq 'n' then begin	; get next scan
			seq_scan = seq_scan + 1
		endif else if ans eq 'b' then begin	; get previous scan
			if seq_scan eq 0 then begin
				print & print, 'No previous scan.'
				goto, again
			endif
			seq_scan = seq_scan - 1
			skip_scan, infile_unit, fscan=seq_scan
		endif else if (ans ge 0) and $
			      (ans lt nscan) then begin ; skip to scan
			seq_scan = ans
			skip_scan, infile_unit, fscan=seq_scan
		endif else begin			; error
			goto, again
		endelse
afterprompt:
endwhile
afterwhile:
;
;----------------------------------------------------------------
;
;	Close input file and free unit number.
;
free_lun, infile_unit
;
;	Optionally remove window and install normal grayscale colormap.
;
if not do_keep then begin
	wdelete, win_index
	newct, 10, /noverb
endif
;
;	Done.
;
print
end

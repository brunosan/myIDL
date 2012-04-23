pro flatav, infile, outfile, fscan=fscan, v101=v101
;+
;
;	procedure:  flatav
;
;	purpose:  display I,Q,U,V ASP data from operation file, average
;			16 scans and write to file, eliminate first column
;                       which has bad pixels, this version does not querry
;                       for bad frames, averages all of them.  Modified from
;                       flatavg.pro.
;
;	author:  lites@ncar, 1/92
;
;	notes:  1. add test with scan number, IQUV, ?
;		   Problem:  diff colormaps change the color of the text,
;		   so may not see the text depending on the color map.
;		   Don't want to make it title of window, as would have to
;		   open/close window for each scan.
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() lt 1) or (n_params() gt 2) then begin
	print
	print, "usage:  flatav, infile, outfile, [,fscan = x]"
	print
	print, "	Display I,Q,U,V ASP data from operation file;"
	print, "	average 16 frames to get dark, flat fields."
	print
	print, "		fscan default = 0"
	print, "		(i.e., start with first sequential scan)"
        print, "		outfile contains average of flat fields"
	print
	print, "	Keywords"
	print, "		v101     - set to force version 101"
	print, "			   (def=use version # in op hdr)"
	print
	return
endif
;-
;
;	Specify common blocks.
;
@op_hdr.com
@scan_hdr.com
@iquv.com
@iquv_label.com
@newct.com
;
;	Set types and sizes of common block variables.
;
@op_hdr.set
@scan_hdr.set
@newct.set
;
;	Set general parameters.
;
stdout_unit = -1
true = 1
false = 0
done = false
ans = string(' ',format='(a1)')
;x_start = 0
;y_start = 0
;x_len = 244
;y_len = 235
x_start = 1
y_start = 0
x_len = 255
y_len = 229
x_end = x_start + x_len - 1
y_end = y_start + y_len - 1
rebin_factor = 1
x_len_rebin = x_len * rebin_factor
y_len_rebin = y_len * rebin_factor
border_width = 10	; width of plus-shape in center between images
xsize = x_len_rebin * 2 + border_width
ysize = y_len_rebin * 2 + border_width
if n_elements(fscan) eq 0 then fscan = 0
if fscan lt 0 then fscan = 0
xx = x_len_rebin + border_width
yy = y_len_rebin + border_width
label_offset = 10
x_i = 0		& y_i = yy
x_q = xx	& y_q = yy
x_u = 0		& y_u = 0
x_v = xx	& y_v = 0
x_i_label = x_i + label_offset
y_i_label = y_i + label_offset
x_q_label = x_q + label_offset
y_q_label = y_q + label_offset
x_u_label = x_u + label_offset
y_u_label = y_u + label_offset
x_v_label = x_v + label_offset
y_v_label = y_v + label_offset
;
;	Set input file.
;
openr, infile_unit, infile, /get_lun
;
;	Read and possibly list operation header.
;
if read_op_hdr(infile_unit, stdout_unit, true) eq 1 then return
;
;	Set I,Q,U,V arrays
;	(must have set 'dnumx' and 'dnumy' in 'op_hdr' common block first --
;	 from read_op_hdr).
;
set_iquv
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Jump to location of first scan to view.
;
skip_scan, infile_unit, fscan=fscan
;
;	Create a window with a title.
;
label = 'Operation ' + strcompress(string(opnum)) + $
	' from tape ' + strcompress(string(tapename))
window, 0, xsize=xsize, ysize=ysize, title=label
;
;----------------------------------------------
;       setup arrays for averaging
        iav = fltarr(x_end-x_start+1,y_end-y_start+1)
        qav = iav
        uav = iav
        vav = iav
        nscan = 0
        nscn = 0
;
;	LOOP FOR ALL SCANS
;
while (not (EOF(infile_unit) or done)) do begin
;
;	Read and list scan header.
	if read_sc_hdr(infile_unit, stdout_unit, true, $
		version=version) eq 1 then return
;
;;	Print scan number.
;;	print, format='(/"SCAN ", I5, $)', s_snum
;;	print, format='(5X, 20("-"))'
;
;	Read scan data.
	if read_sc_data(infile_unit) eq 1 then return
        nscan = nscan + 1
;
;	Chop out middle to use.
	ii =  i(x_start:x_end, y_start:y_end)
	qq =  q(x_start:x_end, y_start:y_end)
	uu =  u(x_start:x_end, y_start:y_end)
	vv =  v(x_start:x_end, y_start:y_end)
		if ans eq 'q' then done = true
;
;	Print ranges.
	minval = min(ii, max=maxval)
	print, 'I	', minval, ' to ', maxval
	minval = min(qq, max=maxval)
	print, 'Q	', minval, ' to ', maxval
	minval = min(uu, max=maxval)
	print, 'U	', minval, ' to ', maxval
	minval = min(vv, max=maxval)
	print, 'V	', minval, ' to ', maxval
;
;	Blow up the array to (rebin_factor ** 2) times the original size.
;	ii = rebin(ii, x_len_rebin, y_len_rebin)
;	qq = rebin(qq, x_len_rebin, y_len_rebin)
; 	uu = rebin(uu, x_len_rebin, y_len_rebin)
;	vv = rebin(vv, x_len_rebin, y_len_rebin)
;
;	Plot I,Q,U,V.
	tvscl, ii, x_i, y_i
	tvscl, qq, x_q, y_q
	tvscl, uu, x_u, y_u
	tvscl, vv, x_v, y_v
;
;	Label with I,Q,U,V.
	label_iquv, 0
;
;	Pause with option to quit.
;		print, ' '
;		read, $
;		'Pause...  (Hit  ''c'' to save individ. scan,', $
;			' ''a'' to add, ''return'' to delete)',ans
  ans = 'a'

;       add average of arrays
        if ans eq 'a' then begin
        	iav = iav + ii
        	qav = qav + qq
        	uav = uav + uu
        	vav = vav + vv
                nscn = nscn + 1
 	endif
;
	if ans eq 'c' then begin
		ifil = 'junkj      '
		read,' enter filename for image:',ifil
		save,ii,filename=ifil
;			if change_cmap() eq 1 then done = true
;			label_iquv, 0
	endif
;	check for 16 frames average
		if nscan eq 16 then done = true
endwhile
;
;----------------------------------------------
;
;	Close input file and free unit number.
;
free_lun, infile_unit

;	renormalize average arrays
        fnscan = nscn
	print,' number of frames averaged =',fnscan
	iav = iav/fnscan
        qav = qav/fnscan
	uav = uav/fnscan
	vav = vav/fnscan
;	Print ranges.
	minval = min(iav, max=maxval)
	print, 'I	', minval, ' to ', maxval
	minval = min(qav, max=maxval)
	print, 'Q	', minval, ' to ', maxval
	minval = min(uav, max=maxval)
	print, 'U	', minval, ' to ', maxval
	minval = min(vav, max=maxval)
	print, 'V	', minval, ' to ', maxval
;
;	save the averages
	save,iav,qav,uav,vav,filename=outfile

;	Plot average images I,Q,U,V.
	tvscl, iav, x_i, y_i
	tvscl, qav, x_q, y_q
	tvscl, uav, x_u, y_u
	tvscl, vav, x_v, y_v
		read, $
		'Pause...  (Hit ''c'' to change colormap.)  ', $
			ans
		if ans eq 'c' then begin
			if change_cmap() eq 1 then done = true
			label_iquv, 0
		endif
;
;

;	Remove window.
;
wdelete, 0
;
;	Done.
;
print
end

pro flatavg, infile, outfile, fscan=fscan, nscan=nscan, v101=v101
;+
;
;	procedure:  flatavg
;
;	purpose:  display I,Q,U,V ASP data from operation file, optionally
;		  average scans, and write to save file; eliminate first
;                 column and last rows, which have bad pixels
;
;	author:  lites@ncar and rob@ncar, 1/92
;
;	notes:   This program works in two basic modes -
;
;		   1) averaging I,Q,U,V's and outputting them to 'outfile'
;		   2) outputting an I, calling it array 'dark' or array 'clear'
;
;		 Do not try to use both modes in one run.
;
;		 Note that X,Y ranges are currently hardwired !!
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() lt 1 then begin
	print
	print, "usage:  flatavg, infile [, outfile]"
	print
	print, "	Display I,Q,U,V ASP data from operation file"
	print, "	and average user-selected scans; alternately save an"
	print, "	individual I to a file (i.e., array 'dark' or 'clear'"
	print, "	-- you will be prompted for the output file name in"
	print, "	that case, and 'outfile' will not be used)."
	print
	print, "	Arguments"
	print, "		infile	 - input ASP file"
	print, "		outfile	 - output file to contain average"
	print, "			   of input scans (def = flatavg.save)"
	print
	print, "	Keywords"
	print, "		fscan	 - first scan to plot"
	print, "			   (def = 0 = first sequential scan)"
	print, "		nscan	 - number of scans to consider"
	print, "			   (def = 16)"
	print, "		v101	 - set to force version 101"
	print, "			   (def=use version # in op hdr)"
	print
	print
	print, "   ex:  flatavg,'29.fa.cal','29.fa.clear.sav',fscan=1,nscan=8"
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
nsum = 0
true = 1
false = 0
ans = string(' ',format='(a1)')
if n_elements(outfile) eq 0 then outfile = 'flatavg.save'
if n_elements(nscan) eq 0 then nscan = 16
nscan = nscan > 1				; nscan must ge 1
if n_elements(fscan) eq 0 then fscan = 0
if fscan lt 0 then fscan = 0
;
;	Set range parameters.
;
x_start = 1					; HARDWIRED RANGES !!!
x_end = 255

y_start = 0
y_end = 228

x_len = x_end - x_start + 1
y_len = y_end - y_start + 1

;
;	Set plotting parameters.
;
border_width = 10	; width of plus-shape in center between images
xsize = x_len * 2 + border_width
ysize = y_len * 2 + border_width
xx = x_len + border_width
yy = y_len + border_width
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
;	Read and list operation header.
;
if read_op_hdr(infile_unit, stdout_unit, true) eq 1 then return
;
;	Set I,Q,U,V arrays
;	(must have set 'dnumx' and 'dnumy' in 'op_hdr'
;	 common block first -- from read_op_hdr).
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
title = 'Operation ' + stringit(opnum) + ' from tape ' + stringit(tapename)
window, xsize=xsize, ysize=ysize, title=title, /free
;
;       Initialize (zero) arrays for averaging.
;
iav = fltarr(x_len, y_len)
qav = iav
uav = iav
vav = iav
;
;----------------------------------------------
;
;	LOOP FOR ALL SCANS
;
for iscan = 0, nscan-1 do begin
;
;	Read and list scan header.
	if read_sc_hdr(infile_unit, stdout_unit, true, $
		version=version) eq 1 then return
;
;	Read scan data.
	if read_sc_data(infile_unit) eq 1 then return
;
;	Chop out middle to use.
	ii =  i(x_start:x_end, y_start:y_end)
	qq =  q(x_start:x_end, y_start:y_end)
	uu =  u(x_start:x_end, y_start:y_end)
	vv =  v(x_start:x_end, y_start:y_end)
;
;	Print ranges.
	min_i = min(ii, max=max_i)
	min_q = min(qq, max=max_q)
	min_u = min(uu, max=max_u)
	min_v = min(vv, max=max_v)
	print, 'I range:   ' + stringit(min_i) + ' to ' + stringit(max_i)
	print, 'Q range:  ' + stringit(min_q) + ' to ' + stringit(max_q)
	print, 'U range:  ' + stringit(min_u) + ' to ' + stringit(max_u)
	print, 'V range:  ' + stringit(min_v) + ' to ' + stringit(max_v)
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
	print
	read, 'Pause... (''d''=save dark, ''c''=save clear,', $
		' ''s''=sum in, ''ret''=ignore, ''q''=quit) ', ans
;
	case ans of
;
;         Sum in images.
	  's':	begin
        		iav = iav + ii
        		qav = qav + qq
        		uav = uav + uu
        		vav = vav + vv
			nsum = nsum + 1
		end
;
;	  Save individual clear I.
	  'c':	begin
			file = 'junk       '
			print
			read,'Enter filename for clear (w/out quotes):  ', file
			clear = ii
			print
			print, 'Saving array "clear" to file:  ' + file
			save, clear, filename=file
		end
;
;	  Save individual dark I.
	  'd':	begin
			file = 'junk       '
			print
			read,'Enter filename for dark (w/out quotes):  ', file
			dark = ii
			print
			print, 'Saving array "dark" to file:  ' + file
			save, dark, filename=file
		end
;
;	  Quit.
	  'q':	begin
			wdelete
			print
			print, '(No averaged scans saved.)'
			print
			return
		end
;
;	  Ignore this scan.
	  else:	begin
;			(don't sum it in)
		end
	endcase
;
endfor
;
;----------------------------------------------
;
;	Close input file.
;
free_lun, infile_unit
;
;	Check if any scans have been summed in.
;
if nsum eq 0 then begin
	print
	print, 'No scans to average.'
	print
	return
endif
;
;	Compute the average arrays.
;
fnscan = float(nsum)
print
print, 'Number of scans averaged = ' + stringit(nsum)
print
iav = iav / fnscan
qav = qav / fnscan
uav = uav / fnscan
vav = vav / fnscan
;
;	Print ranges.
;
min_i = min(iav, max=max_i)
min_q = min(qav, max=max_q)
min_u = min(uav, max=max_u)
min_v = min(vav, max=max_v)
print, 'I avg range:   ' + stringit(min_i) + ' to ' + stringit(max_i)
print, 'Q avg range:  ' + stringit(min_q) + ' to ' + stringit(max_q)
print, 'U avg range:  ' + stringit(min_u) + ' to ' + stringit(max_u)
print, 'V avg range:  ' + stringit(min_v) + ' to ' + stringit(max_v)
;
;	Save the averages.
;
print
print, 'Choose the names of the arrays for the save file:'
print, '     ''d'' = save average I as ''dark'''
print, '     ''c'' = save average I as ''clear'''
print, '    else = save the entire set as ''iav, qav, uav, vav'''
read, ans
if ans eq 'd' then begin
	dark = iav
	print
	print, 'Saving ''dark'' to file ' + outfile + ' ...'
	print
	save, dark, filename=outfile
endif else if ans eq 'c' then begin
	clear = iav
	print
	print, 'Saving ''clear'' to file ' + outfile + ' ...'
	print
	save, clear, filename=outfile
endif else begin
	print
	print, 'Saving ''iav,qav,uav,vav'' to file ' + outfile + ' ...'
	print
	save, iav, qav, uav, vav, filename=outfile
endelse
;
;	Plot average images I,Q,U,V.
;
print, 'Plotting averaged images ...'
print
tvscl, iav, x_i, y_i
tvscl, qav, x_q, y_q
tvscl, uav, x_u, y_u
tvscl, vav, x_v, y_v
label_iquv, 0
read, 'Pause...  (hit ''c'' to change colormap)  ', ans
;
if ans eq 'c' then begin
	void, change_cmap()
	label_iquv, 0
endif
;
;	Remove window.
;
wdelete
;
;	Done.
;
print
end

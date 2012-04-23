pro shgview, infile, $
	x1=x1, y1=y1, x2=x2, y2=y2, $
	xs1=xs1, ys1=ys1, xs2=xs2, ys2=ys2, $
	xshg1=xshg1, xshg2=xshg2, $
	fscan=fscan, lscan=lscan, fmap=fmap, $
	in_shg=in_shg, out_shg=out_shg, nosound=nosound, $
	ignore=ignore, ngray=ngray, v101=v101
;+
;
;	function:  shgview
;
;	purpose:  produce spectroheliogram from ASP data and allow user to
;		  see spectra for specified (mouse-selected) scans
;
;	author:  rob@ncar, 6/93
;
;	notes:  - make a nicer widget version with buttons later
;		- handle default dimensions like aspview (i.e., .aspviewrc)
;		- handle 'movie' operations later
;		- handle change of color maps
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  shgview, infile"
	print
	print, "	Produce spectroheliogram from ASP data and allow user"
	print, "	to see spectra for specified (mouse-selected) scans."
	print
	print, "	Arguments"
	print, "		infile	  - input file name of map"
	print
	print, "	Keywords"
	print, "		x1,x2	  - column range for spectra"
	print, "			    (defs=0 to last)"
	print, "		xshg1,	  - column range for generation of"
	print, "		 xshg2	    spectroheliogram (defs=0 to last)"
	print, "		y1,y2	  - row range (defs=0 to last)"
	print, "		xs1,ys1	  - indices used for scaling spectra"
	print, "		xs2,ys2	    (values outside this rectangle"
	print, "			     will be truncated to the max/min"
	print, "			     values inside the rectangle;"
	print, "			     defs=x1, x2, y1, y2)"
	print, "		fscan,	  - first and last seq. scans of a map"
	print, "		 lscan	    to use (defs = 0 to last)"
	print, "		fmap	  - first seq. map of a movie to plot"
	print, "			    (def = 0 = first sequential map)"
	print, "		in_shg	  - input spectroheliogram (2D array"
	print, "			    with X range 'fscan' to 'lscan';"
	print, "			    def = generate it from 'infile')"
	print, "		out_shg	  - output spectroheliogram (2D array;
	print, "			    def = don't output it)"
	print, "		ignore	  - if set, ignore scan hdr error"
	print, "		ngray	  - percent gray to insert in" 
	print, "			    special red-gray-blue colormap;"
	print, "			    1% is about 1.2 color indices"
	print, "			    (def=7)"
	print, "		v101	  - set to force version 101"
	print, "			    (def=use version # in op hdr)"
	print
	print, "	Note:  'movie' operations not supported yet!"
	print
	print, "   ex:  shgview, '02.fa.map', xshg1=80, xshg2=90"
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
stdout_unit = -1
do_ignore = false
if keyword_set(ignore) then do_ignore = true
if n_elements(ngray) eq 0 then ngray = 7
ngray = fix(ngray)
aspvwin_up = false
	if n_elements(fmap) ne 0 then message, 'movies not supported yet'
	fmap = 0
;
;	Get information from input file to operation header common block.
;
openr, infile_unit, infile, /get_lun
if read_op_hdr(infile_unit, stdout_unit, false) eq 1 then return
free_lun, infile_unit
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then begin
	version = 101
	do_v101 = true
endif else begin
	version = get_version()
	do_v101 = false
endelse
;
;	Set scan information.
;
nscan = get_nscan()		; uses op header common block
if n_elements(fscan) eq 0 then fscan = 0
if n_elements(lscan) eq 0 then lscan = nscan - 1
;
;	Set X and Y ranges
;	(uses dnumx and dnumy from op header common block).
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
;
;	Set scaling X and Y ranges.
;
if n_elements(xs1) eq 0 then xs1 = x1
if n_elements(ys1) eq 0 then ys1 = y1
if n_elements(xs2) eq 0 then xs2 = x2
if n_elements(ys2) eq 0 then ys2 = y2
;
;	Set spectroheliogram X range.
;
if n_elements(xshg1) eq 0 then xshg1 = 0
if n_elements(xshg2) eq 0 then xshg2 = dnumx - 1
;
;	Get spectroheliogram.
;
if n_elements(in_shg) eq 0 then begin		; Generate the shg.

	shg, infile, out_shg, itype='I', x1=xshg1, x2=xshg2, y1=y1, y2=y2, $
		fscan=fscan, lscan=lscan, fmap=fmap, $
		ignore=do_ignore, noplot=true, v101=do_v101

endif else begin				; Use user-input shg.
	out_shg = in_shg
endelse
;
;	Set dimension and location variables.
;
nx_shg = sizeof(out_shg, 1)
ny_shg = sizeof(out_shg, 2)
nx_shg2 = nx_shg / 2
ny_shg2 = ny_shg / 2
xpos_shg = 200
ypos_shg = 400
xpos_aspv = xpos_shg + nx_shg + 10
ypos_aspv = ypos_shg - ny_shg2 - 10
xloc_mouse = nx_shg2
yloc_mouse = ny_shg2
;
;	Display spectroheliogram.
;
window, xsize=nx_shg, ysize=ny_shg, xpos=xpos_shg, ypos=ypos_shg, /free, $
	title='shg'
winx_shg = !d.window
tvscl, out_shg
print
;
;---------------------------------------
;
;	LOOP TO PROCESS USER MOUSE EVENTS.
;
done = false
repeat begin
;
;	Set the mouse pointer.
	wset, winx_shg
	tvcrs, xloc_mouse, yloc_mouse
;
;	Print mouse information.
	print, 'Click on spectroheliogram with'
	print, '	mouse button 1 - to show spectra
	print, '	mouse button 2 - to show spectra (with aspview prompt)'
	print, '	mouse button 3 - to quit
	print
;
;	Wait till user depresses mouse button.
	cursor, xloc_mouse, yloc_mouse, /down, /device
;
;	Remove old aspview window if still up.
	if aspvwin_up then wdelete, winx_aspv
;
;	Process the specific mouse click.
	case !err of
;
	   1: begin					; BUTTON 1
		temp = out_shg
		temp(xloc_mouse, *) = 1.2 * temp(xloc_mouse, *)
		tvscl, temp
		print, 'Seq. scan ' + stringit(xloc_mouse) + $
			' -------------------------------------'
		aspview, infile, fscan=xloc_mouse, $
			x1=x1, y1=y1, x2=x2, y2=y2, $
			xpos=xpos_aspv, ypos=ypos_aspv, /only1, $
			xs1=xs1, ys1=ys1, xs2=xs2, ys2=ys2, /noverb, $
			ignore=do_ignore, ngray=ngray, v101=do_v101
		winx_aspv = !d.window
		aspvwin_up = true
	      end
;
	   2: begin					; BUTTON 2
		temp = out_shg
		temp(xloc_mouse, *) = 1.2 * temp(xloc_mouse, *)
		tvscl, temp
		print, 'Seq. scan ' + stringit(xloc_mouse)
		print
		aspview, infile, fscan=xloc_mouse, $
			x1=x1, y1=y1, x2=x2, y2=y2, $
			xpos=xpos_aspv, ypos=ypos_aspv, $
			xs1=xs1, ys1=ys1, xs2=xs2, ys2=ys2, /noverb, $
			ignore=do_ignore, ngray=ngray, v101=do_v101
	      end
;
	   4: begin					; BUTTON 3
		if not keyword_set(nosound) then begin
			print, 'Exiting ...'
			print
			sound = '/home/hao/stokes/etc/game_over.au'
			spawn, 'play ' + sound
		endif
		done = true
	      end
;
	   else: message, 'Contact Rob - wierd state in shgview.pro'
;
	endcase
;
endrep until done
;
;---------------------------------------
;
;	Delete spectroheliogram window.
;
wdelete, winx_shg
;
;	Done.
;
end

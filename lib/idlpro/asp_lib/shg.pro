pro shg, infile, image, itype=itype, x1=x1, y1=y1, x2=x2, y2=y2, $
	fscan=fscan, lscan=lscan, fmap=fmap, lmap=lmap, $
	title=title, infile2=infile2, light=light, $
	dark=dark, clear=clear, savefile=savefile, ignore=ignore, $
	ha1=ha1, ha2=ha2, hb1=hb1, hb2=hb2, noplot=noplot, $
	noaa=noaa, qnoaa=qnoaa, v101=v101
;+
;
;	function:  shg
;
;	purpose:  produce a spectroheliogram from ASP data
;
;	author:  rob@ncar, 4/92
;
;	examples:
;		shg,'03.fa.map',i,x1=80,x2=90,y2=229,sav='i.save'
;		shg,'03.fa.map',v,x1=120,x2=139,y2=229,sav='v.save',ity='v'
;		shgplot, 'W920612A1', 'i.save', 'v.save', /encap
;
;	notes:	- want to compare slit-jaw (on video tape) vs. PS output
;		- select multiple columns of I and average them (horizontally)
;		  to reduce noise
;		- look at step size (.375?) in vert. and horiz. dir's and
;		  linearly interpolate as necessary to get correct spacing
;		  (actually, no interpolation was required for usual case)
;		- use all but first 1 or 2 columns of raw data
;
;		- activate ha1, hb2 ??  (not using cuz often an extreme
;		  number near the min and max Y extents that throw off
;		  scaling; thus, the scale vector is 1.0's at each end region)
;
;		- FOR MOVIE MAPS:
;		  test fscan/lscan on on movie maps !!!!!!!!!
;
;		- "light" option added to test its usefulness; it is not
;		  worked out for de-streak run (i.e., "infile2" specified);
;		  "light" helps, but not a lot
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  shg, infile, image"
	print
	print, "	Produce a spectroheliogram from ASP data."
	print
	print, "	Arguments"
	print, "		infile	  - input file name of map"
	print, "		image	  - output image (if 'movie' map,"
	print, "			    then this will be a 3D array)"
	print
	print, "	Keywords"
	print, "		itype	  - I, Q, U, or V (def = 'I')"
	print, "		x1, y1	  - starting col,row indices (defs=0)"
	print, "		x2, y2	  - ending col,row indices (defs=last)"
	print, "		fscan,	  - first and last seq. scans of a map"
	print, "		 lscan	    to plot (defs = 0 to last)"
	print, "		fmap,	  - first and last seq. maps of a"
	print, "		 lmap	    movie to plot (defs = 0 to last)"
	print, "		noaa	  - NOAA a. r. number (see 'qnoaa')"
	print, "		qnoaa	  - query flag for setting NOAA number"
	print, "				0 = use 'quiet'"
	print, "				1 = use 'NOAA ' + noaa keyword"
	print, "				2 = query user (def)"
	print, "				3 = use op hdr (not avail.)"
	print, "		light	  - light level to normalize to"
        print, "			    (def = don't normalize)"
	print, "		title	  - X plot title (def = 'itype'; or"
	print, "			    sequential map if a movie)"
        print, "		infile2	  - input file for darks and clears"
        print, "			    (def = don't de-streak)"
        print, "		dark	  - dark scan number from infile2"
        print, "			    (def = 0)"
        print, "		clear	  - clear scan number from infile2"
        print, "			    (def = 1)"
        print, "		savefil	  - file used to save info for shgplot"
        print, "			    (def = do not save)"
	print, "		ha1,ha2	  - y-coords of 1st hairline region"
	print, "		hb1,hb2	  - y-coords of 2nd hairline region"
	print, "			    (ha2 and hb1 used in de-streaking;"
	print, "			     ha1 and hb2 currently unused)"
	print, "		noplot	  - if set, do not display 'image'"
	print, "		ignore	  - if set, ignore scan hdr error"
	print, "		v101	  - set to force version 101"
	print, "			    (def=use version # in op hdr)"
	print
	print, " note:  For itype='v', specify the blue lobe with x1,x2"
	print, "        (i.e., the right lobe in raw ASP data)."
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
do_light = false
if n_elements(light) ne 0 then begin
	if (light lt 1.0) or (light gt 10.0) then $
		message, 'Are you sure about that light level?'
	do_light = true
endif
if n_elements(itype) eq 0 then begin
	imtype = 'i'
endif else if (itype eq 'i') or (itype eq 'I') then begin
	imtype = 'i'
endif else if (itype eq 'q') or (itype eq 'Q') then begin
	imtype = 'q'
endif else if (itype eq 'u') or (itype eq 'U') then begin
	imtype = 'u'
endif else if (itype eq 'v') or (itype eq 'V') then begin
	imtype = 'v'
endif else begin
	message, "itype must be 'I', 'Q', 'U', or 'V'"
endelse
if n_elements(title) eq 0 then title = strupcase(imtype)
do_darks = true
if n_elements(infile2) eq 0 then do_darks = false
if n_elements(dark) eq 0 then dark = 0
if n_elements(clear) eq 0 then clear = 1
if (dark lt 0) or (clear lt 0) then $
	message, "Error in specifying 'dark' and/or 'clear'."
if n_elements(qnoaa) eq 0 then qnoaa = 2
;
;	Set input file.
;
openr, infile_unit, infile, /get_lun
;
;	Read and list operation header.
;
if read_op_hdr(infile_unit, stdout_unit, true) eq 1 then return
;
;	Set and save NOAA number for plot.
;
case qnoaa of
	0:	noaa_sv = 'quiet'			; use 'quiet'
	1:	if n_elements(noaa) eq 0 then begin	; use 'noaa' keyword
		    message, "'noaa' value not set"
		endif else begin
		    noaa_sv = 'NOAA ' + stringit(noaa)
		endelse
	2:	; (done below)				; query user
	3:	begin					; use op header
		    message, $
			"NOAA numbers are not in op headers yet"
		end
	else:	message, "'qnoaa' value out of range"	; error
endcase
;
;	Save operation header information for savefile.
;
opnum_sv = opnum
year_sv = year
month_sv = month
day_sv = day
hour_sv = hour
min_sv = min
sec_sv = sec
nmstep_sv = nmstep
mstepsz_sv = mstepsz
;
;	Set I,Q,U,V arrays.
;	(This is put after the op header is read because
;	 dnumx and dnumy are needed; see op_hdr common block.)
;
set_iquv
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Set X and Y ranges.
;	(This is put after the op header is read in case
;	 dnumx and dnumy are to be used.)
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
x_len = x2 - x1 + 1
y_len = y2 - y1 + 1
if (x_len lt 1) or (y_len lt 1) or $
   (x2 gt dnumx - 1) or (y2 gt dnumy - 1) then $
	message, 'Error in specifying the X,Y range -- check your typing.'
;
;	Get number of scans present.
;
nscan_avail = get_nscan()
;
;	Get operation type [uses op header variables].
;
op_type = get_optype()
;
;	Check if this is a movie.
;	(This is put after the op header is read because nfstep is used.)
;
if nfstep eq 1 then begin			; SINGLE MAP
	nmap = 1
	do_movie = false
	fmap = 0
endif else if (op_type eq 'Map') and $		; MOVIE
	      (nfstep gt 1) then begin
	print
	print, '**************************************************************'
	print
	print, 'This is a movie containing ' + stringit(nfstep) + ' maps,' + $
	       ' with '+ stringit(nscan_avail) + ' scans each.'
	print
	print, '**************************************************************'
	nfstep1 = nfstep - 1
	if n_elements(fmap) eq 0 then fmap = 0
	if n_elements(lmap) eq 0 then lmap = nfstep1
	if fmap gt lmap then message, 'lmap must be >= fmap'
	if (fmap lt 0) or (lmap gt nfstep1) then $
		message, 'fmap/lmap must be in range 0 to ' + stringit(nfstep1)
	nmap = lmap - fmap + 1
	do_movie = true
	seq_map = fmap
endif else begin				; HEADER ERROR
	print
	print, 'Warning:  "nfstep" in operation header is ' + $
		stringit(nfstep) + '; setting it to 1.'
	print
	nfstep = 1L
	nmap = 1
	do_movie = false
	fmap = 0
endelse
;
;	Set scan ranges.
;
if n_elements(fscan) eq 0 then fscan = 0
if fscan lt 0 then message, 'fscan must be >= 0'
m = nscan_avail - 1
if n_elements(lscan) eq 0 then begin
	lscan = m
endif else if lscan gt m then begin
	message, 'lscan must not be greater than ' + stringit(m)
endif
nscan = lscan - fscan + 1	; note: nscan=#scans/map (not 'total' if movie)
mscan = nscan / 2
if nscan lt 1 then message, 'lscan must be >= than fscan'
;
;	Set hairline regions.
;
if n_elements(ha2) eq 0 then ha2 = y1 + 1
if n_elements(hb1) eq 0 then hb1 = y2 - 1
if (n_elements(ha1) ne 0) or (n_elements(hb2) ne 0) then begin
	print
	print, '(Warning:  ''ha1'' and ''hb2'' are not currently used.)'
	print
endif
;
;	Set up output array.
;
if nmap eq 1 then begin
	image = fltarr(nscan, y_len, /nozero)
endif else begin
	image = fltarr(nscan, y_len, nmap, /nozero)
endelse
;
;       Read dark array and calculate scale vector.
;
if do_darks then shg_darks, infile2, 'i', x1, y1, x2, y2, dark, clear, $
                            dark_ary, scale_vec, ha1, ha2, hb1, hb2
;
;----------------------------------------------
;
;	****************************
;	LOOP FOR EACH MAP OF A MOVIE
;	****************************
;
for imap = 0, nmap - 1 do begin
;
;  Print map number for a movie.
   if do_movie then begin
	print, 'SEQUENTIAL MAP ' + stringit(seq_map) + $
		' ------------------------------'
	seq_map = seq_map + 1
   endif
;
;  Position to first scan of map to use.
   n = (fmap + imap) * nscan_avail + fscan	; equals 'fscan' if not movie
   skip_scan, infile_unit, fscan=n
;
;	   ---------------------------
;	   LOOP FOR EACH SCAN OF A MAP
;	   ---------------------------
;
   for iscan = 0, nscan - 1 do begin
;
;	Read scan header.
	if read_sc_hdr(infile_unit, stdout_unit, false, $
		ignore=do_ignore, version=version) eq 1 then return
;
;	Do special processing for middle scan.
	if (imap eq 0) and (iscan eq mscan) then begin
;
;		Save scan header information for savefile.
		lat_sv = s_vtt(6)
		long_sv = s_vtt(7)
		mu_sv = sqrt(1 - s_vtt(11)*s_vtt(11))
;
;		Optionally query user for NOAA number.
		if (qnoaa eq 2) and (imtype eq 'i') then begin
query_noaa:		noaa_sv = ' '
			print
			print, "Middle scan lat,long is "      + $
				stringit(round(lat_sv))  + "," + $
				stringit(round(long_sv)) + "."
			read, "Enter NOAA number, e.g., " + $
				"'quiet' or 'NOAA 8000':  ", noaa_sv
			print, "Read '" + noaa_sv + "'."
			pause, "(r=redo, else accept)", ans=ans
			if ans eq 'r' then goto, query_noaa
			print
		endif
	endif
;
;	Print scan number.
	print, 'SCAN ' + stringit(s_snum) + '...'
;
;	Read scan data.
	if read_sc_data(infile_unit) eq 1 then return
;
;	Select the subset of the desired array.
	case imtype of
	  'i':  im = i(x1:x2, y1:y2)
	  'q':  im = q(x1:x2, y1:y2)
	  'u':  im = u(x1:x2, y1:y2)
	  'v':  im = v(x1:x2, y1:y2)
	endcase
;
;       Optionally subtract off the dark.
        if do_darks then im = im - dark_ary
;
;	Average columns and store in resulting image;
;       optionally multiply by scale vector.
	if nmap eq 1 then begin

		if do_light then begin
			lfactor = light/s_vtt(22)
			image(iscan, *) = avg_col(im) * lfactor
		endif else begin
			image(iscan, *) = avg_col(im)
		endelse

        	if do_darks then image(iscan, *) = image(iscan, *) * scale_vec
	endif else begin

		if do_light then begin
			lfactor = light/s_vtt(22)
			image(iscan, *, imap) = avg_col(im) * lfactor
		endif else begin
			image(iscan, *, imap) = avg_col(im)
		endelse

        	if do_darks then image(iscan, *, imap) = $
			image(iscan, *, imap) * scale_vec
	endelse
;
   endfor
;
endfor
;----------------------------------------------
;
;	Close input file and free unit number.
;
free_lun, infile_unit
;
;	Optionally save information to savefile.
;
if n_elements(savefile) ne 0 then begin
	case imtype of
	  'i':  begin
		  ii = image
		  save, file=savefile, ii, $
			opnum_sv, year_sv, month_sv, day_sv, mu_sv, $
			hour_sv, min_sv, sec_sv, nmstep_sv, mstepsz_sv, $
			lat_sv, long_sv, noaa_sv
		end
	  'q':  begin
		  qq = image
		  save, file=savefile, qq, $
			opnum_sv, year_sv, month_sv, day_sv, mu_sv, $
			hour_sv, min_sv, sec_sv, nmstep_sv, mstepsz_sv, $
			lat_sv, long_sv
		end
	  'u':  begin
		  uu = image
		  save, file=savefile, uu, $
			opnum_sv, year_sv, month_sv, day_sv, mu_sv, $
			hour_sv, min_sv, sec_sv, nmstep_sv, mstepsz_sv, $
			lat_sv, long_sv
		end
	  'v':  begin
		  vv = image
		  save, file=savefile, vv, $
			opnum_sv, year_sv, month_sv, day_sv, mu_sv, $
			hour_sv, min_sv, sec_sv, nmstep_sv, mstepsz_sv, $
			lat_sv, long_sv
		end
	endcase
endif
;
;	Plot to X window.
;
if not keyword_set(noplot) then begin
	if nmap eq 1 then begin
		tvwin, image, /free, title=title
	endif else begin
		for i = 0, nmap-1 do  tvwin, image(*,*,i), /free, $
			title=stringit(i+1)
	endelse
endif
;
;	Done.
;
end

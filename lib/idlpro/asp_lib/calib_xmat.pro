pro calib_xmat, xfiles_a, xlocs, y1, y2, xmats_a, xmats_b, xmats_ab, $
	cameras=cameras
;+
;
;	procedure:  calib_xmat
;
;	purpose:  read in and interpolate X matrices for all positions
;		  along slit (for calibrate.pro)
;
;	author:  rob@ncar, 10/93
;
;	notes:  - file names for 'Camera B' & 'Merged' generated automatically
;		- assume error checking for 'cameras' has been done
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 7 then begin
	print
	print, "usage:  calib_xmat, xfiles_a, xlocs, y1, y2, $"
	print, "		    xmats_a, xmats_b, xmats_ab"
	print
	print, "	Read in and interpolate X matrices for all positions"
	print, "	along slit (for calibrate.pro)."
	print
	print, "	Arguments"
	print, "	    xfiles_a	- X matrix file names for Camera A"
	print, "	    xlocs	- array of corresponding Y locations"
	print, "			  (along slit) of mat's in 'xfiles_a'"
	print, "	    y1, y2	- range along slit to interp Xs for"
	print, "	    xmats_a	- output interp'ed Camera A X matrices"
	print, "	    xmats_b	- output interp'ed Camera B X matrices"
	print, "	    xmats_ab	- output interp'ed Merged   X matrices"
	print
	print, "	Keywords"
	print, "	    cameras	- choice of cameras to process"
	print, "		             'a_only' = process only camera A"
	print, "		             'b_only' = process only camera B"
	print, "		             'both' = process both A & B (def)"
	print
	return
endif
;-
;
;	Set general variables.
;
str = ''
ny = y2 - y1 + 1
n_xmats = sizeof(xfiles_a, 1)
n_xmats1 = n_xmats - 1
;
;	Set up X matrices arrays.
;
x_mat = fltarr(4, 4, /nozero)
if cameras ne 'b_only' then begin
	xmats_a1  = fltarr(n_xmats, 4, 4, /nozero)
	xmats_a  = fltarr(ny, 4, 4, /nozero)
endif
if cameras ne 'a_only' then begin
	xmats_b1  = fltarr(n_xmats, 4, 4, /nozero)
	xmats_b  = fltarr(ny, 4, 4, /nozero)
endif
if cameras eq 'both'   then begin
	xmats_ab1 = fltarr(n_xmats, 4, 4, /nozero)
	xmats_ab = fltarr(ny, 4, 4, /nozero)
endif
;
;	Create file names for 'Camera B' and 'Merged' via string substitution.
;
if cameras ne 'a_only' then begin
	xfiles_b  = xfiles_a
	for i = 0, n_xmats1 do xfiles_b(i)  = strsub( xfiles_a(i), 'a', 'b'  )
endif
if cameras eq 'both' then begin
	xfiles_ab = xfiles_a
	for i = 0, n_xmats1 do xfiles_ab(i) = strsub( xfiles_a(i), 'a', 'ab' )
endif
;
;	Read in X matrices:  Camera A.
;
if cameras ne 'b_only' then $
	for m = 0, n_xmats1 do begin
		openr, unit, xfiles_a(m), /get_lun
		for i = 1, 4 do readf, unit, str
		readf, unit, x_mat
		free_lun, unit
		xmats_a1(m, *, *) = invert(transpose(x_mat))
	endfor
;
;	Read in X matrices:  Camera B.
;
if cameras ne 'a_only' then $
	for m = 0, n_xmats1 do begin
		openr, unit, xfiles_b(m), /get_lun
		for i = 1, 4 do readf, unit, str
		readf, unit, x_mat
		free_lun, unit
		xmats_b1(m, *, *) = invert(transpose(x_mat))
	endfor
;
;	Read in X matrices:  Merged Data.
;
if cameras eq 'both' then $
	for m = 0, n_xmats1 do begin
		openr, unit, xfiles_ab(m), /get_lun
		for i = 1, 4 do readf, unit, str
		readf, unit, x_mat
		free_lun, unit
		xmats_ab1(m, *, *) = invert(transpose(x_mat))
	endfor
;
;	Interpolate X matrices for all positions along slit.
;
if cameras ne 'b_only' then begin
	y_seq = 0
	for y = y1, y2 do begin
		xmats_a( y_seq,  *, *) = interp4x4(xmats_a1,  xlocs, y)
		y_seq = y_seq + 1
	endfor
endif
if cameras ne 'a_only' then begin
	y_seq = 0
	for y = y1, y2 do begin
		xmats_b( y_seq,  *, *) = interp4x4(xmats_b1,  xlocs, y)
		y_seq = y_seq + 1
	endfor
endif
if cameras eq 'both' then begin
	y_seq = 0
	for y = y1, y2 do begin
		xmats_ab(y_seq,  *, *) = interp4x4(xmats_ab1, xlocs, y)
		y_seq = y_seq + 1
	endfor
endif
;
;	Done.
;
end

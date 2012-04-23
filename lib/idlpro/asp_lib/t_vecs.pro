pro t_vecs, ops, xys, tfile, ofile, bandpass
;+
;
;	procedure:  t_vecs
;
;	purpose:  Compute VTT Stokes vectors from a calibrated
;		  ASP ops and t matrix file.  The output file
;		  is in a format suitable for input to 'xttx.f'.
;		  'xttx.f' then computes a new t matrix file.
;
;	author:  paul@ncar, 10/94	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	t_vecs, ops, xys, tfile, ofile [, bandpass]"
	print
	print,"		Compute VTT Stokes vectors from a calibrated"
	print,"		ASP ops and t matrix file.  The output file"
	print,"		is in a format suitable for input to 'xttx.f'."
	print,"		'xttx.f' then computes a new t matrix file."
	print
	print, "	Arguments (all input)"
	print, "		ops	- string vector with paths to"
	print, "			  ASP ops"
	print, "		xys	- array (first dimension 2)"
	print, "			  with one [x,y] location for"
	print, "			  each file in ops above"
	print, "		tfile	- string path to file with"
	print, "			  t matrix info"
	print, "		ofile	- string path to output file"
	print, "		bandpass - array across wavelength"
	print, "			  space; non zero for vectors"
	print, "			  to output"
	print, "	Example:"
	pause
	print, "		;"
	print, "		;Set paths to calibrated ASP ops."
	print, "		;"
	print, "		ops = $"
	print, "		[ '/swing/d/94.05.17/op02/02.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op04/04.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op06/06.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op07/07.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op10/10.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op13/13.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op14/14.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op19/19.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op21/21.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op23/23.fab.spotctr' $"
	print, "		, '/swing/d/94.05.17/op29/29.fab.spotctr' $"
	print, "		]"
	pause
	print, "		;"
	print, "		;Select one raster point from each"
	print, "		;ASP op above.  This selection is"
	print, "		;done elsewhere and base on points"
	print, "		;that have no linear polarization."
	print, "		;"
	print, "		xys = $"
	print, "		[ [88,120] $"
	print, "		, [66,118] $"
	print, "		, [66,119] $"
	print, "		, [85,120] $"
	print, "		, [85,120] $"
	print, "		, [71,105] $"
	print, "		, [74,100] $"
	print, "		, [71,105] $"
	print, "		, [66,105] $"
	print, "		, [70,109] $"
	print, "		, [31,117] $"
	print, "		]"
	pause
	print, "		;"
	print, "		;Path to t matrix info that was"
	print, "		;used to calibrate the ops above."
	print, "		;"
	print, "		tfile = $"
	print, "		'/swing/d/94.05.17/xxxx/part_3.6302los10'"
	print, "		;"
	print, "		;Path to output file.  This file"
	print, "		;will be suitable for input to"
	print, "		;program xttx.f"
	print, "		;"
	print, "		ofile = $"
	print, "		'/hilo/d/asp/data/red/94.05.17/tinv_cal'"
	print, "		;"
	print, "		;Set band pass array."
	print, "		;"
	print, "		bandpass = lonarr(256)"
	print, "		bandpass(30:70) = 1"
	print, "		bandpass(110:140) = 1"
	print, "		;"
	print, "		;Compute VTT telescope vectors."
	print, "		;"
	print, "		t_vecs, ops, xys, tfile, ofile, bandpass"
	return
endif
;-
				    ;Specify common blocks.
@op_hdr.com
@scan_hdr.com
				    ;Get number of files.
size_ops = size(ops)
size_xys = size(xys)
nops     = size_ops(1)
nxys     = size_xys(2)

if nops ne nxys then begin
	print, 'tvecs.pro: ops & xys array size differ'
	print, '.c to continue'
	stop
	return
end
				    ;Open output file.
				    ;Print blank header line.
openw, /get_lun, unit, ofile
printf, unit
				    ;Loop over input files.
for nf=0,nops-1 do begin
				    ;Read 0th scan of sequence.
	readscan, ops(nf), 0, i, q, u, v, /nohead

				    ;Number of 0th scan in sequence. 
	n0th = s_snum
				    ;Read scan x, profile set y.
	readscan, ops(nf), xys(0,nf)-n0th, i, q, u, v $
	, y1=xys(1,nf), y2=xys(1,nf), /nohead

				    ;Form array of calibrated Stokes
				    ;vectors.
	size_i = size(i)
	isize  = size_i(1)
	svecs =fltarr(4,isize)
	svecs(0,*) = i
	svecs(1,*) = q
	svecs(2,*) = u
	svecs(3,*) = v
				    ;VTT azimuth, elevation, table angle.
	vttaz  = s_vtt(0)
	vttel  = s_vtt(1)
	tblpos = s_vtt(2)

	if nf eq 0 then print,'SCAN    VTTAZ      VTTEL      TBLPOS'
	print, format='(i4,3f11.5)', s_snum, vttaz, vttel, tblpos

				    ;Get VTT matrix.
	t = get_t( 0, vttaz, vttel, tblpos, tfile )

				    ;Compute telescope vectors
				    ;(Multiply calibrated vectors
				    ;by t matrix).
	svecs = t # svecs
				    ;Determine band pass.
	if n_elements(bandpass) eq 0 $
	then  bpass = replicate(1L,isize) $
	else  bpass = bandpass ne 0
				    ;Match wavelength space to band pass.
	size_bpass = size(bpass)
	pixels = isize < size_bpass(1)

				    ;Output Stokes vectors.
	for w=0,pixels-1 do begin
	if bpass(w) then begin
		printf, unit, format='(a,3f10.3)' $
		, '1000', vttel, vttaz, tblpos
		printf, unit, format='(4f10.3)' $
		, svecs(*,w)
	end
	end
end
				    ;Close output file.
free_lun, unit

end

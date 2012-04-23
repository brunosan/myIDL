pro pf_plot_usage
;+
;
;	procedure:  pf_plot
;
;	purpose:  plot profiles in a *.pf file
;
;	routines:  pf_plot_usage  pf_single  pf_plot
;
;	author:  paul@ncar, 9/94	(minor mod's by rob@ncar)
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	pf_plot [, dir]"
	print
	print, "	Plot profiles in a *.pf file"
	print
	print, "	Arguments"
	print, "		dir	- input directory path (string;"
	print, "			  def = use current working directory)"
	print, "	Keyword"
	print, "		path	- path to file (string;"
	print, "			  def = dir+'/*.pf' )"
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	procedure:  pf_single
;
;	purpose:  plot one stokes component.
;
;------------------------------------------------------------------------------
pro pf_single, pf, title, sobs, sclc, imag, band, xll, yll

				    ;Open hidden pixmap window.
wset, pf.w0
				    ;Check for zero array.
if pf.mx eq 0. then begin
	erase, !d.n_colors-1
	if pf.w1 ne pf.w0 then begin
		wset, pf.w1
		device, copy=[0,0,pf.xsz,pf.ysz,xll,yll,pf.w0]
	end
	return
end
				    ;Initialize plot grid.
plot, [0,pf.np], [pf.mn,pf.mx], /nodata, title=title $
, color=0 , background=!d.n_colors-1

				    ;Plot centers.
for i=0,2 do begin
	if pf.c0(i) ne 0 then begin
		del = .05*(pf.mx-pf.mn)
		plots, [pf.cn(i),pf.cn(i)], [pf.mn+del,pf.mx-del], color=0
		del = .04*(pf.mx-pf.mn)
		plots, [pf.c0(i),pf.c0(i)], [pf.mn,pf.mn+del], color=0
		plots, [pf.c0(i),pf.c0(i)], [pf.mx,pf.mx-del], color=0
	end
end
				    ;Form array for xaxis.
				    ;Use fortran values.
vecx = findgen(pf.np)+1

				    ;Plot fitted arrays.
plots, vecx, sclc, color=0
if n_elements(imag) ne 0 then plots, vecx, imag, color=0

				    ;Set cross size.
csize = 4.
xcross = (csize*pf.np)/pf.xsz
ycross = (csize*(pf.mx-pf.mn))/pf.ysz

				    ;Plot data array.
for i = 0,pf.np-1 do begin
	x = i+1
	y = sobs(i)
	xcrs = xcross
	ycrs = ycross
	if band(i) eq 0. then begin
		xcrs = xcross/3
		ycrs = ycross/3
	end
	plots, [x-xcrs,x+xcrs], [y,y], color=0
	plots, [x,x], [y-ycrs,y+ycrs], color=0
end
				    ;Copy plot to display.
if pf.w1 ne pf.w0 then begin
	wset, pf.w1
	device, copy=[0,0,pf.xsz,pf.ysz,xll,yll,pf.w0]
end

end
;------------------------------------------------------------------------------
;
;	procedure:  pf_plot
;
;	purpose:  plot profiles in a *.pf file
;
;------------------------------------------------------------------------------
pro pf_plot, dir, dummy, path=path
				    ;Check number of parameters.
if n_params() gt 1 then begin
	pf_plot_usage
	return
end
				    ;Size of window to fill screen.
xfull = 1144L
yfull = 868L
				    ;Initialize pf structure.
pf = $
{ xsz:		xfull*3/8 $
, ysz:		yfull*3/8 $
, w0:		0L $
, w1:		0L $
, np:		0L $
, mn:		0. $
, mx:		0. $
, cn:		[0.,0.,0.] $
, c0:		[0.,0.,0.] $
, disper:	0. $
, dty:		'' $
}
				    ;Append directory name with / 
if n_elements(dir) ne 0 then  pf.dty = dir
if pf.dty ne '' then $
if strmid(pf.dty,strlen(pf.dty)-1,1) ne '/' then  pf.dty=pf.dty+'/'

				    ;Set file path.
pth = pf.dty+'*.pf'
if  n_elements(path) ne 0  then  pth=path
print, pth
				    ;Open pf file.
openr, /get_lun, unit, pth, error=error
if  error ne 0  then begin
	print, !err_string
	print, '*.pf files may not exit or wrong directroy'
	return
end
				    ;Open windows for ploting.
window, /free, xsize=pf.xsz, ysize=pf.ysz, /pixmap
pf.w0 = !d.window
window, /free, xsize=2*pf.xsz, ysize=2*pf.ysz $
, xpos=1144-2*pf.xsz, ypos=900-2*pf.ysz $
, title='Click: left(continue), middle(magnify), right(stop)'
pf.w1 = !d.window
				    ;Zero the file pointer.
now_lun = 0
				    ;Loop over asp raster point.
while 1 do begin
				    ;Read next spectra set.
	pf_next_in, unit, endfile, qualify $
	, xp, yp, rgt, dec, ut, mdy $
	, cct, fld, azm, psi $
	, disper $
	, wv, cn, c0 $
	, np $
	, iobs, qobs, uobs, vobs $
	, iclc $
	, imag, qclc, uclc, vclc $
	, band
				    ;Read header and check for end_file.
	if endfile or (qualify eq 0) then  goto, e_x_i_t

				    ;Set some info in structure.
	pf.np     = np
	pf.cn     = cn
	pf.c0     = c0
	pf.disper = disper
				    ;Plot I arrays.
	imx = max( [iobs,imag,iclc,0.], min=imn )
	pf.mx = imx  &  pf.mn = imn
	pf_single, pf, 'I', iobs, iclc, imag, band, 0, pf.ysz

				    ;Plot Q & U arrays.
	qmx = max( abs([qobs,qclc,uobs,uclc]) )
	pf.mx = qmx  &  pf.mn = -qmx
	pf_single, pf, 'Q', qobs, qclc, undef, band, pf.xsz, pf.ysz
	pf_single, pf, 'U', uobs, uclc, undef, band,      0,      0

				    ;Plot V arrays.
	vmx = max( abs([vobs,vclc]) )
	pf.mx = vmx  &  pf.mn = -vmx
	pf_single, pf, 'V', vobs, vclc, undef, band, pf.xsz, 0

				    ;Print (x,y) coordinates.
	wset,pf.w1
	xyouts, pf.xsz, pf.ysz $
	, strcompress( /remove_all $
	, string('(',xp,',', yp,')') ) $
	, align=0.5, color=0, /device, charsize=2

				    ;Loop on magnified windows.
	state = 0
	while state ne 1 do begin
				    ;Get cursor condition.
		wset,pf.w1  &  cursor, xxxx, yyyy, /device, wait=3
		state = !err
		if state eq 4 then  goto, e_x_i_t

				    ;Check for magnified image.
		if state eq 2 then begin

				    ;Open full screen window.
			window, /free, xsize=xfull, ysize=yfull $
			, xpos=1144-xfull, ypos=900-yfull $
			, title='Click to Continue'

				    ;Initialize mg structure.
			mg = pf
			mg.xsz = xfull
			mg.ysz = yfull
			mg.w0 = !d.window
			mg.w1 = !d.window

				    ;Select plot from cursor position.
			x=xxxx/pf.xsz
			y=yyyy/pf.ysz
			if qmx eq 0. and vmx eq 0. then begin
				x = 0
				y = 1
			end

			case 1 of
				    ;Plot I arrays.
			(x eq 0) and y: begin
				mg.mx = imx  &  mg.mn = imn
				pf_single, mg, 'I', iobs,iclc,imag,band, 0,0
				end
				    ;Plot Q arrays.
			x and y: begin
				mg.mx = qmx  &  mg.mn = -qmx
				pf_single, mg, 'Q', qobs,qclc,undef,band, 0,0
				end
				    ;Plot U arrays.
			(x eq 0) and (y eq 0): begin
				mg.mx = qmx  &  mg.mn = -qmx
				pf_single, mg, 'U', uobs,uclc,undef,band, 0,0
				end
				    ;Plot V arrays.
			x and (y eq 0): begin
				mg.mx = vmx  &  mg.mn = -vmx
				pf_single, mg, 'V', vobs,vclc,undef,band, 0,0
				end
			else:
			end
				    ;Wait for click on window and delete.
			wset,mg.w1  &  cursor, xxxx, yyyy, /device, wait=3
			wdelete, mg.w1
		end

	end
end
				    ;Close file and delete window.
e_x_i_t:
free_lun, unit
wdelete, pf.w0, pf.w1

end

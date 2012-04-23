pro pf_ps_usage
;+
;
;	procedure:  pf_ps
;
;	purpose:  plot profiles in a *.pf file to PostScript.
;
;	routines:  pf_ps_usage  plo_  xyo_  dot_ strfmt  ps_plot  pf_ps
;
;	author:  paul@ncar, 9/94	(minor mod's by rob@ncar)
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	pf_ps [, dir]"
	print
	print, "	Plot profiles in a *.pf file to PostScript"
	print
	print, "	Arguments"
	print, "		dir	- input directory path (string;"
	print, "			  def = use current working directory)"
	print, "	Keyword"
	print, "		path	- path to file (string;"
	print, "			  def = dir+'/*.pf' )"
	print, "		band	- Angstroms to plot"
	print, "			  (def = .82 )"
	print, "		scat	- set to plot scat light profile"
	print, "			  (def: do not plot scat light )"
	print, "		x	- x raster point value or range"
	print, "			  (integer or dimension 2 array;"
	print, "			  def: plot full x range )"
	print, "		y	- y raster point value or range"
	print, "			  (integer or dimension 2 array;"
	print, "			  def: plot full y range )"
	print, "examples:"
	print, "		;plot point (110,112) in *.pf"
	print, "	pf_ps, x=110, y=112"
	print
	print, "		;plot points x=110 y=112,113,114 in *.pf"
	print, "	pf_ps, x=110, y=[112,114]"
	print
	print, "		;plot point (110,112) in op07/*.pf"
	print, "	pf_ps, 'op07', x=110, y=112"
	print
	print, "		;plot point (110,112) in op07/pf_sav"
	print, "	pf_ps, path='op07/pf_sav', x=110, y=112"
	print
	print, "		;plot scat light & all points in *.pf"
	print, "	pf_ps, /scat"
	print
	print, "		;plot scat light only in *.pf"
	print, "	pf_ps, /scat, x=-1"
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	procedure: plo_
;
;	purpose: scale vectors to normal coordinates and output with plots.
;
;------------------------------------------------------------------------------
pro plo_, ps, x, y, color=color, thick=thick

if n_elements(color) eq 0 then    color = 0
if n_elements(thick) eq 0 then    thick = !p.thick

plots, /normal, x/ps.xdev, y/ps.ydev, color=color, thick=thick

end
;------------------------------------------------------------------------------
;
;	procedure: xyo_
;
;	purpose: scale normal coordinates and output string with xyouts.
;
;------------------------------------------------------------------------------
pro xyo_, ps, x, y, s $
, color=color, charsize=charsize, align=align, orient=orient

if n_elements(orient  ) eq 0 then   orient = 0.
if n_elements(color   ) eq 0 then    color = 0
if n_elements(charsize) eq 0 then charsize = 1.

xyouts, /normal, x/ps.xdev, y/ps.ydev, s $
, color=color, charsize=charsize, align=align, orient=orient

end
;------------------------------------------------------------------------------
;
;	procedure: dot_
;
;	purpose: output a dot at position (x,y).
;
;------------------------------------------------------------------------------
pro dot_, ps, x, y, radius, color=color

common dot_com, snn, cnn
if n_elements(snn) eq 0 then begin
	tmp = !pi*findgen(13)/6.
	snn = [ 0.,sin(tmp)]
	cnn = [-1.,cos(tmp)]
end

plo_, ps, x+radius*cnn, y+radius*snn, color=color

end
;------------------------------------------------------------------------------
;
;	function: strfmt
;
;	purpose: format number in a string.
;
;------------------------------------------------------------------------------
function strfmt, x, fmt

if x eq 0 then  return, '0'

cccc = strcompress( string(x,format=fmt),/remove_all)

if strmid(cccc,0,2) eq '0.' then  return,  strmid(cccc,1,100) 
if strmid(cccc,0,3) eq '-0.' then  return,  '-'+strmid(cccc,2,100) 

return, cccc

end
;------------------------------------------------------------------------------
;
;	procedure:  ps_plot
;
;	purpose:  plot one stokes component.
;
;------------------------------------------------------------------------------
pro ps_plot, ps, title, sobs, sclc, imag, band, xll, yll

				    ;Check for zero array.
if ps.mx eq 0. then return
				    ;Plot box.
plo_, ps, color=0 $
, ps.xorg+[ 0., 0., ps.sze, ps.sze, 0. ] $
, ps.yorg+[ 0., ps.sze, ps.sze, 0., 0. ]

				    ;Alow .02 y azis boundary.
ymin = ps.mn-.02*(ps.mx-ps.mn)
ymax = ps.mx+.02*(ps.mx-ps.mn)
yrange = ymax-ymin
				    ;Character size factor.
csz = 1.2
				    ;Half character height, inches.
hlfc = .05*csz
				    ;Left margin for printing numbers.
cleft = ps.xorg-.01*ps.sze
				    ;Mark y azis scale.
if yrange lt 0.000001 then begin

	if ymin le 0. and ymax ge 0. then begin
		yy = ps.yorg-(ymin/yrange)*ps.sze
		plo_, ps, color=0, ps.xorg+[0.,.02*ps.sze], yy
		plo_, ps, color=0, ps.xorg+ps.sze+[-.02*ps.sze,0.], yy
		xyo_, ps, cleft, yy, '0' $
		, color=0, align=0.5, charsize=csz, orient=90.
	end

	yy = ps.yorg+(ps.mn-ymin)/yrange*ps.sze
	plo_, ps, color=0, ps.xorg+[0.,.02*ps.sze], yy
	plo_, ps, color=0, ps.xorg+ps.sze+[-.02*ps.sze,0.], yy
	xyo_, ps, cleft, yy, strfmt(ps.mn,'(e16.2)') $
	, color=0, align=0.0, charsize=csz, orient=90.

	yy = ps.yorg+(ps.mx-ymin)/yrange*ps.sze
	plo_, ps, color=0, ps.xorg+[0.,.02*ps.sze], yy
	plo_, ps, color=0, ps.xorg+ps.sze+[-.02*ps.sze,0.], yy
	xyo_, ps, cleft, yy, strfmt(ps.mx,'(e16.2)') $
	, color=0, align=1.0, charsize=csz, orient=90.

end else begin

	ifac = 1L
	while  yrange*ifac lt 4. do ifac=10*ifac

				    ;Set format for y axis numbers.
	case 1 of
	ifac eq 10L: fmt='(f16.1)'
	ifac eq 100L: fmt='(f16.2)'
	ifac eq 1000L: fmt='(f16.3)'
	ifac eq 10000L: fmt='(f16.4)'
	ifac eq 100000L: fmt='(f16.5)'
	ifac eq 1000000L: fmt='(f16.6)'
	else: fmt='(e16.1)'
	end

	jj = long(ymin*ifac)
	kk = long(ymax*ifac)
	if jj lt ymin*ifac then jj=jj+1

	istep = 1 > (((kk-jj)+2)/4)
	if (title eq 'I') and (istep eq 3) then istep = 2

	for ii = jj,kk do begin

		yy = (1.*ii)/ifac
		yi = ps.yorg+(yy-ymin)/yrange*ps.sze

				    ;Draw y axis tick marks
		plo_, ps, color=0, ps.xorg+[0.,.02*ps.sze], yi
		plo_, ps, color=0, ps.xorg+ps.sze+[-.02*ps.sze,0.], yi

				    ;Print y azis number.
		if (ii mod istep) eq 0 then $
		xyo_, ps, cleft, yi-hlfc, strfmt(yy,fmt) $
		, color=0, align=1.0, charsize=csz
	end
end
				    ;Reorder centers.
tmp0 = ps.c0
cmx = max(tmp0,i0)
n0 = 0
c0 = [ ps.c0(i0) ]
cn = [ ps.cn(i0) ]
wv = [ ps.wv(i0) ]
lo = [        1. ]
hi = [  1.*ps.np ]
tmp0(i0) = 0.
				    ;Check for second specta line.
if max(tmp0,i1) ne 0. then begin
	n0 = 1
	c0 = [        ps.c0(i1),        ps.c0(i0) ]
	cn = [        ps.cn(i1),        ps.cn(i0) ]
	wv = [        ps.wv(i1),        ps.wv(i0) ]
	lo = [               1., (c0(0)+c0(1))/2. ]
	hi = [ (c0(0)+c0(1))/2.,         ps.np  ]
	tmp0(i1) = 0.
				    ;Check for third specta line.
	if max(tmp0,i2) ne 0. then begin
		n0 = 2
		c0 = [        ps.c0(i2),        ps.c0(i1),        ps.c0(i0) ]
		cn = [        ps.cn(i2),        ps.cn(i1),        ps.cn(i0) ]
		wv = [        ps.wv(i2),        ps.wv(i1),        ps.wv(i0) ]
		lo = [               1., (c0(0)+c0(1))/2., (c0(1)+c0(2))/2. ]
		hi = [ (c0(0)+c0(1))/2., (c0(1)+c0(2))/2.,         ps.np  ]
	end
end
				    ;Reset lo and hi limits to half width.
lo = lo > (c0-.5*ps.bwdth*1000./ps.disper)
hi = hi < (c0+.5*ps.bwdth*1000./ps.disper)

				    ;Total pixels to plot.
tot = total(hi-lo)
				    ;Loop through line plots.
x1 = 0.
for sl=0,n0 do begin
				    ;Left center right to plot line.
	x0 = x1
	xc = x0+(c0(sl)-lo(sl))*ps.sze/tot
	x1 = x0+(hi(sl)-lo(sl))*ps.sze/tot

				    ;Left and right pixel to plot
	i0 = round(lo(sl))  &  if i0 lt lo(sl) then i0=i0+1
	i1 = round(hi(sl))  &  if i1 gt hi(sl) then i1=i1-1

				    ;Form ramp for x azis.
	xvec = (i0-lo(sl))+findgen(i1-i0+1)
	xvec = x0+xvec*ps.sze/tot
				    ;Form calculated spectra vector.
	yvec = (sclc(i0-1:i1-1)-ymin)*ps.sze/(ymax-ymin)

				    ;Plot calculated spectra vector.
	plo_, ps, color=0, ps.xorg+xvec, ps.yorg+yvec

				    ;Plot I magnetic.
	if n_elements(imag) ne 0 then begin
		yvec = (imag(i0-1:i1-1)-ymin)*ps.sze/(ymax-ymin)
		plo_, ps, color=0, ps.xorg+xvec, ps.yorg+yvec
	end
				    ;Plot calculated center.
	plo_, ps, color=0, ps.xorg+x0+(cn(sl)-lo(sl))*ps.sze/tot $
	, ps.yorg+[.05,.95]*ps.sze, thick=.5*!p.thick

				    ;Plot observed data with dots.
	bvec =  band(i0-1:i1-1)
	yvec = (sobs(i0-1:i1-1)-ymin)*ps.sze/(ymax-ymin)
	for i=0,i1-i0 do begin
		radius = 0.019
		if bvec(i) eq 0. then radius=.5*radius
		dot_, ps, ps.xorg+xvec(i), ps.yorg+yvec(i), radius, color=0
	end
				    ;Plot right side of line box.
	if sl ne n0 then $
	plo_, ps, color=0, ps.xorg+x1, ps.yorg+[0.,ps.sze]

				    ;Print title.
	xyo_, ps, ps.xorg+3./16., ps.yorg+3./16., title $
	, align=0.0, charsize=1.6
				    ;Spacing for x axis numbers, mA.
	;;;;;;;;istep = long(min(hi-lo)*ps.disper/2.5)
	istep = long((hi(sl)-lo(sl))*ps.disper/2.5)
	istep = 100 > ((istep/100)*100)

				    ;x axis range, mA.
	xmin = (lo(sl)-c0(sl))*ps.disper
	xmax = (hi(sl)-c0(sl))*ps.disper

				    ;Print wavelength, NM.
	xyo_, ps, ps.xorg+xc, ps.yorg-19./32., strfmt(.1*wv(sl),'(f8.2)') $
	, align=0.5, charsize=csz

	jj = round(xmin/100)*100  &  if jj lt xmin then jj = jj+100
	kk = round(xmax/100)*100  &  if kk gt xmax then kk = kk-100

	for ii=jj,kk,100 do begin

		xx = ps.xorg+xc+(ii/ps.disper)*(ps.sze/tot)

		if (ii mod istep) eq 0 then begin

				    ;Draw x axis tick marks
			plo_, ps, color=0, xx, ps.yorg+[0.,.025*ps.sze]
			plo_, ps, color=0, xx, ps.yorg+ps.sze+[-.025*ps.sze,0.]

				    ;Print NM scale.
			if sl mod 2 then  yoff=3./16.  else  yoff=3./8.
			xyo_, ps, xx, ps.yorg-yoff $
			, strfmt(.0001*ii,'(f8.2)') $
			, align=0.5, charsize=csz

		end else begin
				    ;Draw x axis tick marks
			plo_, ps, color=0, xx, ps.yorg+[0.,.0175*ps.sze]
			plo_, ps, color=0, xx, ps.yorg+ps.sze+[-.0175*ps.sze,0.]
		end
	end
end

end
;------------------------------------------------------------------------------
;
;	procedure:  pf_ps
;
;	purpose:  plot profiles in a *.pf to PostScript files.
;
;------------------------------------------------------------------------------
pro pf_ps, dir, dummy, path=path, band=band, scat=scat, x=xrange, y=yrange
				    ;Check number of parameters.
if n_params() gt 1 then begin
	pf_ps_usage
	return
end
				    ;Call tvasp to set color table.
@tvasp.com
tvasp, /notv, indgen(2,2)
				    ;Save active window.
				    ;Save font info.
				    ;Save plots line thickness.
				    ;Set plots line thickness.
				    ;Select hardware font.
				    ;Set PostScript device.
w_sav = !d.window
sav_p_font  = !p.font
sav_p_thick = !p.thick
!p.thick    = 5.
!p.font     = 0
set_plot, 'ps'
				    ;PostScript device size in inches.
xdev = 8.5
ydev = 11.
				    ;Left and bottom margin.
mrg_lft = 1.25
mrg_btm = 2.5
				    ;Plot size for one stokes component.
sze = 2.+13./16.
				    ;Spacing between plots.
spc = 3./4.
				    ;Spectra band width to plot (A).
if n_elements(band) eq 0 $
then  bwdth = .82 $
else  bwdth = band
				    ;Initialize pf structure.
ps = $
{ xdev:		xdev $
, ydev:		ydev $
, mrg_lft:	mrg_lft $
, mrg_btm:	mrg_btm $
, sze:		sze $
, spc:		spc $
, xorg:		0. $
, yorg:		0. $
, cct:		0. $
, disper:	0. $
, mn:		0. $
, mx:		0. $
, wv:		[0.,0.,0.] $
, cn:		[0.,0.,0.] $
, c0:		[0.,0.,0.] $
, np:		0L $
, bwdth:	bwdth $
, dty:		'' $
}
				    ;Append directory name with / 
if n_elements(dir) ne 0 then  ps.dty = dir
if ps.dty ne '' then $
if strmid(ps.dty,strlen(ps.dty)-1,1) ne '/' then  ps.dty=ps.dty+'/'

				    ;Set file path.
pth = ps.dty+'*.pf'
if  n_elements(path) ne 0  then  pth=path

				    ;Open pf file.
openr, /get_lun, unit, pth, error=error
if  error ne 0  then begin
	print, !err_string
	print, '*.pf files may not exit or wrong directroy'
	return
end
				    ;Get 2D file pointer map.
pf_xy_map, unit, map, xwhr, ywhr, nxy, ptr_scat

				    ;Plot Scattered light if present and
				    ;requested.
if  ptr_scat ne -1         then $
if  n_elements(scat) ne 0  then $
if  scat ne 0              then begin

				    ;Set file pointer.
	point_lun, unit, ptr_scat
				    ;Read next profile set from pf file.
	pf_next_in, unit, endfile, qualify $
	, xp, yp, rgt, dec, ut, hms $
	, cct, fld, azm, psi $
	, disper $
	, wv, cn, c0 $
	, np $
	, iobs, qobs, uobs, vobs $
	, iclc $
	, imag, qclc, uclc, vclc $
	, band
				    ;Check for endfile or file did not qualify.
	if endfile or (qualify eq 0) then  goto, e_x_i_t

				    ;Save some info in structure.
	ps.cct    = cct
	ps.wv     = wv
	ps.cn     = cn
	ps.c0     = c0
	ps.disper = disper
	ps.np     = np
				    ;Normalize to continuum.
	iobs = iobs/cct
	iclc = iclc/cct
				    ;Open PostScript file.
	device, bits_per_pixel=8, /inches, file='scat_pf.ps' $
	, xoffset=0., yoffset=0., /portrait $
	, xsize=8.5, ysize=11. $
	, color=1, /times, /bold
				    ;Plot I arrays.
	imx = max( [iobs,iclc,0.], min=imn )
	ps.mx = imx  &  ps.mn = imn
	ps.xorg = ps.mrg_lft
	ps.yorg = ps.mrg_btm+ps.sze+ps.spc
	ps_plot, ps, 'I', iobs, iclc, undef, band

				    ;Close PostScript file.
	device, /close_file
end
				    ;Check if raster points are present.
if nxy eq 0 then goto, e_x_i_t
				    ;Set x y raster point ranges.
case n_elements(xrange) of
0:	xrng = [0,max(xwhr)]
1:	xrng = round([xrange,xrange])
else:	xrng = round([min(xrange(0:1)),max(xrange(0:1))])
end

case n_elements(yrange) of
0:	yrng = [0,max(ywhr)]
1:	yrng = round([yrange,yrange])
else:	yrng = round([min(yrange(0:1)),max(yrange(0:1))])
end
				    ;Loop over asp raster point.
for ixy=0,nxy-1 do begin
if   xwhr(ixy) ge xrng(0)  and  xwhr(ixy) le xrng(1) $
and  ywhr(ixy) ge yrng(0)  and  ywhr(ixy) le yrng(1) then begin

				    ;Set file pointer.
	point_lun, unit, map(ixy)
				    ;Read next profile set from pf file.
	pf_next_in, unit, endfile, qualify $
	, xp, yp, rgt, dec, ut, hms $
	, cct, fld, azm, psi $
	, disper $
	, wv, cn, c0 $
	, np $
	, iobs, qobs, uobs, vobs $
	, iclc $
	, imag, qclc, uclc, vclc $
	, band
				    ;Check for endfile or file did not qualify.
	if endfile or (qualify eq 0) then  goto, e_x_i_t

				    ;Save some info in structure.
	ps.cct    = cct
	ps.wv     = wv
	ps.cn     = cn
	ps.c0     = c0
	ps.disper = disper
	ps.np     = np
				    ;Normalize to continuum.
	iobs = iobs/cct  &  iclc = iclc/cct
	qobs = qobs/cct  &  qclc = qclc/cct
	uobs = uobs/cct  &  uclc = uclc/cct
	vobs = vobs/cct  &  vclc = vclc/cct
	imag = imag/cct
				    ;Open PostScript file.
	device, bits_per_pixel=8, /inches $
	, file=strcompress(/remove_all,string(xp)+'_'+string(yp)+'_pf.ps') $
	, xoffset=0., yoffset=0., /portrait $
	, xsize=8.5, ysize=11. $
	, color=1, /times, /bold
				    ;Plot I arrays.
	imx = max( [iobs,imag,iclc,0.], min=imn )
	ps.mx = imx  &  ps.mn = imn
	ps.xorg = ps.mrg_lft
	ps.yorg = ps.mrg_btm+ps.sze+ps.spc
	ps_plot, ps, 'I', iobs, iclc, imag, band

				    ;Q & U range.
	qmx = max( abs([qobs,qclc,uobs,uclc]) )
	ps.mx = qmx  &  ps.mn = -qmx

				    ;Plot Q arrays.
	ps.xorg = ps.mrg_lft+ps.sze+ps.spc
	ps.yorg = ps.mrg_btm+ps.sze+ps.spc
	ps_plot, ps, 'Q', qobs, qclc, undef, band

				    ;Plot U arrays.
	ps.xorg = ps.mrg_lft
	ps.yorg = ps.mrg_btm
	ps_plot, ps, 'U', uobs, uclc, undef, band

				    ;Plot V arrays.
	vmx = max( abs([vobs,vclc]) )
	ps.mx = vmx  &  ps.mn = -vmx
	ps.xorg = ps.mrg_lft+ps.sze+ps.spc
	ps.yorg = ps.mrg_btm
	ps_plot, ps, 'V', vobs, vclc, undef, band

				    ;Plot point number.
	xyo_, ps, align=1.0, charsize=.75 $
	, ps.mrg_lft+ps.sze+ps.spc+ps.sze $
	, ps.mrg_btm+ps.sze+ps.spc+ps.sze+1./16. $
	, strcompress(string(xp,yp))

				    ;Close PostScript file.
	device, /close_file
end
end
				    ;Close *.pf file.
e_x_i_t:
free_lun, unit
				    ;Return to X windows.
				    ;Restore old font setting.
				    ;Restore active window.
set_plot, 'x'
!p.thick = sav_p_thick
!p.font  = sav_p_font
if w_sav gt -1 then  wset, w_sav

end

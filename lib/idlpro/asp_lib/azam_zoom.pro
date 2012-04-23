pro azam_zoom, aa, umbra, laluz, arrow
;+
;
;	procedure:  azam_zoom
;
;	purpose:  zoom portion of an azam op.
;
;	author:  paul@ncar, 8/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:	azam_zoom, aa, umbra, laluz, arrow"
	print
	print, "	Compute an azam structure for an ASP op and display"
	print, "	window."
	print
	print, "	Arguments"
	print, "		aa	- input/output azam data structure"
	print, "		umbra	- input umbra hi light"
	print, "		laluz	- input set equal to umbra"
	print, "		arrow	- input arrow point structure"
	print
	return
endif
;-
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
				    ;Special tvasp colors.
				    ;
white  = aa.white
yellow = aa.yellow
red    = aa.red
black  = aa.black
				    ;
				    ;Prompt for area center.
				    ;
azam_click_xy, aa, 'Click on center of area.', xctr, yctr
				    ;
				    ;Set magnification factor.
				    ;
t = 6L
				    ;
				    ;Size original area to fit on screen.
				    ;
xsz = 530L/t
ysz = 780L/t
				    ;
				    ;Set zoom image bounds.
				    ;
xx0 = 0 > ( (xctr-xsz/2) < (aa.xdim-xsz) )
yy0 = 0 > ( (yctr-ysz/2) < (aa.ydim-ysz) )
xx1 = (xx0+xsz) < (aa.xdim-1)
yy1 = (yy0+ysz) < (aa.ydim-1)
xdim = xx1-xx0+1
ydim = yy1-yy0+1
				    ;
				    ;Sub area of already magnified images.
				    ;
tx0 = aa.t*xx0
ty0 = aa.t*yy0
tx1 = aa.t*xx1+aa.t-1
ty1 = aa.t*yy1+aa.t-1
				    ;Set some display parameters.
rmg = aa.rmg
				    ;Form where there is data in sub arrays.
tmp0 = lonarr(aa.xdim,aa.ydim)
tmp0(aa.pxy) = 1
tmp0 = tmp0(xx0:xx1,yy0:yy1)
npxy = total(tmp0)
				    ;
tmp1 = lonarr(aa.xdim,aa.ydim)
tmp1(aa.sxy) = 1
tmp1 = tmp1(xx0:xx1,yy0:yy1)
nsxy = total(tmp1)
				    ;
				    ;Create azam sub structure.
				    ;
az = $
{ index:	3L $
, stretch:	aa.stretch $
, angxloc:	aa.angxloc $
, npoints:	aa.npoints $
, nsolved:	aa.nsolved $
, xdim:		xdim $
, ydim:		ydim $
, pxy:		where(tmp0) $
, sxy:		where(tmp1) $
, op:		aa.op $
, head:		aa.head $
, win0:		0L $
, win1:		0L $
, wina:		aa.wina $
, winb:		aa.winb $
, bx:		-1L $
, by:		-1L $
, bs:		0L $
, white:	aa.white $
, yellow:	aa.yellow $
, red:		aa.red $
, black:	aa.black $
, cen_lat:	aa.cen_lat $
, cen_e_w:	aa.cen_e_w $
, mxfld:	aa.mxfld $
, pix_deg:	aa.pix_deg $
, mm_per_deg:   aa.mm_per_deg $
, zoom:		1L $
, x0:		xx0 $
, y0:		yy0 $
, xy5000:	aa.xy5000( xx0:xx1,yy0:yy1) $
, umb_lvl:	aa.umb_lvl $
, b__cct:	aa.b__cct( xx0:xx1,yy0:yy1) $
, b_fld:	aa.b_fld(  xx0:xx1,yy0:yy1) $
, b_azm:	aa.b_azm(  xx0:xx1,yy0:yy1) $
, b_amb:	aa.b_amb(  xx0:xx1,yy0:yy1) $
, b_psi:	aa.b_psi(  xx0:xx1,yy0:yy1) $
, b_1azm:	aa.b_1azm( xx0:xx1,yy0:yy1) $
, b_1incl:	aa.b_1incl(xx0:xx1,yy0:yy1) $
, b_2azm:	aa.b_2azm( xx0:xx1,yy0:yy1) $
, b_2incl:	aa.b_2incl(xx0:xx1,yy0:yy1) $
, b_cen1:	aa.b_cen1( xx0:xx1,yy0:yy1) $
, b_alpha:	aa.b_alpha(xx0:xx1,yy0:yy1) $
, b__lat:	aa.b__lat( xx0:xx1,yy0:yy1) $
, b__e_w:	aa.b__e_w( xx0:xx1,yy0:yy1) $
, cct:		aa.cct(    xx0:xx1,yy0:yy1) $
, fld:		aa.fld(    xx0:xx1,yy0:yy1) $
, psi:		aa.psi(    xx0:xx1,yy0:yy1) $
, azm:		aa.azm(    xx0:xx1,yy0:yy1) $
, amb:		aa.amb(    xx0:xx1,yy0:yy1) $
, azm1:		aa.azm1(   xx0:xx1,yy0:yy1) $
, incl1:	aa.incl1(  xx0:xx1,yy0:yy1) $
, azm2:		aa.azm2(   xx0:xx1,yy0:yy1) $
, incl2:	aa.incl2(  xx0:xx1,yy0:yy1) $
, cen1:		aa.cen1(   xx0:xx1,yy0:yy1) $
, alpha:	aa.alpha(  xx0:xx1,yy0:yy1) $
, azm_o:	aa.azm_o(  xx0:xx1,yy0:yy1) $
, azm_r:	aa.azm_r(  xx0:xx1,yy0:yy1) $
, sdat:		aa.sdat(   xx0:xx1,yy0:yy1) $
, img0:		bytarr(t*xdim,t*ydim,/nozero) $
, img1:		bytarr(t*xdim,t*ydim,/nozero) $
, blt:		aa.blt $
, bwd:		aa.bwd $
, xsize:	t*xdim+aa.rmg $
, t:		t $
, t0:		aa.t $
, rmg:		rmg $
, pwr:		aa.pwr $
, b_cust:	aa.b_cust( xx0:xx1,yy0:yy1) $
, cust:		aa.cust(   xx0:xx1,yy0:yy1) $
, custnp:	aa.custnp $
, custmin:	aa.custmin $
, custmax:	aa.custmax $
, custgray:	aa.custgray $
, custwrap:	aa.custwrap $
, custinv:	aa.custinv $
, custback:	aa.custback $
, custname:	aa.custname $
, axa:		aa.axa $
, lock:		aa.lock $
, cri:		aa.cri $
, anti:		aa.anti $
, prime:	aa.prime $
, name0:	aa.name0 $
, name1:	aa.name1 $
, drag0:	aa.drag0 $
, drag1:	aa.drag1 $
, hilite:	aa.hilite $
, spectra:	aa.spectra $
, dty:		aa.dty $
}
				    ;
				    ;Set highlight arrays.
				    ;
tmp0 = bytarr(aa.t*aa.xdim,aa.t*aa.ydim)
if  n_dims(umbra) gt 0  then  tmp0(umbra) = 3
if  n_dims(laluz) gt 0  then  tmp0(laluz) = 4
tmp1 = puff( tmp0(tx0:tx1,ty0:ty1), t/aa.t )
umbz = where( tmp1 eq 3 )
luzz = where( tmp1 eq 4 )
arrz = { hi:-1, lo:-1 }
				    ;
				    ;Open display windows.
				    ;
window, /free, xsize=az.xsize, ysize=t*ydim $
, xpos=1144-t*xdim, ypos=30, title=aa.dty
az.win1  = !d.window
window, /free, xsize=az.xsize, ysize=t*ydim $
, xpos=0, ypos=30, title=aa.dty
az.win0  = !d.window
				    ;
				    ;Show ascii window.
				    ;
wshow, aa.wina
				    ;
				    ;Set and display interactive images.
				    ;
azam_display2, az, umbz, luzz, arrz
				    ;
				    ;Do bulk of azam program.
				    ;
azam_bulk, az, umbz, luzz, arrz, now_what
				    ;
				    ;Prompt if user wants to keep images.
				    ;
if  pop_cult(title='Want zoom windows left open (hidden) ?' $
,['yes','no'])  then begin
	wdelete, az.win0
	wdelete, az.win1
end else begin
	wshow, az.win0, 0
	wshow, az.win1, 0
end
				    ;
				    ;Return if no azimuth changes.
				    ;
whr = where( az.azm ne aa.azm(xx0:xx1,yy0:yy1), nwhr )
if nwhr eq 0 then return
				    ;
				    ;Check if user wants to keep changes.
				    ;
if pop_cult(title='Want updated images with zoom changes?',['yes','no']) $
then return
				    ;
				    ;Update arrays from zoom images.
				    ;
aa.b_azm(  xx0:xx1,yy0:yy1) = az.b_azm
aa.b_amb(  xx0:xx1,yy0:yy1) = az.b_amb
aa.b_1azm( xx0:xx1,yy0:yy1) = az.b_1azm
aa.b_1incl(xx0:xx1,yy0:yy1) = az.b_1incl
aa.b_2azm( xx0:xx1,yy0:yy1) = az.b_2azm
aa.b_2incl(xx0:xx1,yy0:yy1) = az.b_2incl
aa.azm(    xx0:xx1,yy0:yy1) = az.azm
aa.amb(    xx0:xx1,yy0:yy1) = az.amb
aa.azm1(   xx0:xx1,yy0:yy1) = az.azm1
aa.incl1(  xx0:xx1,yy0:yy1) = az.incl1
aa.azm2(   xx0:xx1,yy0:yy1) = az.azm2
aa.incl2(  xx0:xx1,yy0:yy1) = az.incl2
aa.azm_r(  xx0:xx1,yy0:yy1) = az.azm_r
				    ;
				    ;Update highlight arrays.
				    ;
tmp1 = bytarr(tx1-tx0+1,ty1-ty0+1)
if  n_dims(umbz) gt 0  then begin
	yy = umbz/(t*xdim)
	xx = umbz-yy*t*xdim
	yy = yy*aa.t/t
	xx = xx*aa.t/t
	tmp1(yy*aa.t*xdim+xx) = 3
end
if  n_dims(luzz) gt 0  then begin
	yy = luzz/(t*xdim)
	xx = luzz-yy*t*xdim
	yy = yy*aa.t/t
	xx = xx*aa.t/t
	tmp1(yy*aa.t*xdim+xx) = 4
end
				    ;
if  n_dims(arrow.hi) gt 0  then  tmp0(arrow.hi) = 1
if  n_dims(arrow.lo) gt 0  then  tmp0(arrow.lo) = 2
				    ;
tmp0(tx0:tx1,ty0:ty1) = tmp1
				    ;
umbra = where( tmp0 eq 3 )
laluz = where( tmp0 eq 4 )
arrow = { hi: where( tmp0 eq 1 ), lo: where( tmp0 eq 2 ) }
				    ;	
				    ;Set and display interactive images.
				    ;
azam_display2, aa, umbra, laluz, arrow
				    ;
end

pro azam_ps_usage
;+
;
;	procedure:  azam_ps
;
;	purpose:   output PostScript files of azam images.
;
;	author:  rob@ncar 1/93  paul@ncar 7/93
;
;	routines:  azam_ps_usage  azam_ps_extend  azam_mm_inch
;		   azam_ps
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:  azam_ps, aa, umbra, laluz, arrow"
	print
	print, "	output PostScript images:"
	print, "	images cct.*, fld.*, 1azm.*, 1incl.*,"
	print, "	cen1.*, and iiii.*."
	print
	print, "	Arguments"
	print, "		aa	- input azam data set structure"
	print, "		umbra	- input where umbra hi light array"
	print, "		laluz	- input where array for to hi light"
	print, "		arrow	- input arrow point structure"
	print
	print, "	;related UNIX"
	print, "	$ pageview -dpi 72 -left 1azm.ps &"
	print, "	$ lpr -Phaocolor 1azm.ps"
	print, "	$ hcprint *.ps ### high quality printing ###"
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	function:  azam_ps_extend
;
;	purpose:  prompt user for file name extension
;
;------------------------------------------------------------------------------
function azam_ps_extend, aa
				    ;
				    ;Table of choices.
				    ;
table = $
[ 'ps0',      'ps1' $
, 'ps2',      'ps3' $
, 'ps4',      'ps5' $
, 'ps6',      'ps7' $
, 'ps8',      'ps9' $
, 'ps.rob',   'ps.paul' $
, 'ps.sku',   'ps.vmp' $
, 'ps.lites', 'ps.tomczyk' $
, 'ps',       'WIDGET ENTRY' $
]
				    ;
				    ;Pop up window with choices.
				    ;
ext = table( pop_cult( title='click on file name extension', table ) )
				    ;
				    ;Return click value if not keyboard entry.
				    ;
if  ext ne 'WIDGET ENTRY'  then  return, ext
				    ;
				    ;Prompt for widget entry.
				    ;
return, azam_text_in( aa, 'Enter file name extension' )
				    ;
end
;------------------------------------------------------------------------------
;
;	function:  azam_mm_inch
;
;	purpose:  prompt user for image scale in megameters/inch
;
;------------------------------------------------------------------------------
function azam_mm_inch, aa, ps
				    ;
				    ;Scale that will just fit.
				    ;
just = (ps.x_mm/ps.x_avail) > (ps.y_mm/ps.y_avail)
				    ;
				    ;
				    ;
whole = 'just fit '+stringit(just)
				    ;
				    ;Table of choices.
				    ;
table = $
[                   whole,            whole $
, 'standard 10.0', 'WIDGET ENTRY' $
]
				    ;
				    ;Pop up window with choices.
				    ;
scl = pop_cult( title='pick xy scale megameters/inch' , table )
				    ;
				    ;Return click value if not keyboard entry.
				    ;
if scl le 1  then return, just
if scl eq 2  then return, 10.
				    ;
				    ;Prompt for widget entry.
				    ;
on_ioerror, ioerror0
ioerror0:
scl = 0L
reads, azam_text_in( aa, 'Enter megameters/inch scale' ), scl
return, scl
				    ;
end
;------------------------------------------------------------------------------
;
;	procedure:  azam_ps
;
;	purpose:   output PostScript files of azam images.
;
;------------------------------------------------------------------------------
pro azam_ps, aa, umbra, laluz, arrow
				    ;
				    ;Check number of parameters.
				    ;
if n_params() ne 4 then begin
	azam_ps_usage
return
end
				    ;
				    ;Some familiar parameters.
				    ;
t     = aa.t
xdim  = aa.xdim
ydim  = aa.ydim
txdim = t*xdim
				    ;
				    ;Initialize ps structure.
				    ;
ps_asp_str, aa, ps
				    ;
				    ;Prompt for area of interest.
				    ;
azam_click_xy, aa, 'Click on area of interest', xctr, yctr
ps.xctr = xctr
ps.yctr = yctr
				    ;
				    ;Prompt for op number.
				    ;
op = azam_op_num(aa)
				    ;
				    ;Prompt for file name extension.
				    ;
ps.cs_ext = azam_ps_extend(aa)
				    ;
				    ;Plot ranges in megameters.
				    ;
ps.x_mm = (xdim-1.) / aa.pix_deg * aa.mm_per_deg
ps.y_mm = (ydim-1.) / aa.pix_deg * aa.mm_per_deg
				    ;
				    ;Prompt for xy image scale in
				    ;mega meters per inch.
				    ;
ps.mm_per_inch = azam_mm_inch( aa, ps )
				    ;
				    ;Flag if arrow points are present.
				    ;
ifarrow = sizeof( arrow.hi, 0 ) ne 0  or  sizeof( arrow.lo, 0 ) ne 0 
				    ;
				    ;Unmagnify highlight arrays.
				    ;
if n_elements(umbra) ne 0 then  if sizeof(umbra,0) ne 0 then begin
	yy = umbra/txdim
	xx = umbra-yy*txdim
	yy = yy/t
	xx = xx/t
	umbra0 = yy*xdim+xx
	tmp = lonarr(xdim,ydim)
	tmp(umbra0) = 1
	umbra0 = where( tmp )
end
				    ;Update ambigs hilite.
if aa.hilite eq 'ambigs' then $
azam_ambigs, aa.b_azm, aa.sdat, aa.t, laluz, nwhr
				    ;
if n_elements(laluz) ne 0 then  if sizeof(laluz,0) ne 0 then begin
	yy = laluz/txdim
	xx = laluz-yy*txdim
	yy = yy/t
	xx = xx/t
	laluz0 = yy*xdim+xx
	tmp = lonarr(xdim,ydim)
	tmp(laluz0) = 1
	laluz0 = where( tmp )
end
				    ;
				    ;Compute signed field byte image by_s_fld
				    ;
tmp = bytarr(aa.xdim,aa.ydim)
tmp(aa.sxy) = 1
tmp0 = aa.b_fld
whr = where( aa.b_1incl gt 90., nwhr )
if nwhr ne 0 then  tmp0(whr) = -tmp0(whr)
tvasp, /notv, tmp0, bi=by_s_fld, min=-aa.mxfld, max=aa.mxfld $
, white=where(tmp eq 0 ), /gray, invert=0
				    ;
				    ;Output Postscript files.
				    ;
ps_asp_etc, ps, umbra0, laluz0, op $
, ifarrow, aa.b_1azm, aa.b_1incl, aa.sxy $
, by__cct  = aa.cct   $
, by_fld   = aa.fld   $
, by_s_fld = by_s_fld $
, by_1azm  = aa.azm1  $
, by_1incl = aa.incl1 $
, by_cen1  = aa.cen1  $
, azam     = aa
				    ;
end

pro azam_tools
;+
;
;	procedure:  azam_tools
;
;	purpose:  compile several small azam routines
;
;	author:  paul@ncar, 10/93	(minor mod's by rob@ncar)
;
;	routines:  tw
;		   azam_tools        azam_display2     azam_message
;		   azam_relabel      azam_click_xy     azam_text_in
;		   azam_image_names  azam_flipa        azam_a_azm
;		   azam_op_num       azam_2d_data      azam_cursor
;		   azam_azm_off      azam_custom       azam_average
;		   azam_flick        azam_slick        azam_spectra
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	@azam_tools"
	print
	print, "	Compile several small azam routines."
	print
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	procedure:  set window and do tv procedure
;
;	purpose:  magnify and display two azam interactive images
;
;------------------------------------------------------------------------------
pro tw, window, image, x, y
wset, window
tv, image, x, y
end
;------------------------------------------------------------------------------
;
;	procedure:  azam_display2
;
;	purpose:  magnify and display two azam interactive images
;
;------------------------------------------------------------------------------
pro azam_display2, aa, umbra, laluz, arrow

				    ;Magnify images and install high lights.
name = aa.name0
aa.img0 = azam_image( name, aa, umbra, laluz, arrow )
aa.name0 = name
name = aa.name1
aa.img1 = azam_image( name, aa, umbra, laluz, arrow )
aa.name1 = name
				    ;Display the images.
tw, aa.win0, aa.img0, 0, 0
tw, aa.win1, aa.img1, 0, 0

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_message
;
;	purpose:  print message in azam button window.
;
;------------------------------------------------------------------------------
pro azam_message, aa, message, color=color

				    ;Set to azam button window.
wset, aa.winb  &  wshow, aa.winb
				    ;Set default margin color.
if  n_elements(message) eq 0  then begin
	if  n_elements(color) eq 0  then  color=aa.black
end else begin
	if  n_elements(color) eq 0  then  color=aa.yellow
end
				    ;Erase window with color index.
erase, color
				    ;Check if there is a message.
if n_elements(message) ne 0 then begin

				    ;Set character color.
	if  color eq aa.black  then  c_color=aa.white  else  c_color=aa.black

				    ;Print message.
	xyouts, 3*aa.blt, 4, message $
	, /device, align=0.5, charsize=1.4, color=c_color
end
				    ;Wait for no mouse button pressed.
repeat  cursor, xx, yy, /device, /nowait  until  !err eq 0

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_relabel
;
;	purpose:  print labels in right image margins.
;
;------------------------------------------------------------------------------
pro azam_relabel, aa, lbls, wdws
				    ;Black array for window margin.
blank = replicate( aa.black, aa.rmg, aa.t*aa.ydim )

				    ;Set default message azam image names.
if n_elements(lbls) eq 0 then  lbls=[aa.name0,aa.name1]

				    ;Set default windows to azam images.
if n_elements(wdws) eq 0 then  wdws=[aa.win0,aa.win1]

				    ;Loop over windows.
for i=0,n_elements(wdws)>n_elements(lbls) do begin

				    ;Set window active.
	wset, wdws( i < (n_elements(wdws)-1) )

				    ;Erase margin.
	tv, blank, aa.t*aa.xdim, 0

				    ;Print message.
	xyouts, aa.t*aa.xdim+2, aa.t*aa.ydim-2 $
	, lbls( i < (n_elements(lbls)-1) ) $
	, /device, align=0.0, charsize=1.4, color=aa.white, orient=270.
end

end
;-----------------------------------------------------------------------------
;
;	procedure:  azam_text_in
;
;	purpose:  open text widget and input character string
;
;-----------------------------------------------------------------------------
function azam_text_in, aa, title
				    ;Set default prompt.
if n_elements(title) eq 0 then title='Enter character string'

				    ;Open base widget.
base = widget_base( title=title )
				    ;Open text widget.
text = widget_text( base, /editable, ysize=1, xsize=120 )

				    ;Realize the widget.
widget_control, base, /realize
				    ;Wait for event.
event = widget_event( text )
				    ;Get character string.
widget_control, text, get_value=buff

				    ;Destroy the widget.
widget_control, base, /destroy
				    ;Erase user prompt.
azam_message, aa
				    ;Return character string.
return, buff(0)

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_click_xy
;
;	purpose:  prompt for and return azam image cooridnate click
;
;------------------------------------------------------------------------------
pro azam_click_xy, aa, message, x, y

				    ;Print message in button window.
azam_message, aa, message
				    ;Loop till no button pressed.
repeat azam_cursor, aa, xerase, yerase $
	, aa.win0, aa.win1, undef, undef, undef $
	,   undef,   undef, undef, undef, undef $
	, eraser0, eraser1, undef, undef, undef $
	, x, y, state $
	, likely=likely $
	, maybe=[aa.win0,aa.win1] $
until state eq 0

				    ;Loop till button pressed.
repeat azam_cursor, aa, xerase, yerase $
	, aa.win0, aa.win1, undef, undef, undef $
	,   undef,   undef, undef, undef, undef $
	, eraser0, eraser1, undef, undef, undef $
	, x, y, state $
	, likely=likely $
	, maybe=[aa.win0,aa.win1] $
until state ne 0
				    ;Erase cursor.
if xerase ne -1 then begin
	tw, aa.win0, eraser0, xerase, yerase
	tw, aa.win1, eraser1, xerase, yerase
end
				    ;Erase message.
azam_message, aa
				    ;Wait buttons pressed in image windows.
wset, likely
repeat  cursor, x0,y0, /device,/nowait  until  !err eq 0  or  x0 eq -1

end
;------------------------------------------------------------------------------
;
;	function: azam_image_names
;
;	purpose:  return string array with recognized azam image names;
;		  the last name is 'continue'
;
;------------------------------------------------------------------------------
function azam_image_names, aa


if aa.zoom then begin
	SET_flux         = 'continue'
end else begin
	SET_flux         = 'SET flux'
end

return, $
[         'continue',         aa.custname  $
,      'fill factor',            SET_flux  $
,    'local azimuth',      'local incline' $
,    'ambig azimuth',      'ambig incline' $
,'reference azimuth',  'reference incline' $
, 'original azimuth',   'original incline' $
,    'sight azimuth',      'sight incline' $
,        'continuum',              'field' $
,          'doppler',           'continue' $
]

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_flipa
;
;	purpose:  flip azimuth in azam structure based on where array. 
;
;------------------------------------------------------------------------------
pro azam_flipa, aa, chg

if n_dims(chg) le 0 then return

tmp             = aa.b_azm(chg)
aa.b_azm(chg)   = aa.b_amb(chg)
aa.b_amb(chg)   = tmp
tmp             = aa.b_1azm(chg)
aa.b_1azm(chg)  = aa.b_2azm(chg)
aa.b_2azm(chg)  = tmp
tmp             = aa.b_1incl(chg)
aa.b_1incl(chg) = aa.b_2incl(chg)
aa.b_2incl(chg) = tmp
tmp           = aa.azm(chg)
aa.azm(chg)   = aa.amb(chg)
aa.amb(chg)   = tmp
tmp           = aa.azm1(chg)
aa.azm1(chg)  = aa.azm2(chg)
aa.azm2(chg)  = tmp
tmp           = aa.incl1(chg)
aa.incl1(chg) = aa.incl2(chg)
aa.incl2(chg) = tmp

end
;------------------------------------------------------------------------------
;
;	function:  azam_a_azm
;
;	purpose:  return ongoing azimuth solution as a stream vector
;
;------------------------------------------------------------------------------
function azam_a_azm, aa
				    ;Check if working with stretched images.
if  aa.stretch  then begin
				    ;Get copy of original azimuth stream
				    ;vector from directory.
				    ;This is to assures that all solved
				    ;data points are present.
	tmp = read_floats(aa.dty+'a_azm')

				    ;Set where there are changes.
	tmp(aa.vec_sxy) = aa.b_azm(aa.sxy)

				    ;Return stream vector of ongoing azimuth.
	return, tmp

end else begin
				    ;Return stream vector of ongoing azimuth.
	return, aa.b_azm(aa.sxy)
end

end
;------------------------------------------------------------------------------
;
;	function:  azam_num_op
;
;	purpose:  prompt user for op number
;
;------------------------------------------------------------------------------
function azam_op_num, aa
				    ;Return ongoing op number if defined.
	if  aa.op ge 0  then  return, aa.op

				    ;Pop up window with choices.
	num = pop_cult( title='click on op number', $
	[ '0',  '1' $
	, '2',  '3' $
	, '4',  '5' $
	, '6',  '7' $
	, '8',  '9' $
	,'10',	'11' $
	,'12',	'13' $
	,'14',	'15' $
	,'16',	'17' $
	,'18',	'19' $
	,'20',	'21' $
	,'22',	'23' $
	,'24',	'25' $
	,'26',	'27' $
	,'28',	'29' $
	,'30',	'31' $
	,'32',	'33' $
	,'34',	'35' $
	,'36',	'37' $
	,'38',	'39' $
	,'40',	'41' $
	,'42',	'43' $
	,'44',	'45' $
	,'46',	'47' $
	,'48',	'49' $
	,'50',	'WIDGET ENTRY' $
	] )
				    ;Return click value if not keyboard entry.
	if  num le 50  then  return, num

				    ;Prompt for widget entry.
	on_ioerror, ioerror0
	ioerror0:
	num = 0L
	reads, azam_text_in( aa, 'Enter op number' ), num
	return, round(num)
end
;------------------------------------------------------------------------------
;
;	procedure:  azam_2d_data
;
;	purpose:  form 2D data array corresponding to azam image.
;
;------------------------------------------------------------------------------
pro azam_2d_data, aaname, aa, b_data

				    ;Check number of parameters.
if  n_params() eq 0  then begin
	print
	print, "usage:	azam_2d_data, aaname, aa, b_data
	print
	print, "	Form 2D data array corresponding to azam image."
	print
	print, "	Arguments"
	print, "		aaname	- input string name of image"
	print, "		aa	- input azam data set structure"
	print, "		b_data	_ output 2D data array."
	print
	return
endif
				    ;Get 2D data array.
case aaname of
'continuum'		: b_data = aa.b__cct
'field'			: b_data = aa.b_fld
'local azimuth'		: b_data = aa.b_1azm
'local incline'		: b_data = aa.b_1incl
'ambig azimuth'		: b_data = aa.b_2azm
'ambig incline'		: b_data = aa.b_2incl
'sight azimuth'		: b_data = aa.b_azm
'sight incline'		: b_data = aa.b_psi
'doppler'		: b_data = aa.b_cen1
'fill factor'		: b_data = aa.b_alpha
aa.custname		: b_data = aa.b_cust
'original azimuth'	: $
    begin
	b_data = aa.b_1azm
	whr = where( aa.azm ne aa.azm_o, nwhr )
	if nwhr ne 0 then  b_data(whr) = aa.b_2azm(whr)
    end
'original incline'	: $
    begin
	b_data = aa.b_1incl
	whr = where( aa.azm ne aa.azm_o, nwhr )
	if nwhr ne 0 then  b_data(whr) = aa.b_2incl(whr)
    end
else: b_data = fltarr(aa.xdim,aa.ydim)
end

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_cursor
;
;	purpose:  do most details of azam.pro computed cursor.
;
;------------------------------------------------------------------------------
pro azam_cursor, aa, xerase, yerase $
,      w0,      w1,      w2,      w3,      w4 $
,    img0,    img1,    img2,    img3,    img4 $
, eraser0, eraser1, eraser2, eraser3, eraser4 $
, xc, yc, state $
, likely=likely $
, maybe=maybe $
, no_ttack=no_ttack
				    ;Default mouse status on button
				    ;window.
aa.bx = -1L
aa.by = -1L
aa.bs = 0L
				    ;Set defaults for undefined variables.
if n_elements(  likely) eq 0 then likely=maybe(0)
if n_elements(   state) eq 0 then state=0
if n_elements(no_ttack) eq 0 then no_ttack=0
if n_elements(  xerase) eq 0 then begin
	xerase = -1L
	yerase = -1L
end
if n_elements(      xc) eq 0 then begin
	xc = -1L
	yc = -1L
end
				    ;Flags for images to work on.
nw0 = n_elements(w0)
nw1 = n_elements(w1)
nw2 = n_elements(w2)
nw3 = n_elements(w3)
nw4 = n_elements(w4)
				    ;Get some display parameters.
t    = aa.t
xdim = aa.xdim
ydim = aa.ydim
				    ;Try to get mouse status from
				    ;other possible images.
start = where( maybe eq likely )
ntry = n_elements(maybe)
for i = 0,ntry-1 do begin
	try = maybe((i+start(0)) mod ntry)
	wset, try  &  cursor, xxxx, yyyy, /device, /nowait
	if xxxx ne -1 then  goto, break22
end
				    ;CURSOR NOT ON AZAM IMAGES.
				    ;Erase old crusors and ascii window.
wset, aa.wina  &  erase, aa.black
if xerase ge 0 then begin
	if nw0 then  tw, w0, eraser0, xerase, yerase
	if nw1 then  tw, w1, eraser1, xerase, yerase
	if nw2 then  tw, w2, eraser2, xerase, yerase
	if nw3 then  tw, w3, eraser3, xerase, yerase
	if nw4 then  tw, w4, eraser4, xerase, yerase
end
				    ;Null returns for cursor not on images.
xerase = -1L
xc     = -1L
yc     = -1L
state  =  0L
				    ;Mouse status on button window.
wset, aa.winb  &  cursor, xxxx, yyyy, /device, /nowait
aa.bx = xxxx
aa.by = yyyy
aa.bs = !err

return
				    ;Image number cursor is on.
break22:
likely = try
				    ;Get mouse button state.
state = !err
				    ;Get unmagnified coordinates.
xi = 0 > ((xxxx-28)/t) < (xdim-1)
yi = 0 >      (yyyy/t) < (ydim-1)
				    ;Check if position has changed.
if xi eq xc and yi eq yc then return

				    ;Set new coordinates.
xc = xi
yc = yi
				    ;Return if displays not changed.
if no_ttack then return
				    ;Save cursor informtion common to 
				    ;entire run.
common azam_cursor_com, cradius, cdim, yrast, xcircle, xspin
if  n_elements(cradius) eq 0  then begin
	cradius = 12
	cdim = 2*cradius+1
	tmp = indgen(7*cradius)*2.*!pi/(6*cradius-1)
	ycircle = (cradius-1)*sin(tmp)
	xcircle = (cradius-1)*cos(tmp)
	xspin = lindgen(cradius-1)+1.
	yrast = [ ycircle, fltarr(cradius-1) ]
end

				    ;Set bounds.
txdim = t*xdim
tydim = t*ydim
xcenter = t*xc+t/2
ycenter = t*yc+t/2
xx0 = 0 > (xcenter-cradius)
yy0 = 0 > (ycenter-cradius)
xx1 = (xcenter+cradius) < (txdim-1)
yy1 = (ycenter+cradius) < (tydim-1)
				    ;Blank cursor image without valid colors.
pad = replicate( -1, cdim, cdim )

if  aa.sdat(xc,yc) then begin
				    ;Compute where array for tack.
	agl = ( aa.b_1azm(xc,yc)-aa.angxloc )*!pi/180.
	snn = sin(agl)
	csn = cos(agl)
	cosz = cos(aa.b_1incl(xc,yc)*!pi/180.)
	xrast = [ xcircle*cosz, xspin ]
	xprm = round( csn*xrast-snn*yrast + cradius )
	yprm = round( snn*xrast+csn*yrast + cradius )
	gyro = yprm*cdim+xprm
				    ;Pick colors depending on reversal.
	if  aa.b_1incl(xc,yc) le 90. then begin
		colr = aa.yellow
		outl = aa.red
	end else begin
		colr = aa.white
		outl = aa.black 
	end
				    ;Outline cursor.
	pad(gyro+1   ) = outl
	pad(gyro-1   ) = outl
	pad(gyro+cdim) = outl
	pad(gyro-cdim) = outl
				    ;Install cursor.
	pad(gyro) = colr

end else begin
				    ;Cursor is not on a data point.
				    ;Set cross with outline.
	pad(*,cradius-1:cradius+1) = aa.black
	pad(cradius-1:cradius+1,*) = aa.black
	pad(*,cradius) = aa.white
	pad(cradius,*) = aa.white
end
				    ;Set center to image color.
tt = t < 3
xy0 = cradius-tt/2
xy1 = xy0+tt-1
pad(xy0:xy1,xy0:xy1) = -1
				    ;Truncate due to array bounds.
pad = pad( cradius+xx0-xcenter:cradius+xx1-xcenter $
         , cradius+yy0-ycenter:cradius+yy1-ycenter )

				    ;Translate cursor to where array form.
whrcrs = where( pad ge 0 )
crs = pad( whrcrs )
				    ;Erase old crusors.
if xerase ge 0 then begin
	if nw0 then  tw, w0, eraser0, xerase, yerase
	if nw1 then  tw, w1, eraser1, xerase, yerase
	if nw2 then  tw, w2, eraser2, xerase, yerase
	if nw3 then  tw, w3, eraser3, xerase, yerase
	if nw4 then  tw, w4, eraser4, xerase, yerase
end
				    ;Update cursor coordinates.
xerase  = xx0
yerase  = yy0
				    ;Plot cursor in window 0.
if nw0 then begin
	if  n_elements(img0) ne 0 $
	then  eraser0 = img0(xx0:xx1,yy0:yy1) $
	else  eraser0 = aa.img0(xx0:xx1,yy0:yy1)
	tmp = eraser0
	tmp( whrcrs ) = crs
	tw, w0, tmp, xerase, yerase
end
				    ;Plot cursor in window 1.
if nw1 then begin
	if  n_elements(img1) ne 0 $
	then  eraser1 = img1(xx0:xx1,yy0:yy1) $
	else  eraser1 = aa.img1(xx0:xx1,yy0:yy1)
	tmp = eraser1
	tmp( whrcrs ) = crs
	tw, w1, tmp, xerase, yerase
end
				    ;Plot cursor in window 2.
if nw2 then begin
	if  n_elements(img2) ne 0 $
	then  eraser2 = img2(xx0:xx1,yy0:yy1) $
	else  eraser2 = aa.img0(xx0:xx1,yy0:yy1)
	tmp = eraser2
	tmp( whrcrs ) = crs
	tw, w2, tmp, xerase, yerase
end
				    ;Plot cursor in window 3.
if nw3 then begin
	if  n_elements(img3) ne 0 $
	then  eraser3 = img3(xx0:xx1,yy0:yy1) $
	else  eraser3 = aa.img1(xx0:xx1,yy0:yy1)
	tmp = eraser3
	tmp( whrcrs ) = crs
	tw, w3, tmp, xerase, yerase
end
				    ;Plot cursor in window 4.
if nw4 then begin
	if  n_elements(img4) ne 0 $
	then  eraser4 = img4(xx0:xx1,yy0:yy1) $
	else  eraser4 = aa.img0(xx0:xx1,yy0:yy1)
	tmp = eraser4
	tmp( whrcrs ) = crs
	tw, w4, tmp, xerase, yerase
end
				    ;Print data near cursor.
azam_average, aa, xc,yc, xc,yc, xc,yc

				    ;Set window where cursor is at.
wset, likely

end
;-----------------------------------------------------------------------------
;
;	function:  azam_azm_off
;
;	purpose: Return azimuth array less offset put in range -180. to 180.
;
;-----------------------------------------------------------------------------
function azam_azm_off, azm, off
	if n_elements(off) eq 1 then if off(0) eq 0. then return, azm
	return, ( (azm-off+(720.+180.) ) mod 360. ) - 180.
end
;------------------------------------------------------------------------------
;
;	procedure:  azam_custom
;
;	purpose:  modify custom image.
;
;------------------------------------------------------------------------------
pro azam_custom, aa, umbra, laluz, arrow

				   ;Names of some a_* files.
file_names = reverse( $
[ 'continue',   'WIDGET ENTRY' $
, 'a_1azm',	'a_1incl',	'a_2azm',	'a_2incl'$
, 'a_alpha',	'a_alpha_er',	'a_ampl1',	'a_ampl1_er' $
, 'a_ampl2',	'a_ampl2_er',	'a_azm',	'a_azm_er' $
, 'a_b1mu',	'a_b1mu_er',	'a_bzero',	'a_bzero_er' $
, 'a__cct',	'a_cen1',	'a_cen1_er',	'a_cen2' $
, 'a_cen2_er',	'a_chi',	'a_chi_ii',	'a_chi_qq' $
, 'a_chi_uu',	'a_chi_vv',	'a__dclntn',	'a_delta' $
, 'a_delta_er',	'a_dmp',	'a_dmp_er',	'a_dop' $
, 'a_dop_er',	'a_epsl1',	'a_epsl1_er',	'a_epsl2' $
, 'a_epsl2_er',	'a_eta0',	'a_eta0_er',	'a_fld' $
, 'a_fld_er',	'a_icmag',	'a_iters',	'a__latitude' $
, 'a__longitude','a__mu',	'a__pip',	'a_psi' $
, 'a_psi_er',	'a__rgtasn',	'a__utime'$
] )

t     = aa.t
xdim  = aa.xdim
ydim  = aa.ydim
txdim = t*xdim
tydim = t*ydim
white = aa.white
black = aa.black
				    ;Open window for custom image.
xsize = txdim+125
ysize = 300 > tydim
window, /free, xsize=xsize, ysize=ysize $
, xpos=1144-xsize, ypos=40, title='custom image'
w2 = !d.window
				    ;Show ascii window.
wshow, aa.wina
				    ;Loop till user clicks right button.
while 1 do begin
				    ;Compute byte image.
	img2 = azam_image( aa.custname, aa, umbra, laluz, arrow )

				    ;Display custom image.
	wset, w2  &  erase, black
	tv, img2, 0, 0
	xyouts, txdim+2, tydim-2, aa.custname $
	, /device, align=0.0, charsize=1.4, color=white, orient=270

				    ; Plot color bar
	x0 = txdim+10
	y0 = ysize/2-100
	tv, replicate(white,42,202), x0-1, y0-1
	tvasp, lindgen(40,200)/40, x0, y0 $
	, gray=aa.custgray, wrap=aa.custwrap, invert=aa.custinv
	xyouts, txdim+4, [y0-20,y0+208] $
	, [stringit(aa.custmin),stringit(aa.custmax)] $
	, /device, align=0.0, charsize=1.4, color=white

				    ;Print instructions.
	azam_message, aa, 'left(options), right(exit)'

				    ;Do computed cursors till right
				    ;button clicked.
	stst = 0
	while  stst ne 4 and stst ne 1  do begin
		azam_cursor, aa, xerase, yerase $
		, aa.win0, aa.win1,      w2,   undef,   undef $
		,   undef,   undef,    img2,   undef,   undef $
		, eraser0, eraser1, eraser2,   undef,   undef $
		, xc, yc, state $
		, likely=likely $
		, maybe=[aa.win0,aa.win1,w2]
		stst = state > aa.bs
	end
				    ;Erase crusors.
	if xerase ge 0 then begin
		tw, aa.win0, eraser0, xerase, yerase
		tw, aa.win1, eraser1, xerase, yerase
		tw,      w2, eraser2, xerase, yerase
		xerase = -1
	end
				    ;Exit if right button pressed.
	if stst eq 4 then begin
		wdelete, w2
		return
	end
				    ;Set button strings.
	if aa.custgray then begin
		colscale = 'black & white'
	end else begin
		if aa.custwrap $
		then  colscale = 'wraped color' $
		else  colscale = 'unwraped color'
	end

	if aa.custinv then  invert='inverted'  else  invert='uninverted'

	maxdat = 'max: '+stringit(aa.custmax)
	mindat = 'min: '+stringit(aa.custmin)

	background = 'continue'
	if aa.custback eq aa.black then  background = 'black background'
	if aa.custback eq aa.white then  background = 'white background'

				    ;Set choice table.
	labels = $
	[ colscale $
	, invert $
	, mindat $
	, maxdat $
	, aa.custname $
	, background $
	, 'continue' $
	]
				    ;Prompt for choice.
	case  labels( pop_cult( labels, $
	title='Change what present contition ?' ) ) of

				    ;Invert color scale
	invert:		aa.custinv = 1L-aa.custinv

				    ;Change backgroud color, black or white.
	'black background':  aa.custback = aa.white
	'white background':  aa.custback = aa.black

				    ;Reset scale minimum.
	mindat: $
	    begin
			on_ioerror, ioerror0
			mess = 'Enter minimum (was '+stringit(aa.custmin)+')'
			ioerror0:
			tmp = 1.
			reads, azam_text_in(aa,mess), tmp
			aa.custmin = tmp
	    end
				    ;Reset scale maximum.
	maxdat: $
	    begin
			on_ioerror, ioerror1
			mess = 'Enter maximum (was '+stringit(aa.custmax)+')'
			ioerror1:
			tmp = 1.
			reads, azam_text_in(aa,mess), tmp
			aa.custmax = tmp
	    end
				    ;Reset color or gray scale.
	colscale: $
	    begin
		lbls = $
		[ 'black & white' $
		, 'inverted black & white' $
		, 'unwrap color' $
		, 'wrap color' $
		]
		ix = pop_cult( lbls, title='Pick color scale' )
		if  ix le 1  then begin
			aa.custgray = 1
			aa.custinv  = ix
			aa.custwrap = 0
		end else begin
			aa.custgray = 0
			aa.custinv  = 0
			aa.custwrap = ix-2
		end
	    end
				    ;Read new file.
	aa.custname: $
	    begin
		error = 1
		while error ne 0 do begin

				    ;Prompt for file name.
			error = 0
			a_name = file_names( pop_cult(file_names $
			, title='Click on file name' ) )
			if a_name eq 'continue' then goto, break7

				    ;Enter file name from widget.
			if a_name eq 'WIDGET ENTRY' then begin
				a_name = azam_text_in( aa $
				, 'Enter a_* file name (q=quit)' )
				if a_name eq 'q' then goto, break7
			end
				    ;Try to read file.
			tmp = read_floats( aa.dty+a_name, error )

			if error ne 0 then begin
				azam_message, aa, a_name+': read error'
			end else begin

				    ;Check for correct number of points.
				npnts = n_elements(tmp)
				if  npnts ne aa.npoints $
				and npnts ne aa.nsolved then begin
					azam_message, aa $
					,a_name+': file is wrong size'
					error = 1
				end
			end
		end
				    ;Read 2D data array.
		aa.b_cust = s_image( aa.dty+a_name, aa )

		aa.custname = a_name
		aa.custnp   = npnts
		if aa.custnp eq aa.npoints $
		then  aa.custmin  = min( aa.b_cust(aa.pxy), max=mx ) $
		else  aa.custmin  = min( aa.b_cust(aa.sxy), max=mx )
		aa.custmax  = mx
		aa.custgray = 1L
		aa.custwrap = 0L
		aa.custinv  = 0L
		aa.custback = aa.white
	    end
	else:
	end
				    ;Form background where array.
	bkg = replicate(1L,aa.xdim,aa.ydim)
	if aa.custnp eq aa.npoints $
	then  bkg(aa.pxy) = 0 $
	else  bkg(aa.sxy) = 0
	bkg = where(bkg)
				    ;Form 2D byte image.
	tvasp, aa.b_cust, white=bkg $
	, gray=aa.custgray, wrap=aa.custwrap, invert=aa.custinv $
	, min=aa.custmin, max=aa.custmax $
	, /notv, bi=tmp
	aa.cust = tmp
				   ;Set background.
	aa.cust(bkg) = aa.custback

	break7:

end

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_average
;
;	purpose:  average and print data near cursor.
;
;------------------------------------------------------------------------------
pro azam_average, aa, xc,yc, x0,y0, x1,y1

				    ;Erase ascii window with white background.
wset, aa.wina
erase, aa.black
				    ;Print coordinates.
xy5000 = aa.xy5000(xc,yc)
if xy5000 ge 0 then begin
	xyouts, 4, 2 $
	, strcompress( /remove_all $
	, string('(',xc+aa.x0,',', yc+aa.y0,')(' $
	, xy5000 mod 5000,',',xy5000/5000,')') ) $
	, align=0.0, color=aa.white, /device, charsize=1.4
end else begin
	xyouts, 4, 2 $
	, strcompress( /remove_all $
	, string('(',xc+aa.x0,',', yc+aa.y0,')') ) $
	, align=0.0, color=aa.white, /device, charsize=1.4
end
				    ;Get where array for continuum.
wct = where( aa.cct(x0:x1,y0:y1) ne 0., nct )

				    ;Check if there is data.
if nct gt 0 then begin
				    ;Convert where array to full image.
	xdm = x1-x0+1
	yyy = wct/xdm
	xxx = wct-yyy*xdm
	wct = (y0+yyy)*aa.xdim+(x0+xxx)

				    ;Average continuum
	cct = total(aa.b__cct(wct))/nct

				    ;Print continuum.
	xyouts $
	, [ 1, 2]*aa.blt $
	, 10*aa.bwd+2 $
	, strcompress( /remove_all, $
	[ 'continuum', string(cct,fo='(f12.1)') ] ) $
	, align=1.0, color=aa.white, /device, charsize=1.4

				    ;Print number data points.
	if nct ne 1 then $
	xyouts $
	, 2*aa.blt+10 $
	, 10*aa.bwd+2 $
	, strcompress( string(nct), /remove_all )+' points' $
	, align=0.0, color=aa.white, /device, charsize=1.4

				    ;Print custom image average.
	if aa.custnp eq aa.npoints then begin
		cst = total(aa.b_cust(wct))/nct
		xyouts, [1,2]*aa.blt , 5*aa.bwd+2 $
		, strcompress( /remove_all $
		, [  aa.custname, string(cst) ] ) $
		, align=1.0, color=aa.white, /device, charsize=1.4
	end
				    ;Where array for solved points.
	wdt = where( aa.sdat(x0:x1,y0:y1), ndt )

				    ;Check if there is solved data.
	if ndt gt 0 then begin
				    ;Convert where array to full image.
		yyy = wdt/xdm
		xxx = wdt-yyy*xdm
		wdt = (y0+yyy)*aa.xdim+(x0+xxx)

				    ;Compute flux.
		alp = aa.b_alpha(wdt)
		fld = aa.b_fld(  wdt)
		in1 = aa.b_1incl(wdt)
		flx = (1.-alp)*fld*cos(in1*(!pi/180.))

				    ;Averages.
		psi = total(aa.b_psi(  wdt))/ndt
		azm = total(aa.b_azm(  wdt))/ndt
		az1 = total(aa.b_1azm( wdt))/ndt
		az2 = total(aa.b_2azm( wdt))/ndt
		in2 = total(aa.b_2incl(wdt))/ndt
		cn1 = total(aa.b_cen1( wdt))/ndt
		alp = total(alp)/ndt
		fld = total(fld)/ndt
		in1 = total(in1)/ndt
		flx = total(flx)/ndt

				    ;Print info in window.
		xyouts $
		, [1,2,1,2,1,2,1,2,2,3,1,2,3,1,2,3,1,2,3]*aa.blt $
		, [9,9,8,8,7,7,6,6,4,4,3,3,3,2,2,2,1,1,1]*aa.bwd+2 $
		, strcompress( /remove_all, $
		[     'field',string(fld,fo='(f12.1)') $
		,      'flux',string(flx,fo='(f12.1)') $
		,   'doppler',string(cn1,fo='(f12.4)') $
		,    '1-fill',string(alp,fo='(f12.4)') $
		, 'azimuth','incline' $
		, 'sight',string(azm,fo='(f12.2)'),string(psi,fo='(f12.2)') $
		, 'local',string(az1,fo='(f12.2)'),string(in1,fo='(f12.2)') $
		, 'ambig',string(az2,fo='(f12.2)'),string(in2,fo='(f12.2)') $
		] ) $
		, align=1.0, color=aa.white, /device, charsize=1.4

				    ;Print number data points.
		if ndt ne 1 then $
		xyouts $
		, 2*aa.blt+10 $
		, 9*aa.bwd+2 $
		, strcompress( string(ndt), /remove_all )+' points' $
		, align=0.0, color=aa.white, /device, charsize=1.4

				    ;Print custom image average.
		if aa.custnp ne aa.npoints then begin
			cst = total(aa.b_cust(wdt))/ndt
			xyouts, [1,2]*aa.blt , 5*aa.bwd+2 $
			, strcompress( /remove_all $
			, [  aa.custname, string(cst) ] ) $
			, align=1.0, color=aa.white, /device, charsize=1.4
		end
	end
end
end
;------------------------------------------------------------------------------
;
;	procedure:  azam_flick
;
;	purpose:  blink an image on both display images.
;
;------------------------------------------------------------------------------
pro azam_flick, aa, umbra, laluz, arrow

t     = aa.t
xdim  = aa.xdim
ydim  = aa.ydim
txdim = t*xdim
tydim = t*ydim
				    ;Get image name.
labels = azam_image_names(aa)
iname = labels( pop_cult( labels, 1, title='click on one' ) )
if iname eq 'continue' then return
				    ;Print instructions.
azam_message, aa, 'left(faster) middle(slower) right(stop)'

				    ;Set hidden pixmap windows.
window, /free, /pixmap, xsize=txdim, ysize=tydim
w2 = !d.window
tv, aa.img0, 0, 0

window, /free, /pixmap, xsize=txdim, ysize=tydim
w3 = !d.window
tv, aa.img1, 0, 0

img4 = azam_image( iname, aa, umbra, laluz, arrow )
window, /free, /pixmap, xsize=txdim, ysize=tydim
w4 = !d.window
tv, img4, 0, 0
				    ;Blink images.
				    ;(Same method as flick.pro).
rate = 2.25
faster = 0
while 1 do begin
				    ;Copy flick image from pixmap window.
	t0 = systime(1)
	wset, aa.win0  &  device, copy=[0,0,txdim,tydim,0,0,w4]
	wset, aa.win1  &  device, copy=[0,0,txdim,tydim,0,0,w4]

				    ;Loop for time interval.
	while  systime(1)-t0 lt 1./rate  do begin

				    ;Do computed field cursors.
		azam_cursor, aa, xerase, yerase $
		, aa.win0, aa.win1,      w2,      w3,      w4 $
		,    img4,    img4,   undef,   undef,    img4 $
		, eraser4, eraser4, eraser0, eraser1, eraser4 $
		, xc, yc, state $
		, likely=likely $
		, maybe=[aa.win0,aa.win1]

				    ;Process mouse button state.
		case  state > aa.bs  of
			0: faster = faster mod 8
			1: if faster eq 0 then  faster = 1
			2: if faster eq 0 then  faster = 2
			4: goto, break0
			else:
		end
	end
				    ;Copy flick image from pixmap window.
	t0 = systime(1)
	wset, aa.win0  &  device, copy=[0,0,txdim,tydim,0,0,w2]
	wset, aa.win1  &  device, copy=[0,0,txdim,tydim,0,0,w3]

				    ;Loop for time interval.
	while  systime(1)-t0 lt 1./rate  do begin

				    ;Do computed field cursors.
		azam_cursor, aa, xerase, yerase $
		, aa.win0, aa.win1,      w2,      w3,      w4 $
		,   undef,   endef,   undef,   undef,    img4 $
		, eraser0, eraser1, eraser0, eraser1, eraser4 $
		, xc, yc, state $
		, likely=likely $
		, maybe=[aa.win0,aa.win1]

				    ;Process mouse button state.
		case  state > aa.bs  of
			0: faster = faster mod 8
			1: if faster eq 0 then  faster = 1
			2: if faster eq 0 then  faster = 2
			4: goto, break0
			else:
		end
	end
				    ;Adjust cycle rate.
	if faster ne 0 then begin
		if faster eq 1 then  rate = rate*1.5
		if faster eq 2 then  rate = rate/1.5
		faster = 8
	end
end
break0:
				    ;Delete extra windows.
wdelete, w2, w3, w4
				    ;Restore display windows.
tw, aa.win0, aa.img0, 0, 0
tw, aa.win1, aa.img1, 0, 0

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_slick
;
;	purpose:  blink a sub image on azam display images
;
;------------------------------------------------------------------------------
pro azam_slick, aa, umbra, laluz, arrow

t     = aa.t
xdim  = aa.xdim
ydim  = aa.ydim
txdim = t*xdim
tydim = t*ydim
				    ;Get image name.
labels = azam_image_names(aa)
iname = labels( pop_cult( labels, 1, title='click on one' ) )
if iname eq 'continue' then return
				    ;Print instructions.
azam_message, aa, 'left(faster) middle(slower) right(stop)'

				    ;Set hidden pixmap windows.
window, /free, /pixmap, xsize=txdim, ysize=tydim
w2 = !d.window
tv, aa.img0, 0, 0

window, /free, /pixmap, xsize=txdim, ysize=tydim
w3 = !d.window
tv, aa.img1, 0, 0

img4 = azam_image( iname, aa, umbra, laluz, arrow )
window, /free, /pixmap, xsize=txdim, ysize=tydim
w4 = !d.window
tv, img4, 0, 0
				    ;Blink images.
				    ;(Same method as flick.pro).
rate = 2.25
faster = 0
x0 = 0
y0 = 0
while 1 do begin
				    ;Loop for time interval.
	first = 1
	t0 = systime(1)
	while  systime(1)-t0 lt 1./rate  do begin

				    ;Do computed field cursors.
		azam_cursor, aa, xerase, yerase $
		,   undef,   undef,      w2,      w3,      w4 $
		,   undef,   undef,   undef,   undef,    img4 $
		,   undef,   undef, eraser0, eraser1, eraser4 $
		, xc, yc, state $
		, likely=likely $
		, maybe=[aa.win0,aa.win1]

				    ;Process mouse button state.
		case  state > aa.bs  of
			0: faster = faster mod 8
			1: if faster eq 0 then  faster = 1
			2: if faster eq 0 then  faster = 2
			4: goto, break0
			else:
		end
				   ;Set sub array locations.
		if  first  and  xc ge 0  then begin
			x0 = 0 > ( (t*xc-90) < (txdim-180) )
			y0 = 0 > ( (t*yc-90) < (tydim-180) )
		end
		first = 0
		x1 = (x0+179) < (txdim-1)
		y1 = (y0+179) < (tydim-1)

				    ;Copy flick image from pixmap window.
		wset, aa.win0
		device, copy=[x0,y0,x1-x0+1,y1-y0+1,x0,y0,w4]
		wset, aa.win1
		device, copy=[x0,y0,x1-x0+1,y1-y0+1,x0,y0,w4]
	end
				    ;Loop for time interval.
	t0 = systime(1)
	while  systime(1)-t0 lt 1./rate  do begin

				    ;Do computed field cursors.
		azam_cursor, aa, xerase, yerase $
		,   undef,   undef,      w2,      w3,      w4 $
		,   undef,   undef,   undef,   undef,    img4 $
		,   undef,   undef, eraser0, eraser1, eraser4 $
		, xc, yc, state $
		, likely=likely $
		, maybe=[aa.win0,aa.win1]

				    ;Process mouse button state.
		case  state > aa.bs  of
			0: faster = faster mod 8
			1: if faster eq 0 then  faster = 1
			2: if faster eq 0 then  faster = 2
			4: goto, break0
			else:
		end
				    ;Copy flick image from pixmap window.
		wset, aa.win0
		device, copy=[x0,y0,x1-x0+1,y1-y0+1,x0,y0,w2]
		wset, aa.win1
		device, copy=[x0,y0,x1-x0+1,y1-y0+1,x0,y0,w3]
	end
				    ;Adjust cycle rate.
	if faster ne 0 then begin
		if faster eq 1 then  rate = rate*1.5
		if faster eq 2 then  rate = rate/1.5
		faster = 8
	end
end
break0:
				    ;Delete extra windows.
wdelete, w2, w3, w4
				    ;Restore display windows.
tw, aa.win0, aa.img0, 0, 0
tw, aa.win1, aa.img1, 0, 0

end
;------------------------------------------------------------------------------
;
;	procedure:  azam_spectra
;
;	purpose:  display data spectra.
;
;------------------------------------------------------------------------------
pro azam_spectra, aa, umbra, laluz, arrow

				    ;Ask if user wants new file.
if aa.spectra ne '' then $
if pop_cult(['yes','no'],title='Want same file') then aa.spectra=''

				    ;Get file path.
if aa.spectra eq '' then begin
	path = azam_text_in( aa, 'Enter path to spectra file')
	if path eq '' or path eq 'q' then return
end else begin
	path = aa.spectra
end
				    ;Try open 10 times.
try = 0
on_ioerror, ioerror
if 0 then begin
	ioerror: print, !err_string
	if try eq 10 then return
	try = try+1
	wait, .1
end
				    ;Open file.
openr, /get_lun, unit, path
				    ;Save path.
aa.spectra = path
				    ;Open window for plots.
sz = 300
window, /free, xsize=sz, ysize=sz, title='I' $
, xpos=1154-2*(sz+10), ypos=30+1*(sz+30)
wi = !d.window
window, /free, xsize=sz, ysize=sz, title='Q' $
, xpos=1154-1*(sz+10), ypos=30+1*(sz+30)
wq = !d.window
window, /free, xsize=sz, ysize=sz, title='U' $
, xpos=1154-2*(sz+10), ypos=30+0*(sz+30)
wu = !d.window
window, /free, xsize=sz, ysize=sz, title='V' $
, xpos=1154-1*(sz+10), ypos=30+0*(sz+30)
wv = !d.window
				    ;Read header & first scan header.
on_ioerror, error0
hdr = lonarr(256)
readu, unit, hdr
				    ;Set variables nmstep numx numy.
nmstep = hdr(28)
numx   = hdr(42)
numy   = hdr(43)
				    ;Get first scan number.
snum0  = hdr(139)
				    ;Slit step record size in bytes.
rcd = 512+4*numx*numy*2
				    ;x axis ramp array.
vecx  = indgen(numx)
				    ;Old cursor postions.
count = 0
xsav = -1
ysav = -1
				    ;Print instructions.
azam_message, aa, 'left() middle() right(stop)'

				    ;Infinite loop.
while 1 do begin
	infinity:
				    ;Do computed field cursors.
	azam_cursor, aa, xerase, yerase $
	, aa.win0, aa.win1,   undef,   undef,   undef $
	,   undef,   undef,   undef,   undef,   undef $
	, eraser0, eraser1,   undef,   undef,   undef $
	, xc, yc, state $
	, likely=likely $
	, maybe=[aa.win0,aa.win1]
				    ;Process mouse button state.
	case  state > aa.bs  of
		0:
		1:
		2:
		4: goto, break0
		else:
	end
				    ;Get spectra coordinates.
	xs = -1
	ys = -1
	if xc ge 0 then if aa.xy5000(xc,yc) ge 0 then begin
		xs = aa.xy5000(xc,yc) mod 5000
		ys = aa.xy5000(xc,yc)/5000
	end
				    ;Check if spectra position unchanged.
	if xs eq xsav and ys eq ysav then begin
		count = (count+1) < 100
		if count eq 100 then  wait, .1
		goto, infinity
	end
				    ;Save spectra position.
	count = 0
	xsav = xs
	ysav = ys
				    ;Erase windows if off data.
	if xs lt 0 then begin
		wset, wi  &  erase, 0
		wset, wq  &  erase, 0
		wset, wu  &  erase, 0
		wset, wv  &  erase, 0
		goto, infinity
	end
				    ;Set offset to spectra.
	offset = 512+(xs-snum0)*rcd+512
				    ;Associate variable to spectra.
	as = assoc( unit, vecx, offset )

				    ;Read profiles.
	iiii = long(as(ys)) and '0000FFFF'XL
	qqqq = as(   numy+ys )
	uuuu = as( 2*numy+ys )
	vvvv = as( 3*numy+ys )
				    ;Plot i profile.
	wset, wi  &  plot, iiii
				    ;Plot q and u profiles to same scale.
	mx = max(abs([qqqq,uuuu]))

	wset, wq
	plot, [0,numx-1], [-mx,mx], /nodata
	plots, vecx, qqqq

	wset, wu
	plot, [0,numx-1], [-mx,mx], /nodata
	plots, vecx, uuuu
				    ;Plot v profile.
	wset, wv
	mx = max(abs(vvvv))
	plot, [0,numx-1], [-mx,mx], /nodata
	plots, vecx, vvvv
end
				    ;I/O error exit.
error0: print, !err_string
aa.spectra=''
				    ;Normal exit.
break0:
				    ;Delete windows.
wdelete, wi, wq, wu, wv
				    ;Close file.
free_lun, unit
				    ;Restore display windows.
tw, aa.win0, aa.img0, 0, 0
tw, aa.win1, aa.img1, 0, 0

end

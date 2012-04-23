pro azam_blink, umbra, laluz, arrow, aa
;+
;
;	procedure:  azam_blink
;
;	purpose:  do blinking for 'azam.pro'
;
;	author:  paul@ncar, 6/93	(minor mod's by rob@ncar)
;
;=============================================================================
;
;       Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:	azam_blink, umbra, laluz, arrow, aa"
	print
	print, "	Do blinking for 'azam.pro'."
	print
	print, "	Arguments (input)"
	print, "		umbra	- where array to highlight umbra"
	print, "		laluz	- where array to highlight images"
	print, "		arrow	- arrow point structure"
	print, "		aa	- azam data set structure"
	print
	return
endif
;-
				    ;Display parameters
t     = aa.t
xdim  = aa.xdim
ydim  = aa.ydim
txdim = t*xdim
tydim = t*ydim
				    ;Names of azam images.
labels = azam_image_names(aa)

				    ;Pop up menu for two choices.
LL = labels( pop_cult( labels, 2, title='click on two' ) )
if  LL(1) eq 'continue'  then return

				    ;Do custom request last.
if strmid(LL(0),0,3) eq 'SET' then LL = reverse(LL)

				    ;Set hidden pixmap windows.
window, /free, /pixmap, xsize=txdim, ysize=tydim
w2 = !d.window
img2 = azam_image( LL(0), aa, umbra, laluz, arrow )
tv, img2, 0, 0

window, /free, /pixmap, xsize=txdim, ysize=tydim
w3 = !d.window
img3 = azam_image( LL(1), aa, umbra, laluz, arrow )
tv, img3, 0, 0
				    ;Open window for blinking.
window, /free, xsize=aa.xsize, ysize=tydim $
, xpos=1140-aa.xsize, ypos=40
w4 = !d.window
				    ;Show ascii image
wshow, aa.wina
				    ;Print instructions.
azam_message, aa, 'left(faster) middle(slower) right(stop)'

				    ;Blink images.
				    ;(Same method as flick.pro in User's
				    ;Library).
rate = 2.25
faster = 0
while 1 do begin
				    ;Copy blink image from pixmap window.
	t0 = systime(1)
	wset, w4  &  device, copy=[0,0,txdim,tydim,0,0,w2]

				    ;Loop till time interval.
	while  systime(1)-t0 lt 1./rate  do begin

				    ;Do computed cursor.
		azam_cursor, aa, xerase, yerase $
		, aa.win0, aa.win1,      w2,      w3,      w4 $
		,   undef,   undef,    img2,    img3,    img2 $
		, eraser0, eraser1, eraser2, eraser3, eraser2 $
		, xc, yc, state $
		, likely=likely $
		, maybe=[aa.win0,aa.win1,w4]

				    ;Process mouse buttons.
		case  state > aa.bs  of
			0: faster = faster mod 8
			1: if faster eq 0 then  faster = 1
			2: if faster eq 0 then  faster = 2
			4: goto, break0
			else:
		end
	end
				    ;Copy blink image from pixmap window.
	t0 = systime(1)
	wset, w4  &  device, copy=[0,0,txdim,tydim,0,0,w3]

				    ;Loop till time interval.
	while  systime(1)-t0 lt 1./rate  do begin

				    ;Do computed cursor.
		azam_cursor, aa, xerase, yerase $
		, aa.win0, aa.win1,      w2,      w3,      w4 $
		,   undef,   undef,    img2,    img3,    img3 $
		, eraser0, eraser1, eraser2, eraser3, eraser3 $
		, xc, yc, state $
		, likely=likely $
		, maybe=[aa.win0,aa.win1,w4]

				    ;Process mouse buttons.
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
		if faster eq 1 then rate = rate*1.5
		if faster eq 2 then rate = rate/1.5
		faster = 8
	end
end
break0:
				    ;Delete extra windows.
wdelete, w2, w3, w4
print
				    ;Check if user wants image left on screen.
if 1-pop_cult(['yes','no'],title='Want images left on ?') then begin

	window, /free, xsize=txdim, ysize=tydim $
	, xpos=0, ypos=900-tydim, title=LL(0)
	tv, img2, 0, 0

	window, /free, xsize=txdim, ysize=tydim $
	, xpos=20, ypos=900-(tydim+20), title=LL(1)
	tv, img3, 0, 0
end
				    ;Restore display windows.
wset, aa.win0  &  tv, aa.img0, 0, 0
wset, aa.win1  &  tv, aa.img1, 0, 0

end

pro azam_profiles, umbra, laluz, arrow, aa
;+
;
;	procedure:  azam_profiles
;
;	purpose:  does profiles for 'azam.pro'
;
;	author:  paul@ncar, 11/93	(minor mod's by rob@ncar)
;		 (heavy revised  $IDL_DIR/lib/userlib/porfiles.pro )
;
;=============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	azam_profiles, umbra, laluz, arrow, aa"
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
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
				    ;Display parameters
				    ;
t      = aa.t
xdim   = aa.xdim
ydim   = aa.ydim
win0   = aa.win0
win1   = aa.win1
red    = aa.red
yellow = aa.yellow
txdim  = t*xdim
tydim  = t*ydim
				    ;Initialize some variables.
xprt = -1
yprt = -1
vecx = findgen(xdim)
vecy = findgen(ydim)
				    ;Cross length.
tickl = 0.025
				    ;Compute 2D data images and extrema.
minv = fltarr(2)
maxv = fltarr(2)
data = fltarr(xdim,ydim,2,/nozero)
azam_2d_data, aa.name0, aa, tmp
data(*,*,0) = tmp
minv(0) = min( tmp, max=mx )  &  maxv(0) = mx
azam_2d_data, aa.name1, aa, tmp
data(*,*,1) = tmp
minv(1) = min( tmp, max=mx )  &  maxv(1) = mx

				    ;Image names.
wname = [aa.name0,aa.name1]

				    ;Instructions.
azam_message, aa $
, 'MOUSE: Left rows/columns; center image/image; right exit.'

				    ;Open window for profiles.
window, /free, xsize=640, ysize=512, xpos=1144-640, ypos=30
w1 = !d.window
window, /free, xsize=640, ysize=512, /pixmap
w2 = !d.window
wshow, aa.wina
				    ;Mode = 0 for rows, 1 for cols
mode = 0
old_mode = -1
wdx = 0
				    ;Infinite loop to left mouse button
				    ;is pressed.
while 1 do begin
				    ;Do computed field cursor.
	repeat  azam_cursor, aa, xerase, yerase $
		,    win0,    win1,   undef,   undef,   undef $
		,   undef,   undef,   undef,   undef,   undef $
		, eraser0, eraser1,   undef,   undef,   undef $
		, x, y, state $
		, likely=likely $
		, maybe=[win0,win1] $
	until x ne -1

	if state ne 0 then begin

		old_mode = -1
				    ;Wait till mouse buttons are up.
		repeat  cursor, xx, yy, /device, /nowait  until  !err eq 0

		case state of
				    ;Toggle mode.
		1: mode = 1-mode
				    ;Toggle display images.
		2: $
		    begin
			xprt = -1
			yprt = -1
			wdx = (wdx+1) mod 2
		    end
				    ;Return if left button was pressed.
		4: $
		    begin
			wdelete, w1, w2
			wset, win0  &  tv, aa.img0, 0, 0
			wset, win1  &  tv, aa.img1, 0, 0
			return
		    end
		else:
		end
	end
				    ;Toggle row/column scales.
	if mode ne old_mode then begin
		xprt = -1
		old_mode = mode
		if mode then begin
			wset, w2
			plot, [minv(wdx),maxv(wdx)], [0,ydim-1], /nodata $
			, title=wname(wdx)+' Column Profile'
			wset, w1
			plot, [minv(wdx),maxv(wdx)], [0,ydim-1], /nodata
			crossx = [-tickl, tickl]*(maxv(wdx)-minv(wdx))
			crossy = [-tickl, tickl]*ydim
		end else begin
			wset, w2
			plot, [0,aa.xdim-1], [minv(wdx),maxv(wdx)], /nodata $
			, title=wname(wdx)+' Row Profile'
			wset, w1
			plot, [0,aa.xdim-1], [minv(wdx),maxv(wdx)], /nodata
			crossx = [-tickl, tickl]*xdim
			crossy = [-tickl, tickl]*(maxv(wdx)-minv(wdx))
		end
	end
				    ;Check if image coordinates changed.
	if  xprt ne x  or  yprt ne y  then begin

				    ;Save image coordimates.
		xprt = x
		yprt = y
				    ;Refresh window.
		wset, w1
		device, copy=[0,0,640,512,0,0,w2]

				    ;Plot column or row data.
		ixy  = data(x,y,wdx)
		if mode then begin
			plots, data(x,*,wdx), vecy, color=yellow
			plots, crossx+ixy, [y,y],   color=red
			plots, [ixy,ixy], crossy+y, color=red
		end else begin
			plots, vecx, data(*,y,wdx), color=yellow
			plots, [x,x], crossy+ixy,   color=red
			plots, crossx+x, [ixy,ixy], color=red
		end
	end
end

end

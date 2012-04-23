pro field_cursor, wdx, w_on, xi, yi, xc, yc, xasp, yasp, leave, c
;+
;
;	procedure: field_cursor
;
;	purpose:  Run interactive cursor of field_plot.pro displays.
;		  Intended to be called by other programs.
;
;	author:  paul@ncar, 5/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if  n_params() eq 0  then begin
	print
	print, "usage:	field_cursor, wdx, w_on $"
	print, "		, xi, yi, xc, yc, xasp, yasp $"
	print, "		, leave, c"
	print, "						-or-"
	print, "	field_cursor, wdx, w_on $"
	print, "		, xi, yi, xc, yc, xasp, yasp $"
	print, "		, leave, b"
	print
	print, "	Run interactive cursor of field_plot.pro displays."
	print
	print, "	Arguments"
	print, "		wdx	- array with 2 display window numbers"
	print, "		w_on	- 0 or 1 index into wdx (def=0)"
	print, "		xi	- 0 or 1 image in x direction (def=0)"
	print, "		yi	- 0 or 1 image in y direction (def=1)"
	print, "		xc	- returned idl x index into image"
	print, "		yc	- returned idl y index into image"
	print, "		xasp	- returned asp x index into image"
	print, "		yasp	- returned asp y index into image"
	print, "		leave	- !ERR value on exit"
	print, "		c	- structure of images and directory"
	print
	return
endif
;-
		    ;
		    ;Recall from field_plot.pro some display parameters.
		    ;
xmrg = (124-c.xdim) > 24
xfrm = xmrg+c.xdim
ymrg = (124-c.ydim) > 24
yfrm = ymrg+c.ydim
		    ;
		    ;Form 2D array with original asp point numbers.
		    ;
xrast = replicate(-1L,c.xdim,c.ydim)  &  xrast( c.pxy ) = c.xpnt( c.vec_pxy )
yrast = replicate(-1L,c.xdim,c.ydim)  &  yrast( c.pxy ) = c.ypnt( c.vec_pxy )
		    ;
		    ;Initialize undefined arguments.
		    ;
if  n_elements(xc  ) eq 0  then  xc   = c.xdim/2
if  n_elements(yc  ) eq 0  then  yc   = c.ydim/2
if  n_elements(xi  ) eq 0  then  xi   = 0
if  n_elements(yi  ) eq 0  then  yi   = 1
if  n_elements(w_on) eq 0  then  w_on = 0
		    ;
		    ;Bring forward local frame display.
		    ;Set cursor on current (xc,yc).
		    ;
wset,  wdx(w_on)
wshow, wdx(w_on)
tvcrs, xi*xfrm+xmrg+xc, yi*yfrm+ymrg+yc
		    ;
ones = replicate(1.,100,ymrg)
ones(0,0) = 0.
		    ;
		    ;Loop till left or right mouse
		    ;button is clicked.
		    ;
leave = 0
while  leave eq 0  do begin
		    ;
		    ;Loop waiting for change in mouse.
		    ;CURSOR procedure has a bug which sometimes 
		    ;returns (-1,-1).
		    ;
	xxxx = -1
	yyyy = -1
	while  xxxx eq -1  and  yyyy eq -1  do begin
		cursor, xxxx, yyyy, /change, /device
	end
	leave = !err
	if  leave eq 2  then begin
		leave = 0
		    ;
		    ;Swap display windows.
		    ;
		tvasp, ones, /gray
		w_on = (w_on+1) mod 2
		wset,  wdx(w_on)
		wshow, wdx(w_on)
		tvcrs, xi*xfrm+xmrg+xc, yi*yfrm+ymrg+yc
	end
		    ;
		    ;Index into idl image.
		    ;
	xc = (xxxx mod xfrm)-xmrg
	yc = (yyyy mod yfrm)-ymrg
		    ;
		    ;Image frame number in x and y direction.
		    ;
	xi = xxxx/xfrm	
	yi = yyyy/yfrm
		    ;
		    ;Default (xasp,yasp) in case cursor in not on data.
		    ;
	xasp = -1
	yasp = -1
		    ;
		    ;White background or (xasp,yasp) to
		    ;be printed in lower left.
		    ;
	tvasp, ones, /gray
		    ;
		    ;If (xc,yc) is in image range, set and display (xasp,yasp).
		    ;
	if   xc ge 0  and  xc lt c.xdim $
	and  yc ge 0  and  yc lt c.ydim  then begin
		xasp = xrast(xc,yc)
		yasp = yrast(xc,yc)
		if  xasp ge 0  then begin
			xyouts, 0,4, string(xasp,yasp,format='(2i5)') $
				, color=0, /device, charsize=1.5
		end
	end
end
		    ;
		    ;Return reasonable positions within image range.
		    ;Note: (xasp,yasp) returned (-1,-1) if cursor is off data.
		    ;
if  xi gt 1  then begin
	xi = 1
	xc = c.xdim-1
end
if  yi gt 1  then begin
	yi = 1
	yc = c.ydim-1
end
xc = 0 > xc < c.xdim-1
yc = 0 > yc < c.ydim-1
		    ;
end

pro wrap_key, xloc, yloc, rad2, kflag, type, aratio=aratio, xwin=xwin
;+
;
;	procedure:  wrap_key
;
;	purpose:  display an annulus key
;
;	author:  rob@ncar, 8/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 5 then begin
	print
	print, "usage:  wrap_key, xloc, yloc, rad2, kflag, type"
	print
	print, "	Display an annulus key."
	print
	print, "	Arguments"
	print, "	    xloc,yloc	- location of lower left in NDC"
	print, "		          for PostScript, pixels for X"
	print, "	    rad2	- outer radius of annulus in NDC"
	print, "		           in X-dimension for PostScript"
	print, "		           (radius for X windows output"
	print, "		            is hardwired)"
	print, "	    kflag	- key flag"
	print, "		           1 = 180 degrees"
	print, "		           2 = 360 degrees"
	print, "	    type	- see wrap_scale.pro 'type'"
	print
	print, "	Keywords"
	print, "	    aratio	- aspect ratio of output device"
	print, "		           for PS output (X/Y;"
	print, "		           def=11.0/8.5 <--Landscape)"
	print, "	    xwin	- output to X window"
	print, "		           def=output to PostScript)"
	print
	print
	print, "   ex:  wrap_key, 0.1, 0.1, 0.02, 1, 5"
	print
	return
endif
;-
;
;	Specify common block.
;
@wrap.com
;
;	Set parameters.
;
factor = 180 / !pi
if n_elements(aratio) eq 0 then aratio = 11.0 / 8.5
;
;	Create annulus.
;
;-------------------------- ONE-SIDED -----------------------------------------
;
;	Choose size in pixels.
;
case kflag of

1: begin

;
;	Specify size in device coordinates.
;
	xsize = rad2			; for PostScript output
	ysize = (rad2 * 2.0) * aratio
;
	xpix = 51			; (these dimensions fixed for X)
	ypix = 101
	rpix1 = 25			; inner radius
	rpix2 = 50			; outer radius
;
;	Create image array and initialize to background color.
;
	ann = bytarr(xpix, ypix)
;
	if keyword_set(xwin) then begin
		ann(*,*) = ix_back
	endif else begin
		ann(*,*) = ix_text
	endelse
;
;	Loop for all values in array.
;
	for i = 0, xpix - 1 do begin
		for j = 0, ypix - 1 do begin

;			Calculate rectangular coordinates.
			xc = i
			yc = j - rpix2

;			Check radius and color pixel if in annulus.
			rad = sqrt(xc * xc + yc * yc)

			if (rad ge rpix1) and (rad le rpix2) then begin
				theta = asin(yc / rad)
				theta = theta * factor * (-1.0) + 90.0
				if theta ne 180.0 then $
				       color_pix, ann, i, j, type, theta, kflag
			endif
  		endfor
	endfor

   end
;
;-------------------------- TWO-SIDED -----------------------------------------
;
2: begin

;
;	Specify size in device coordinates.
;
	xsize = rad2 * 2.0		; for PostScript output
	ysize = xsize * aratio
;
	xpix = 101			; (these dimensions fixed for X)
	ypix = 101
	rpix1 = 25			; inner radius
	rpix2 = 50			; outer radius
;
;	Create image array and initialize to background color.
;
ann = bytarr(xpix, ypix)
if keyword_set(xwin) then begin
	ann(*,*) = ix_back
endif else begin
	ann(*,*) = ix_text
endelse
;
;	Loop for all values in array.
;
for i = 0, xpix - 1 do begin
  for j = 0, ypix - 1 do begin

;	Calculate rectangular coordinates.
	xc = i - rpix2
	yc = j - rpix2

;	Check radius and color pixel if in annulus.
	rad = sqrt(xc * xc + yc * yc)

	if (rad ge rpix1) and (rad le rpix2) then begin

		; upper right -- 0 to 90
		if (xc ge 0) and (yc ge 0) then begin
			theta = asin(yc / rad)
			theta = theta * factor
			color_pix, ann, i, j, type, theta, kflag

		; upper left -- 90 to 180
		endif else if (xc lt 0) and (yc ge 0) then begin
			theta = asin(yc / rad)
			theta = 180.0 - theta * factor
			color_pix, ann, i, j, type, theta, kflag

		; lower left -- 180 to 270
		endif else if (xc lt 0) and (yc lt 0) then begin
			theta = asin(yc / rad)
			theta = 180.0 - theta * factor
			color_pix, ann, i, j, type, theta, kflag

		; lower right -- 270 to 360
		endif else begin
			theta = asin(yc / rad)
			theta = 360.0 + theta * factor
			color_pix, ann, i, j, type, theta, kflag

		endelse

	endif
  endfor
endfor

end

endcase
;
;------------------------------------------
;
;	Display annulus.
;
if keyword_set(xwin) then begin
	tv, ann, xloc, yloc
endif else begin
	tv, ann, xloc, yloc, xsize=xsize, ysize=ysize, /normal
endelse
;
;	Label annulus.
;

;
;	Done.
;
end

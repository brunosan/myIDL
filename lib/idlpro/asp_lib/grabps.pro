pro grabps, fileps, dummy, rb=rb
;+
;
;	procedure:  grabps
;
;	purpose:  Grab the image in the current X window into a
;		  PostScript file, converting the colormap to greyscale.
;
;	usage:  grabps [,fileps]
;
;	author:  rob@ncar, 3/92
;
;	notes:  1. the window being captured must be visible
;		2. do REBIN without interpolation (make it an option ?)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() gt 1 then begin
	print
	print, "usage:  grabps [,fileps]"
	print
	print, "	Grab the image in the current X window into a"
	print, "	PostScript file, converting the colormap to greyscale."
	print
	print, "	Arguments"
	print, "	    fileps	- output PostScript file (def=idl.ps)"
	print
	print, "	Keywords"
	print, "	        rb	- set to double the image dim's"
	print
	return
endif
;-
;
;	Set parameters.
;
true = 1
false = 0
do_rebin = false
if keyword_set(rb) then do_rebin = true
if n_params() eq 0 then fileps = 'idl.ps'
;
;	Make sure that the device type is X Windows.
;
set_plot, 'x'
;
;	Grab the image from the current window.
;
print, 'Grabbing the image...'
image = tvrd()
;
;	Optionally rebin the image.
;
if do_rebin then begin
	print, 'Rebinning the image...'
	s = size(image)
	image = rebin(image, s(1)*2, s(2)*2)
endif
;
;	Grab the color table and convert it to greyscale.
;
print, 'Grabbing the color table...'
tvlct, r, g, b, /get
bwtable = .3*r + .59*g + .11*b
bwtable = bytscl(bwtable)
;
;	Change the device type to high-resolution PostScript.
;
set_plot, 'ps'
xoffset = 1.0
yoffset = 1.0
device, bits_per_pixel=8, file=fileps, $
	/inches, $
	xoffset=xoffset, yoffset=yoffset, $
	xsize=8.5 - xoffset*2, ysize=11.0 - yoffset*2
;
;	Plot the image in PS; note the fancy indexing of the greyscale.
;
print, 'Writing to output file "' + fileps + '"...'
tv, bwtable(image)
;
;	Flush the PS plot and return to X Windows.
;
print, 'Returning to X Windows...'
device, /close
set_plot, 'x'
;
;	Done.
;
end

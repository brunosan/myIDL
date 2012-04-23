function notch_p, image, xlen, ylen, x1, y1, x2, y2, ixc
;+
;
;	function:  notch_p
;
;	purpose:  notch out a portion of an image
;
;	author:  rob@ncar, 1/93
;
;	notes:  - this may be used to make a hole for a key in an
;		  image going to a PostScript file
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 8 then begin
	print
	print, "usage:  im = notch_p(image, xlen, ylen, x1, y1, x2, y2, ixc)"
	print
	print, "	Notch out a portion of an image."
	print
	print, "	Arguments"
	print, "	    image	- input byte image (ready for tv)"
	print, "	    xlen,ylen	- image dimensions in NDC units"
	print, "	    x1,y1	- lower left corner for notch (NDC)"
	print, "	    x2,y2	- upper right corner for notch (NDC)"
	print, "	     ixc	- color map index to fill notch with"
	print
	print, "	    For x1,y1,x2,y2:  (0,0) is lower left of image."
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return, 0
endif
;-
;
;	Get actual dimensions of image.
;
xlen_data = sizeof(image, 1)
ylen_data = sizeof(image, 2)
;
;	Find image indices of notch corresponding to the NDC coordinates.
;
xrat = (xlen_data - 1) / float(xlen)
yrat = (ylen_data - 1) / float(ylen)
x1_data = fixr(x1 * xrat)
x2_data = fixr(x2 * xrat)
y1_data = fixr(y1 * yrat)
y2_data = fixr(y2 * yrat)
;
;	Notch the image.
;
im = image
im(x1_data:x2_data, y1_data:y2_data) = ixc
;
;	Return notched image.
;
return, im
end

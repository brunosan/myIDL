pro pltiiiix, im1, im2, im3, im4, image1, image2, image3, image4, $
	second=second
;+
;
;	procedure:  pltiiiix
;
;	purpose:  plot images obtained from getiiii.pro in X
;
;
;		Continuum Intensity	Field Magnitude (Gauss)
;
;		Azimuth (degrees)	Inclination (degrees)
;
;
;	date:  1/93, rob@ncar
;
;	first run of session:
;	 pltiiiix, cct, fld, azm, incl, image1, image2, image3, image4
;		(image1-4 are output for second run)
;
;	second and following runs:
;	 pltiiiix, cct, fld, azm, incl, image1, image2, image3, image4, /second
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 8 then begin
	print
	print, "usage:  pltiiiix, im1, im2, im3, im4, $"
	print, "                  image1, image2, image3, image4 [, /second]"
	print
	print, "	Plot images obtained from getiiii.pro in X."
	print
	return
endif
;-
;
;	Install special color table.
;
@wrap.com
newwct, 1, nd2_col=[255,255,255], back_col=[255,255,255]
;
;	Convert the images to byte indices using special color table.
;
if not keyword_set(second) then begin
;
	image1 = wrap_scalew(im1, 1, 0.0, max(im1))
	image2 = wrap_scalew(im2, 3, 0.0, 3500.0)
	image3 = wrap_scalew(im3, 4, 0.0, 360.0)
	image4 = wrap_scalew(im4, 3, 0.0, 180.0)
endif
;
;----------------------
;
;	Set plotting parameters.
;
xlen = sizeof(image1, 1)
ylen = sizeof(image1, 2)
border = 20
xtot = xlen * 2 + border * 3
ytot = ylen * 2 + border * 3
;window, xsize=xtot, ysize=ytot, /free
x = border * 2 + xlen
y = border * 2 + ylen
;
;	Plot images.
;
tv, image1, border, y
tv, image2, x, y
tv, image3, border, border
tv, image4, x, border
;
;	Done.
;
end


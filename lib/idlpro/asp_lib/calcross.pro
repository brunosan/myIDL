pro calcross, aim, bim, xst, xend, yst, yend, bn, diff, plot=plot
;+
;
;	procedure:  calcross
;
;	purpose:  Cross-correlate two images in the wavelength direction,
;		  fit the shifts as a function of position along the slit
;		  with a parabola, then Fourier shift the images.
;
;	author:  lites@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 8 then begin
	print
	print, "usage:  calcross, aim, bim, xst, xend, yst, yend, $"
	print, "		  bn, diff"
	print
	print, "	Cross-correlate in the wavelength direction"
	print, "	image bim with image aim, fit the shifts as a"
	print, "	function of position along the slit with a parabola,"
	print, "	then Fourier shift bim with respect to aim."
	print
	print, "	Arguments (input)"
	print, "		aim	- a-channel gain-corrected Stokes I"
	print, "			  image (not shifted)"
	print, "		bim	- b-channel gain-corrected Stokes I"
	print, "			  image (shifted)"
	print, "		xst,	- start and end pixel for cross-"
	print, "		 xend	  correlation of wavelength"
	print, "		yst,	- start and end pixel for cross-"
	print, "		 yend	  correlation along slit
	print
	print, "	Arguments (output)"
	print, "		bim	- interpolated b-channel spectral"
	print, "			  image, appropriately shifted in both"
	print, "			  dimensions to match a-channel;"
	print, "			  array aim is not changed"
	print, "		bn	- overall multiplicative renormal-"
	print, "			  ization constant for b-channel"
	print, "		diff	- multiplicative correction array for"
	print, "			  b-channel to remove slowly-varying"
	print, "			  wavelength slope differences"
	print, "			  between a,b channels"
	print
	print, "	Keywords"
	print, "		plot	- if set, produce run-time plots"
	print, "			  (def=don't produce plots)"
	print
	return
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
do_plot = false
if keyword_set(plot) then do_plot = true

;  get dimensions of arrays (assumed to be the same for both)
nx = sizeof(aim, 1)
ny = sizeof(aim, 2)
nx1 = nx-1
ny1 = ny-1

;  arrays containing averages removed from data before transforming
avga = fltarr(ny)
avgb = avga
;  average spectral profile of a=channel for fitting shifts below
avgwl = fltarr(nx)
avgwl(*) = 0.

;  find average over centers of image, then renormalize intensity of b-array
;  to average of a-array.  Temporarily use avga, avgb arrays to improve
;  numerical accuracy.  Avoid columns near beginning, end because of
;  occasional glitches there.
fnx = float(xend-xst+1)
fny = float(yend-yst+1)
for j = 0,ny1 do avga(j) = total(aim(xst:xend,j))/fnx
for j = 0,ny1 do avgb(j) = total(bim(xst:xend,j))/fnx
anorm = total(avga(yst:yend))/fny
bnorm = total(avgb(yst:yend))/fny
;  get renormalization constant to multiply times b-channel
bn = anorm/bnorm
bim = bim*bn
;  renormalize avgb
avgb = avgb*bn

;temporary insert to display difference of intensity-equalized raw images
temm = aim-bim
temm = (temm < (-2000)) > 2000		; clip to range -2000 to 2000
if do_plot then tvscl,temm,256,0


;  find average wavelength profile
for i = xst,xend do begin
  avgwl(i) = total(aim(i,yst:yend))/fny
endfor

;  Find rows with intensity greater than some threshold.
;  This avoids problem areas in spot umbrae and hairlines.
;  Current threshold value is the average intensity.
xy = indgen(ny)
avmn = total(avga)/float(n_elements(avga))
;  avoid top and bottom of array
avgaa = avga
avgaa(0:yst-1) = 0.
avgaa(yend+1:ny1) = 0.
whry = where(avgaa gt avmn)

;  Find columns that avoid spectral lines
avmn = total(avgwl(xst:xend))/fnx
whrx = where(avgwl gt avmn)

;  equalize the wavelength slope of the two images by fitting the
;  slope of the continuum for each row, then fitting smoothed curves
;  to coefficients along the slit
;  get fit coefficients to the difference of the images for each slit position,
;  avoiding the lines
xx = indgen(nx)
delt = fltarr(nx)
diff = (aim-bim)
coefwl = dblarr(2,ny)
;  fit continuum wavelengths of difference
for j = yst,yend do coefwl(*,j) = poly_fit(xx(whrx),diff(whrx,j),1)
;  fit curves to coefficients, avoiding hairlines and spots
coef0 = poly_fit(xy(whry),coefwl(0,whry),1)
coef1 = poly_fit(xy(whry),coefwl(1,whry),1)
;  replace coefwl array with fits
coefwl(0,*) = poly(xy,coef0)
coefwl(1,*) = poly(xy,coef1)
;  get average of b-channel, excluding hairlines, spots, and spectral lines
for j = 0,ny1 do avgb(j) = total(bim(whrx,j))/float(n_elements(whrx))
bnorm = total(avgb(whry))/float(n_elements(whry))
;  rescale the b-channel image to equalize
for j = 0,ny1 do begin
  delt = poly(xx,coefwl(*,j))
  diff(*,j) = 1. + delt(*)/bnorm
endfor
bim = bim*diff

end

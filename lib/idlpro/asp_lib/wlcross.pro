pro wlcross, aim, bim, xst, xend, yst, yend, ixst, nsearch, $
	wdel, sdel, wlfit, slfit, bn, diff
;+
;
;	procedure:  wlcross
;
;	purpose:  Cross-correlate in the wavelength direction image bim with
;		  image aim, fit the shifts as a function of position along
;		  the slit with a parabola, then Fourier shift bim with
;		  respect to aim.
;
;	author:  lites@ncar, 4/93	(speed/formatting mod's by rob@ncar)
;
;	notes:  WARNING - 'ixst' assumes wavelengths HAVE been flipped !!!
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 14 then begin
	print
	print, "usage:  wlcross, aim, bim, xst, xend, yst, yend, ixst, $"
	print, "		 nsearch, wdel, sdel, wlfit, slfit, bn, diff"
	print
	print, "	Cross-correlate in the wavelength direction image bim"
	print, "	bim with image aim, fit the shifts as a function of"
	print, "	position along the slit with a parabola, then Fourier"
	print, "	shift bim with respect to aim."
	print
	print, "	Arguments (input)"
	print, "		aim	- a-channel gain-corrected Stokes I"
	print, "			  image (not shifted)"
	print, "		bim	- b-channel gain-corrected Stokes I"
	print, "			  image (shifted)"
	print, "		xst,	- start and end  pixel for cross-"
	print, "		 xend	  correlation of wavelength"
	print, "		yst,	- start and end pixel for cross-"
	print, "		 yend	  correlation along slit"
	print, "		ixst	- number of non-data columns on"
	print, "			  *right* side of the spectra"
	print, "		nsearch	- number of pixels either side to"
	print, "			  search for maximum of cross-"
	print, "			  correlation"
	print
	print, "	Arguments (output)"
	print, "		wdel	- wavelength shift along the slit,"
	print, "			  in pixels"
	print, "		wlfit	- wavelength shift along the slit,"
	print, "			  in pixels, fitted with 3rd order"
	print, "			  polynomial"
	print, "		sdel	- shift along slit as a function of"
	print, "			  wavelength"
	print, "		slfit	- shift along slit as a function of"
	print, "			  wavelength, in pixels, fitted with"
	print, "			  3rd order polynomial"
	print, "		bim	- interpolated b-channel spectral"
	print, "			  image, appropriately shifted in"
	print, "			  both dimensions to match a-channel"
	print, "			  (array aim is not changed)"
	print, "		bn	- overall multiplicative"
	print, "			  renormalization constant for"
	print, "			  b-channel"
	print, "		diff	- multiplicative correction array for"
	print, "			  b-channel to remove slowly-varying"
	print, "			  wavelength slope differences between"
	print, "			  a,b channels"
	print
	print, "	Keywords"
	print, "		(none)
	print
	return
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
;
;	Get dimensions of arrays (assumed to be the same for both).
;
nx = sizeof(aim, 1)
ny = sizeof(aim, 2)
nx1 = nx-1
ny1 = ny-1
;
;	Define some arrays for storage.
;
fftbx = complexarr(256,ny)  ; Fourier transform of b-array for wlen shifting
wdel = fltarr(ny)	    ; pixel shift array for wavelength
sdel = fltarr(nx)	    ; pixel shift array along slit
avga = fltarr(ny)	    ; avgs removed from data b4 transforming (zeroed)
avgb = avga		    ; avgs removed from data b4 transforming (zeroed)
avgwl = fltarr(nx)	    ; avg spec profile of a=channel for fitting shifts
;
;	Find average over centers of image, then renormalize intensity of
;	b-array to average of a-array.  Temporarily use avga, avgb arrays
;	to improve numerical accuracy.  Avoid columns near beginning, end
;	because of occasional glitches there.
;
fnx = float(xend-xst+1)
fny = float(yend-yst+1)
for j = 0,ny1 do avga(j) = total(aim(xst:xend,j))/fnx
for j = 0,ny1 do avgb(j) = total(bim(xst:xend,j))/fnx
anorm = total(avga(yst:yend))/fny
bnorm = total(avgb(yst:yend))/fny
;
;	Get renormalization constant to multiply times b-channel.
;
bn = anorm/bnorm
bim = bim*bn
;
;	Zero avga,avgb again.
;
avga(*) = 0.0
avgb(*) = 0.0
;
;	Loop over y-dimension (rows) to cross-correlate in wavelength.
;
for j = 0,ny1 do begin
;
;	Extend, remove average, Fourier transform.
	fftrp,aim(*,j),xst,xend,fftera,ava
	fftrp,bim(*,j),xst,xend,ffterb,avb
	fftbx(*,j) = ffterb
	avga(j) = ava
	avgb(j) = avb
;
;	Find the maximum of cross-correlation.
	cormax,fftera,ffterb,nsearch,sh
	wdel(j) = sh
endfor
;
;	Do cross-correlation in vertical direction.  Use much of array,
;	as solar image structure actually helps us here (no differential
;	refraction, becasuse at same wavelength).  However, if a hairline
;	is too close to the end of array (as it is in the 920619 data for
;	the top hairline), avoid the use of that hairline.
;
;	!!!NOTE: FITTING RANGE HARDWIRED!!!
;
for i = 5,nx1-ixst-5 do begin
;
;	Extend, remove average, Fourier transform.
	fftrp,aim(i,*),yst,yend,fftera,ava
	fftrp,bim(i,*),yst,yend,ffterb,avb
	avgwl(i) = ava
;
;	Find the maximum of cross-correlation.
	cormax,fftera,ffterb,nsearch,sh
	sdel(i) = sh
endfor
;
;	BEGIN SHIFTING.
;	Do wavelength shifts first.  For wavelength, fit 3rd order
;	polynomial to shifts from rows with intensity greater than
;	some threshold.  This avoids problem areas in spot umbrae
;	and hairlines.  Current threshold value is the average intensity.
;
xy = indgen(ny)
avmn = total(avga)/float(n_elements(avga))
;
;	Avoid top and bottom of array.
;
avgaa = avga
if yst gt 0 then avgaa(0:yst-1) = 0.0
if yend lt ny1 then avgaa(yend+1:ny1) = 0.0
whry = where(avgaa gt avmn)
coef = poly_fit(xy(whry),wdel(whry),3)
wlfit = poly(xy,coef)
;
for j = 0,ny1 do begin
;
;	Fourier transform full active range of x dimension.
	fftrp,bim(*,j),0,nx1-ixst,ffterb,avb
;
;	Apply Fourier shift theorem to shift b-row.
	ffterb = xshift(ffterb,wlfit(j))
;
;	Inverse transform, restore normalization.
	shftb = float(fft(ffterb,1)) + avb
;
;	Replace active area back into input array.
	bim(0:nx1,j) = shftb(0:nx1)
endfor
;
;	Hairline shifts:  fit 3rd order polynomial to slit variation of shift.
;
xx = indgen(nx)
;
;	Avoid spectral line regions in fit.
avmn = total(avgwl(xst:xend))/fnx
whrx = where(avgwl gt avmn)
coef = poly_fit(xx(whrx),sdel(whrx),3)
slfit = poly(xx,coef)
;
;	Retransform active columns in preparation for shifting.
;
for i = 0,nx1 do begin
	fftrp,bim(i,*),0,ny1,ffterb,avb
;
;	Apply Fourier shift theorem to shift b-row.
	ffterb = xshift(ffterb,slfit(i))
;
;	Inverse transform, restore normalization.
	shftb = float(fft(ffterb,1)) + avb
;
;	Replace back into input arrays.
	bim(i,0:ny1) = shftb(0:ny1)
endfor
;
;	Equalize the wavelength slope of the two images by fitting the
;	slope of the continuum for each row, then fitting smoothed curves
;	to coefficients along the slit.  Get fit coefficients to the
;	difference of the images for each slit position, avoiding the lines.
;
delt = fltarr(nx)
diff = (aim-bim)
coefwl = dblarr(2,ny)
;
;	Fit continuum wavelengths of difference.
;
for j = yst,yend do coefwl(*,j) = poly_fit(xx(whrx),diff(whrx,j),1)
;
;	Fit curves to coefficients, avoiding hairlines and spots.
;
coef0 = poly_fit(xy(whry),coefwl(0,whry),1)
coef1 = poly_fit(xy(whry),coefwl(1,whry),1)
;
;	Replace coefwl array with fits.
;
coefwl(0,*) = poly(xy,coef0)
coefwl(1,*) = poly(xy,coef1)
;
;	Get avg of b-channel, excluding hairlines, spots, and spectral lines.
;
for j = 0,ny1 do avgb(j) = total(bim(whrx,j))/float(n_elements(whrx))
bnorm = total(avgb(whry))/float(n_elements(whry))
;
;	Rescale the b-channel image to equalize.
;
for j = 0,ny1 do begin
	delt = poly(xx,coefwl(*,j))
	diff(*,j) = 1. + delt(*)/bnorm
endfor
bim = bim*diff

end

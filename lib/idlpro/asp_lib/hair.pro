pro hair, imag, ilo1, ihi1, ilo2, ihi2, slope, ixst, $
	  onehair=onehair, verbose=verbose
;+
;
;	procedure:  hair
;
;	purpose:  determine the skewness of the image from measured
;		  positions of the hairlines at top and bottom
;		  (or bottom only) for skew.pro
;
;		  "should be run on CAL clear port image" --Bruce
;		  "running it on calibrated I image" --Rob
;
;	history:  lites@ncar - created.
;		  rob@ncar, 10/93 - reversed meaning of 'ixst' so code
;				    works on flipped data; added 'onehair'
;				    option; various small mod's.
;
;	WARNING - 'ixst' assumes wavelengths HAVE been flipped !!!
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 7 then begin
	print
	print, "usage:  hair, imag, ilo1, ihi1, ilo2, ihi2, slope, ixst"
	print
	print, "	Determine the skewness of the image from measured"
	print, "	positions of the hairlines at top and bottom"
	print, "	(or bottom only) for skew.pro."
	print
	print, "	Arguments"
	print, "	    imag	- Stokes I intensity image, dark"
	print, "		          previously removed"
	print, "	    ilo1	- lower lmt search for min of hline 1"
	print, "	    ihi1	- upper lmt search for min of hline 1"
	print, "	    ilo2	- lower lmt search for min of hline 2"
	print, "			  (not used if 'onehair' is set)"
	print, "	    ihi2	- upper lmt search for min of hline 2"
	print, "			  (not used if 'onehair' is set)"
	print, "	    ixst	- number of non-data columns on"
	print, "			  *right* side of the spectra"
	print, "	    slope	- output hairline slope "
	print, "		          (per pixel; see 'onehair' below)"
	print
	print, "	Keywords"
	print, "	    onehair	- if set, use only the bottom hairline"
	print, "			  (def=average slope of both hairs)"
	print, "	    verbose	- if set, print run-time information"
	print, "			  (def=don't print it)"
	print
	return
endif
;-
;
;	Get dimensions of arrays.
;
nx = sizeof(imag, 1)
ny = sizeof(imag, 2)
nx1 = nx - 1
ny1 = ny - 1
;
;	Set general parameters.
;
imag_temp = imag
slop = fltarr(2, /nozero)
shft = fltarr(nx, /nozero)
avgwl = fltarr(nx, /nozero)
do_verb = keyword_set(verbose)
do_oneh = keyword_set(onehair)
indx = float( [ [ilo1, ihi1], [ilo2, ihi2] ] )
if do_oneh then top=ny1 else top=ilo2
;
;	Correct for residual RGB variations.
;
ofstc2, imag_temp, verbose=do_verb
;
;-------------------------------------------------
;	 Process the bottom or both hairlines
;-------------------------------------------------
;
for k = 0, 1-do_oneh do begin

	ilo = indx(0, k)
	ihi = indx(1, k)

	nsh = ihi - ilo + 1	; # wlen positions around profile of interest
	corrl = fltarr(nsh)
;
;	Use the minimum intensity rather than cross correlation.
	for i = 0, nx1-ixst do begin
		corrl(0:nsh-1) = imag_temp(i, ilo:ihi)
		shft(i) = corsh1(corrl)
	endfor
;
;	Subtract out the average to get relative shifts.
	shft(*) = shft(*) - mean(shft(0:nx1-ixst))
;
;	Fit the shifts with a linear function.
;	Avoid spectral line regions in fit.
;
;	Get average spectral profile.
	for i = 0, nx1 do avgwl(i) = mean(imag_temp(i, ihi1:top))

;	Ensure that LAST columns are excluded from fit.
	avgwl(nx1-ixst+1:nx1) = 0.0

;	Find average spectral intensity over wavelength range.
	avmn = mean(avgwl(0:nx1-ixst))
;
;	Fit only wavelengths above average.
	x1 = indgen(nx)
	whrx = where(avgwl gt avmn)
	coef = poly_fit(x1(whrx), shft(whrx), 1)
	slop(k) = coef(0, 1)
;
endfor
;
;-------------------------------------------------
;
;	Return the slope (or average of the two slopes).
;
if do_oneh then slope=slop(0)   else slope=0.5*(slop(0) + slop(1))
;
end

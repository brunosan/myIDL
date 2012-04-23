pro shslit, imag, ilo, ihi, shft, shfit, avgprf, clrsp, $
	ixst, ihst, ihend, verbose=verbose
;+
;
;	procedure:  shslit
;
;	purpose:  build the ideal spectral image without defects.
;		  built from shifting the average spectral profile
;		  by the relative wavelength shift of the weak line
;		  profiles in the ND filter flat-field images as a
;		  function of distance along the slit
;
;	author:  lites@ncar
;
;	WARNING - 'ixst' assumes wavelengths have NOT been flipped !!!
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 10 then begin
	print
	print, "usage:  shslit, imag, ilo, ihi, shft, shfit, avgprf, clrsp, $"
	print, "		ixst, ihst, ihend"
	print
	print, "	Build the ideal spectral image without defects..."
	print, "	built from shifting the average spectral profile"
	print, "	by the relative wavelength shift of the weak line"
	print, "	profiles in the ND filter flat-field images as a"
	print, "	function of distance along the slit."
	print
	print, "	Arguments"
	print, "		imag	- Stokes I intensity image"
	print, "			  (dark previously removed)"
	print, "		ilo	- lower limit spectrum index for"
	print, "			  profile shift test"
	print, "		ihi	- upper limit spectrum index for"
	print, "			  profile shift test"
	print, "		ixst	- index of first active X"
	print, "			  (using 15 for 3/92 data)"
	print, "		ihst	- Y index after 1st hairline"
	print, "			  (using 20 for 3/92 data)"
	print, "		ihend	- Y index before 2nd hairline"
	print, "			  (using 215 for 3/92 data)"
	print
	print, "		shft	- output differential shift in pixels"
	print, "			  of spectrum along slit"
	print, "		shfit	- output polynomial fit to shifts"
	print, "			  along the slit"
	print, "		avgprf	- output average profile array"
	print, "			  rewritten"
	print, "		clrsp	- output ideal spectral image without"
	print, "			  pixel variations, normalized to"
	print, "			  unity"
	print, "	Keywords"
	print, "	    verbose	- if set, print run-time information"
	print, "			  (def=don't print it)"
	print
	return
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
do_verb = false
if keyword_set(verbose) then do_verb = true

;  get dimensions of arrays
nx = sizeof(imag, 1)
ny = sizeof(imag, 2)
nx1 = nx-1
ny1 = ny-1

yavg = float(ny-ihst)

img = imag
;  correct for residual rgb variations
ofstc2, img, verbose=do_verb

;  compute raw average spectrum profile
avgprf = fltarr(nx)
shft = fltarr(ny)
shfit = shft
for i = 0,nx1 do avgprf(i) = total( img(i,ihst:ihend) ) / yavg

;  nsh=number of wavelength positions around profile of interest
nsh = (ihi-ilo+1)

sumpr=fltarr(nx)	; array is zero'ed
sump = fltarr(nx)

;  loop over length along slit, find new average profile

;  use the minimum intensity rather than cross correlation
for j=0,ny1 do shft(j) = corsh1(img(ilo:ihi,j) )

;  subtract out the average to get relative shifts
shft = shft - mean(shft(ihst:ihend))

;  fit the shifts with a parabola
x1=indgen(ny)
coef = poly_fit(x1(ihst:ihend),shft(ihst:ihend),3)
shfit = poly(x1,coef)

;  sum the appropriately shifted profiles along the slit for new average profile
for j=ihst,ihend do sumpr = sumpr + fshft(img(*,j),-shfit(j),ixst,nx1)
sumpr = sumpr/yavg
avgprf = sumpr

; instead use mean without hole at beginning ??? Rob
;;sumpr = sumpr/mean(sumpr)
;  why not use a clear continuum portion of sumpr, rather than whole thing????
sumpr = sumpr/mean(sumpr(ixst:nx1-2))

;  divide image by average profile shifted along the slit
clrsp = img
for j=0,ny1 do begin
   tempr = fshft(sumpr,shfit(j),ixst,nx1)
   for i = ixst,nx1-2 do sump(i) = tempr(i)

  sump(nx1-1:nx1) = sump(nx1-3)

; needed??? Rob
  sump(0:ixst-1) = sump(ixst)

;  get supposed spectral image without defects (clrsp)
  for i=0,ixst-1 do clrsp(i,j) = 1.
  for i=ixst,nx1 do clrsp(i,j)=sump(i)
endfor

end

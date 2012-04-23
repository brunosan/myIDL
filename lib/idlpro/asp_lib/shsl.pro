pro shsl, imag, ilo, ihi, shft, shfit, avgprf, clrsp, ixst, ihst, ihend
;+
;
;	procedure:  shsl
;
;	purpose:  Compute the 'line-free' normalized image of the corrected
;		  cal clear port image, which has already been corrected for
;		  pixel-pixel variations using gncorr.pro.  Find shifts from
;		  telluric line contained between ilo-ihi, then compute
;		  average line profile from this, and divide by that profile
;		  appropriately shifted along the slit.
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
	print, "usage:  shsl, imag, ilo, ihi, shft, shfit, avgprf, clrsp, $"
	print, "	      ixst, ihst, ihend"
	print
	print, "	Compute the 'line-free' normalized image of the"
	print, "	corrected cal clear port image, which has already"
	print, "	been corrected for pixel-pixel variations using"
	print, "	gncorr.pro.  Find shifts from telluric line contained"
	print, "	between ilo-ihi, then compute average line profile"
	print, "	from this, and divide by that profile appropriately"
	print, "	shifted along the slit."
	print
	print, "	Arguments"
	print, "		imag	- Stokes I Clear port image, dark"
	print, "			  previously removed and corrected"
	print, "			  for pixel-pixel noise by gncorr.pro"
	print, "		ilo	- lower limit spectrum index for"
	print, "			  profile shift test"
	print, "		ihi	- upper limit spectrum index for"
	print, "			  profile shift test"
	print
	print, "		(Usually use middle telluric line between"
	print, "		 2 Fe I lines; 25 March 92 data use 165-195.)"
	print
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
	print, "			  rewritten on output"
	print, "		clrsp	- output 'line-free' image, normalized"
	print, "			  to unity"
	print
	return
endif
;-

;  get dimensions of arrays
nx = sizeof(imag, 1)
ny = sizeof(imag, 2)
nx1 = nx - 1
ny1 = ny - 1

;  normalizing constant when averaging over active rows
yavg = float(ihend-ihst+1)

;  setup arrays
avgprf = fltarr(nx)
sumpr  = avgprf
sump   = avgprf
shft   = fltarr(ny)
shfit  = shft
img    = imag

;  correct for residual rgb variations
;;ofstc2, img  -Rob

;  compute raw average spectrum profile
for i = 0,nx1 do avgprf(i) = total( img(i,ihst:ihend) ) / yavg

;  use the minimum intensity rather than cross correlation
for j=0,ny1 do shft(j) = corsh1( img(ilo:ihi,j) )

;  subtract out the average over meaningful slit positions
;  to get relative shifts
shft = shft - mean(shft(ihst:ihend))

;  fit the shifts with a parabola
x1 = indgen(ny)
coef = poly_fit( x1(ihst:ihend), shft(ihst:ihend), 3 )

;  generate fit to data
shfit = poly(x1,coef)

;  sum the appropriately shifted profiles along the slit for new average
;  profile; avoid discontinuity for first pixels in fourier shifting. 
for j=ihst,ihend do sumpr = sumpr + fshft(img(*,j),-shfit(j),ixst,nx1)

sumpr = sumpr/yavg
avgprf = sumpr

;  divide image by average profile shifted along the slit
clrsp = img

for j=0,ny1 do begin
	tempr = fshft(sumpr,shfit(j),ixst,nx1)

	for i = ixst,nx1-2 do sump(i) = tempr(i)

	sump(nx1-1:nx1) = sump(nx1-3)
	sump(0:ixst-1) = sump(ixst)

;	generate flat-field image
;----------This instruction has been added by Skumanich, Aug 23, 1994.-----
        clrsp(0:ixst-1,j)= img(ixst,j)/sump(ixst)
;--------------------------------------------------------------------------
	for i = ixst,nx1 do clrsp(i,j) = img(i,j)/sump(i)
endfor

end

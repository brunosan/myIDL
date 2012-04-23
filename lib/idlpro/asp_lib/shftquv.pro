pro shftquv, aim, bim, ixst, wlfit, slfit, bn, diff
;+
;
;	procedure:  shftquv
;
;	purpose:  Renormalize then Fourier shift b-channel Q,U,V images
;		  then combine them.  Uses the Fourier techniques and output
;		  shift and renormalization parameters from wlcross.pro.
;
;	author:  lites@ncar, 4/93	(minor mod's by rob@ncar)
;
;	WARNING - 'ixst' assumes wavelengths HAVE been flipped !!!
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 7 then begin
	print
	print, "usage:  shftquv, aim, bim, ixst, wlfit, slfit, bn, diff"
	print
	print, "	Renormalize then Fourier shift b-channel Q,U,V images"
	print, "	then combine them.  Uses the Fourier techniques and"
	print, "	output shift and renormalization parameters from"
	print, "	wlcross.pro."
	print
	print, "	Arguments (input)"
	print, "		aim	- a-channel gain-corrected Stokes I"
	print, "			  image (not shifted)"
	print, "		bim	- b-channel gain-corrected Stokes I"
	print, "			  image (shifted)"
	print, "		ixst	- number of non-data columns on"
	print, "			  *right* side of the spectra"
	print, "		wlfit	- wavelength shift along the slit, in"
	print, "			  pixels, fitted with 3rd order"
	print, "			  polynomial"
	print, "		slfit	- shift along slit as a function of"
	print, "			  wavelength, in pixels, fitted with"
	print, "			  3rd order polynomial"
	print, "		bn	- overall renormalization constant for"
	print, "			  b-channel"
	print, "		diff	- multiplicative renormalization array"
	print, "			  for b-channel"
	print
	print, "	Arguments (output)"
	print, "		aim     - result of subtracting a,b channels"
	print, "			  after shifting and correcting level"
	print, "			  of b-channel according to parameters"
	print, "			  derived from intensity images"
	print, "		bim     - corrected b channel image for this"
	print, "			  polarization"
	print
	return
endif
;-

;  get dimensions of arrays (assumed to be the same for both)
nx = sizeof(aim, 1)
ny = sizeof(aim, 2)
nx1 = nx-1
ny1 = ny-1

;  correct for normalizations
bim = bim*bn
bim = bim*diff

;  Do wavelength shifts first.
for j = 0,ny1 do begin

	fftrp, bim(*,j), 2, nx1-ixst-2, ffterb, avb

	;  apply Fourier shift theorem to shift b-row
	ffterb = xshift(ffterb,wlfit(j))

	;  inverse transform, restore normalization
	shftb = float(fft(ffterb,1)) + avb

	;  replace active area back into input array
	bim(0:nx1,j) = shftb(0:nx1)
endfor

;  do shifts along slit
for i = 0,nx1 do begin

	fftrp,bim(i,*),0,ny1,ffterb,avb

	;  apply Fourier shift theorem to shift b-row
	ffterb = xshift(ffterb,slfit(i))

	;  inverse transform, restore normalization
	shftb = float(fft(ffterb,1)) + avb

	;  replace back into input arrays
	bim(i,0:ny1) = shftb(0:ny1)
endfor

end

function skew, imag, slope
;+
;
;	function:  skew
;
;	purpose:  remove the skewness of spectral image using slope of
;		  hairlines previously derived using routine [one]hair
;
;	author:  lites@ncar
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = skew(imag, slope)"
	print
	print, "	Remove the skewness of spectral image using"
	print, "	slope of hairlines previously derived using"
	print, "	[one]hair.pro.  Returned value is image with"
	print, "	skew removed by Fourier interpolation."
	print
	print, "	Arguments"
	print, "		imag    = input 2D input spectral array"
	print, "		slope   = input slope of hairlines"
	print, "			  (pixels/pixel in wavelength)"
	print
	return, 0
endif
;-
;
;	Get dimensions of arrays.
;
nx = sizeof(imag, 1)
ny = sizeof(imag, 2)
nx1 = nx-1
ny1 = ny-1
;
;	Set up arrays.
;
imgout = imag
temp = fltarr(ny, /nozero)
;
;---------------------
;
;	Loop over columns to be interpolated.
;
for i = 1,nx1 do begin
;
;	Grab a column.
	temp = imag(i,*)
;
;	Calculate shift correction.
	shi = -slope * float(i)
;
;	Apply shift to the column.
	imgout(i,*) = fshft(temp, shi, 0, ny1)
;
endfor
;
;---------------------
;
return, imgout
end

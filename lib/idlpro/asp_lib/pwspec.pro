pro pwspec, arr, pwsp, nst, nend, napod=napod
;+
;
;	procedure:  pwspec
;
;	purpose:  determine average power spectrum from x-direction
;		  Fourier transform of input array
;
;	history:  8/94 lites@ncar - written.
;		  8/94 rob@ncar - added 'napod' option; replaced PRINT/STOP
;			with MESSAGE; replaced SIZE with SIZEOF; added
;			usage/comments/etc.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  pwspec, arr, pwsp, nst, nend"
	print
	print, "	Determine average power spectrum from x-direction"
	print, "	Fourier transform of input array."
	print
	print, "	Arguments"
	print, "		arr	- input array"
	print, "		nst	- starting fast axis value for"
	print, "			  apodization"
	print, "		nend	- ending fast axis value for"
	print, "			  apodization"
	print, "		pwsp	- output array containing power"
	print, "			  spectra"
	print
	print, "	Keywords"
	print, "		napod	- width of cosine bell for apodizing"
	print, "			  with apod.pro (def=use extend.pro)"
	print
	print
	print, "   ex:  pwspec, arr, pwsp, nst, nend, napod=20"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Get dimensions of input array.
;
nx = sizeof(arr, 1)
ny = sizeof(arr, 2)
nx1 = nx-1
ny1 = ny-1
;
;	Check sizes.
;
if nx gt 256 then $
	message, 'Array size ' + stringit(nx) + ' > 256 hardwire maximum.'

temp = fltarr(256)
tempr = temp
if n_elements(napod) eq 0 then napod = 0
do_apod = (napod gt 1)
;
;	Loop for each y.
;
for j = 0, ny1 do begin
	temp(0:nx1) = arr(0:nx1,j)

;;---------------------------
;;	Remove mean.
;;	temp = temp-mean(temp(nst:nend))
;;
;;	Apodize ends of array with 20-point cosine bell.
;;	apod,temp,nst,nend,20
;;---------------------------

	if do_apod then begin

;		Remove mean and apodize ends of data with cosine bell.
		apod, temp, nst, nend, napod

	endif else begin

;		Extend array to 256 points with cosine function.
		temp = extend(temp, nst, nend)

	endelse

	fftr = fft(temp, -1)
	tempr = (abs(fftr))^2

	pwsp(0:nx1, j) = alog10(tempr(0:nx1))
endfor

end


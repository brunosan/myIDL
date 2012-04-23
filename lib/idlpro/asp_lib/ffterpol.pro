function ffterpol, dat, del, nst, nend
;+
;
;  purpose:  do Fourier interpolation of a one-dimensional array
;
;  inputs:  dat    = one-dimensional data
;           del    = fractional pixel shift
;           nst    = starting index for active area
;           nend   = ending index for active area
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  ret = ffterpol(dat, del, nst, nend)"
	print
	print, "	Do Fourier interpolation of a one-dimensional array."
	print
	print, "	Arguments"
	print, "		dat	  - one-dimensional data"
	print, "		del	  - fractional pixel shift"
	print, "		nst	  - starting index for active area"
	print, "		nend	  - ending index for active area"
	print
	return, 0
endif
;-

terp = dat

;  get dimensions of array
nx = sizeof(dat, 1)
nx1 = nx - 1

;  always interpolate to 256 points
nmask = 256 - (nend - nst + 1)

if nmask le 14 then begin
	print,'In ffterpol, no. pts ',nmask,' is too close to 256 limit.'
	stop
endif

;  define the interpolated array
temp = fltarr(256)

;  extend the array so that there is smooth transition
temp(nst:nend) = dat(nst:nend)
temp = extend(temp, nst, nend)

;  fft the extended data
fftr = fft(temp, -1)

;  apply the shift theorem
fftr = xshift(fftr, del)

;  inverse transform
temp = float(fft(fftr, 1))

;  backfill array
for i = nst,nend do terp(i) = temp(i)

return, terp
end

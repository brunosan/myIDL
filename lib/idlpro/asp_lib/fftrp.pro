pro fftrp, dat, nst, nend, fftr, avg, terp=terp
;+
;
;	procedure:  fftrp
;
;	purpose:  Obtain Fourier transform of data.  Make smooth transition
;		  from beginning to end, remove mean, and kill frequencies with
;		  rgb variation.
;
;	author:  lites@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 5 then begin
	print
	print, "usage:  fftrp, dat, nst, nend, fftr, avg"
	print
	print, "	Obtain Fourier transform of data"
	print, "	(make smooth transition from beginning to end, remove"
	print, "	mean, and kill frequencies with rgb variation)."
	print
	print, "	Arguments"
	print, "		dat	- input space data"
	print, "		nst,	- start and end pixels for"
	print, "		 nend	  interpolation"
	print, "		fftr	- output interpolated array,"
	print, "			  Fourier space:  complex(256*nn)"
	print, "		avg	- output mean of array from nst to"
	print, "			  nend which has been subtracted"
	print, "			  from dat"
	print, "	Keywords"
	print, "		terp	- data array transformed back,"
	print, "			  after filtering, etc."
	print, "			  (def=don't calculate/return it)"
	print
	return
endif
;-

;  get dimensions of array
nx = sizeof(dat, 1)
nx1 = nx-1

;  size output array
npt = 256

;  always interpolate from an array 256 points long
nmask = 256-(nend-nst+1)
if nmask le 14 then begin
	print,'in ffterpol, no. pts ',nmask,' is too close to 256 limit'
	stop
endif

;  define the interpolated array
temp = fltarr(256)

;  extend the array so that there is smooth transition to symmetry
temp(nst:nend)=dat(nst:nend)
temp = extend(temp,nst,nend)

;  remove mean from array
avg = total(temp)/float(npt)
temp = temp-avg

;  fft the extended data
fftr = fft(temp,-1)

;  get power spectrum
; pspec = (abs(fftr))^2
; pspec = alog10(pspec)
; stop


;  filter out frequencies corresponding to rgb variation
fftr(85) = complex(0.,0.)
fftr(86) = complex(0.,0.)
fftr(256-85) = complex(0.,0.)
fftr(256-86) = complex(0.,0.)

;  Fourier interpolation not used
;  define limits for zeros
; n1 = 128
; n2 = npt-128
;  extend transform by adding zeros in middle
; ffter(0:n1) = fftr(0:n1)
; ffter(n1+2:n2-2) = complex(0.,0.)
; ffter(n2:npt-1) = fftr(n1:255)

;  inverse transform
if n_elements(terp) ne 0 then terp = float(fft(fftr,1))

end

pro filtavg, sumpr, nst, nend
;+
;
;	purpose:  filter the residual RGB variations out of average
;		  profile sumpr
;
;	author:  lites@ncar
;
;==============================================================================

if n_params() ne 3 then begin
	print
	print, "usage:  filtavg, sumpr, nst, nend"
	print
	print, "	Filter the residual RGB variations out of average"
	print, "	profile sumpr."
	print
	print, "	Arguments"
	print, "		sumpr	- average spectral profile"
	print, "			  (input and output)"
	print, "		nst	- starting fast axis value for"
	print, "			  apodization"
	print, "		nend	- ending fast axis value for"
	print, "			  apodization"
	print
	return
endif
;-

;  get dimensions of input array
nx = sizeof(sumpr, 1)
nx1 = nx-1

;  check sizes
if nx gt 256 then begin
  print,' array size',nx,' gt 256 hardwire maximum in filt.pro'
  stop
endif

  temp = fltarr(256)

;  build filter to extract fringing
filtr=complexarr(256)

;  keep all other frequencies the same
for i=0,255 do filtr(i) = complex(1.,0.)

;  now build filter specific to
;  the residual rgb variation (frq 85)
for i=84,87 do begin
  filtr(i) = complex(0.,0.)
  filtr(255-i) = filtr(i)
endfor


  temp(0:nx1) = sumpr(0:nx1)
;  extend array to 256 points with cosine function
  temp = extend(temp,nst,nend)
  fftr = fft(temp,-1)

;  apply filter
   fftr = fftr*filtr

;  inverse transform
   temp = float(fft(fftr,1))

;  backfill data
   sumpr(0:nx1) = temp(0:nx1)

end

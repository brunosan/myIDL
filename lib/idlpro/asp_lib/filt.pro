pro filt, clrsp, nst, nend, filtd, run=run
;+
;
;	procedure:  filt
;
;	purpose:  Filter image by filtering only in x-direction
;		  Fourier transform of input array clrsp;
;		  generate multiplicative flat-field correction
;		  to remove high frequency fringes and (no longer)
;		  residual RGB variation.
;
;	author:  lites@ncar	(mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  filt, clrsp, nst, nend, filtd"
	print
	print, "	Filter image by filtering only in x-direction"
	print, "	Fourier transform of input array clrsp;"
	print, "	generate multiplicative flat-field correction"
	print, "	to remove high frequency fringes and (no longer)"
	print, "	residual RGB variation."
	print
	print, "	Arguments"
	print, "		clrsp	- input 'line-free' normalized clear"
	print, "			  port cal image from output of"
	print, "			  routine shsl.pro"
	print, "		nst	- starting fast axis value for"
	print, "			  apodization"
	print, "		nend	- ending fast axis value for"
	print, "			  apodization"
	print, "		filtd	- output array containing filtered"
	print, "			  flat-field image to remove high"
	print, "			  frequency fringes (a multi-"
	print, "			  plicative factor for application"
	print, "			  to first-order gain-corrected data)"
	print
	print, "	Keywords"
	print, "		run	- string containing the run date"
	print, "			  for run-specific processing"
	print, "			     'mar92' = March 1992"
	print, "			      other  = normal processing (def)"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Set general parameters.
;
true = 1
false = 0
if n_elements(run) eq 0 then run = 'normal'

;  get dimensions of input array
nx = sizeof(clrsp, 1)
ny = sizeof(clrsp, 2)
nx1 = nx-1
ny1 = ny-1
npoints = 256

;  check sizes
if nx gt npoints then begin
	print,' array size',nx,' gt',npoints,' hardwire maximum in filt.pro'
	stop
endif

;  build filter to extract fringing
filtr=complexarr(npoints)
temp = fltarr(npoints)

;  first,a low pass filter to keep DC level, slow variations
for i=0,128 do begin
	arg= (float(i)/1.5)^2
	if arg gt 35. then arg=35.
	arg = exp(-arg)
	filtr(i) = complex(arg,0.)
endfor

for i = 1,127 do filtr(256-i) = filtr(i)

;
;	Run-specific filtering.
;
case (run) of

  'mar92':  begin
;		Build filter specific to the high frequency fringes (frq 76),
;		and the residual RGB variation (frq 85).
		for i=76,76 do begin
			filtr(i) = complex(1.,0.)
			filtr(256-i) = filtr(i)
		endfor

;		Also remove the spike at freq 31.
		for i=31,31 do begin
			filtr(i) = complex(1.,0.)
			filtr(256-i) = filtr(i)
		endfor
	    end

     else:  begin
;		Build filter specific to the high frequency fringes (frq 76),
;		and the residual RGB variation (frq 85).
		for i=85,86 do begin
			filtr(i) = complex(1.,0.)
			filtr(256-i) = filtr(i)
		endfor
	    end

endcase


for j = 0, ny1 do begin

	temp(0:nx1) = clrsp(0:nx1,j)

;	extend array to npoints points with cosine function
	temp = extend(temp,nst,nend)

;	Fourier transform
	fftr = fft(temp,-1)

;	apply filter
	fftr = fftr*filtr

;	inverse transform
	temp = float(fft(fftr,1))

;	generate multiplicative gain correction
	filtd(0:nx1,j) = 1./temp(0:nx1)
   
endfor

end

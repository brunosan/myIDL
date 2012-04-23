pro cormax, fftera, ffterb, nsearch, sh
;+
;
;	procedure:  cormax
;
;	purpose:  find the maximum of a cross correlation function
;
;	author:  lites@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 4 then begin
	print
	print, "usage:  cormax, fftera, ffterb, nsearch, sh"
	print
	print, "	Arguments"
	print, "		fftera,	- input Fourier transforms of 1st"
	print, "		ffterb	  and 2nd vectors to be shifted"
	print, "		nsearch	- number of pixels either side to"
	print, "			  search for maximum"
	print, "		sh	- pixel shift of 2nd vector with"
	print, "			  respect to first"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif
;-

;  get dimensions of transform arrays (assumed to be the same for both)
  ntot = sizeof(fftera, 1)

;  multiply: (a-transform) X (conjugate of b-transform)
  ccor = fftera*conj(ffterb)

;  transform back to real space
  corr = float(fft(ccor,1))

;  find local maximum near zero shift.  Search +-nsearch pixels either direction
  temp = fltarr(2*nsearch)
  temp(0:nsearch-1) = corr(ntot-nsearch:ntot-1)
  temp(nsearch:2*nsearch-1)=corr(0:nsearch-1)
  amax = max(temp,imx)

;  fit parabola to 3 interpolated pixels around maximum position
  xx = indgen(nsearch*2)
;  ensure that we are not at endpoints
  if imx eq 0 then imx = 1
  if imx eq nsearch*2-1 then imx = nsearch*2-2
;  fit parabola
  coeff = poly_fit(xx(imx-1:imx+1),temp(imx-1:imx+1),2)
  sh = -coeff(1)/(2.*coeff(2))
  sh = (sh-nsearch)

end

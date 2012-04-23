pro apod, dat, nst, nend, nap, nomean=nomean
;+
;
;	procedure:  apod
;
;	purpose:  apodize a 1-d array with a cosine bell function
;
;	history:  lites@ncar - written.
;		  8/94 rob@ncar - changed parentheses in 'bell' expression to
;			produce a quarter period cosine bell rather than a
;			multi-period one; replaced loop with array operations
;			for speed; added usage information and comments; use
;			'message' in place of 'print/stop'; removed unused
;			'mask' array; added 'nomean' keyword.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  apod, dat, nst, nend, nap"
	print
	print, "	Apodize a 1-d array with a cosine bell function."
	print, "	It apodizes to zero at either end such that"
	print, "	    dat(0:nst)    will be 0"
	print, "	    dat(nend:END) will be 0"
	print, "	    dat(nst+nap:nend-nap) will be as input."
	print
	print, "	Arguments"
	print, "		dat	- 1-d float array (input and output)"
	print, "		nst	- starting index for apodization"
	print, "		nend	- ending index for apodization"
	print, "		nap	- number of points in bell function"
	print
	print, "	Keywords"
	print, "		nomean	- if set, do not subtract mean to"
	print, "			  create zero bias"
	print
	print
	print, "   ex:  apod, dat, 10, 190, 20"
	print
	return
endif
;-
;
;	Get dimensions of input array.
;
nx = sizeof(dat, 1)
nx1 = nx - 1
;
;	Check input numbers.
;
if nend ge nx1 then $
	message, 'ending value ' + stringit(nend) + ' ge ' + stringit(nx1)
if nst lt 1 then $
	message, 'starting value ' + stringit(nst) + ' lt 1'
if (nend-nst+1) lt 2*nap then $
	message, 'apodization length nap is too long'
;
;	Fill ends with 0's.
;
dat(0:nst) = 0.0
dat(nend:nx1) = 0.0
;
;	Optionally subtract mean.
;
if not keyword_set(nomean) then begin
	m = mean(dat(nst+1:nend-1))
	dat(nst+1:nend-1) = dat(nst+1:nend-1) - m
endif
;
;	Apodize ends with cosine bell.
;
bell = 0.5 * ( 1.0 - cos(!pi * findgen(nap+1) / float(nap)) )
dat(nst:nst+nap) = dat(nst:nst+nap) * bell
dat(nend-nap:nend) = dat(nend-nap:nend) * reverse(bell)

end

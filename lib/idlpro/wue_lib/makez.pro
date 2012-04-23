;+
; NAME:
;       MAKEZ
; PURPOSE:
;       Make simulated 2-d data.  Useful for software development.
; CATEGORY:
; CALLING SEQUENCE:
;       data = makez( nx, ny, [w, m, sd, seed])
; INPUTS:
;       nx, ny = size of 2-d array to make.                 in 
;       w = smoothing window size (def = 5% of sqrt(nx*ny). in 
;       m = mean (def = 100).                               in 
;       sd = standard deviation (def = 40% of mean).        in 
;       seed = random number seed.                          in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       data = resulting data array (def = undef).          out  
; COMMON BLOCKS:
;       makez_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  29 Nov, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION MAKEZ, Nx, ny, W, M, SD, SEED0, help=hlp
 
	common makez_com, seed
 
	NP = N_PARAMS(0)
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Make simulated 2-d data.  Useful for software development.' 
	  print,' data = makez( nx, ny, [w, m, sd, seed])' 
	  print,'   nx, ny = size of 2-d array to make.                 in'
	  print,'   w = smoothing window size (def = 5% of sqrt(nx*ny). in'
	  print,'   m = mean (def = 100).                               in'
	  print,'   sd = standard deviation (def = 40% of mean).        in'
	  print,'   seed = random number seed.                          in'
	  print,'   data = resulting data array (def = undef).          out' 
	  return, -1
	endif
 
	if n_elements(seed0) ne 0 then seed = seed0
	IF NP LT 3 THEN W = .05*sqrt(long(Nx)*ny) > 1
	IF NP LT 4 THEN M = 100
	IF NP LT 5 THEN SD = .40*M > 1
 
	w = w>4
	X = RANDOMU( SEED, nx+W+W, ny+w+w)
	seed0 = seed
	X = SMOOTH2( X, W)
	X = X(W:(nx+W-1), w:(ny+w-1))
	X = X - MEAN(X)
	X = X*SD/SDEV(X) + M
	RETURN, X
	END

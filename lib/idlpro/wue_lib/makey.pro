;+
; NAME:
;       MAKEY
; PURPOSE:
;       Make simulated data.  Useful for software development.
; CATEGORY:
; CALLING SEQUENCE:
;       data = makey( n, [w, m, sd, seed])
; INPUTS:
;       n = number of data values to make.                in 
;       w = smoothing window size (def = 5% of n).        in 
;       m = mean (def = 100).                             in 
;       sd = standard deviation (def = 40% of mean).      in 
;       seed = random number seed.                        in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /PERIODIC forces data to match at ends. 
;	  LASTSEED = s  returns last random seed used.
; OUTPUTS:
;       data = resulting data array (def = undef).        out  
; COMMON BLOCKS:
;       makey_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner,  2 Apr, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 21 Nov, 1988 --- added SEED.
;	R. Sterner, 2 Feb, 1990 --- added periodic.
;	R. Sterner, 29 Jan, 1991 --- renamed from makedata.pro.
;-
 
	FUNCTION MAKEY, N, W0, M, SD, SEED0, help=hlp, periodic=per, $
	  lastseed=lseed
 
	common makey_com, seed
 
	NP = N_PARAMS(0)
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Make simulated data.  Useful for software development.' 
	  print,' data = makey( n, [w, m, sd, seed])' 
	  print,'   n = number of data values to make.                in'
	  print,'   w = smoothing window size (def = 5% of n).        in'
	  print,'   m = mean (def = 100).                             in'
	  print,'   sd = standard deviation (def = 40% of mean).      in'
	  print,'   seed = random number seed.                        in'
	  print,'   data = resulting data array (def = undef).        out' 
	  print,' Keywords:'
	  print,'   /PERIODIC forces data to match at ends.'
	  print,'   LASTSEED = s  returns last random seed used.'
	  return, -1
	endif
 
	if n_elements(seed0) ne 0 then seed = seed0
	IF NP LT 2 THEN W0 = .05*N > 5
	IF NP LT 3 THEN M = 100
	IF NP LT 4 THEN SD = .40*M > 1
	w = w0
 
	if keyword_set(per) then begin
	  X = RANDOMU( SEED, N)
	  seed0 = seed			; 4 smooths to simulate 1 smooth2.
	  x = [x,x(0:(w-1))]		; Tack on 1 smoothing windows worth.
	  X = SMOOTH(X, W)		; Smooth.
	  X = X((W/2):(N+W/2-1))	; Extract 1 period.
	  x = [x,x(0:(w-1))]		; repeat . . .
	  X = SMOOTH(X, W)
	  X = X((W/2):(N+W/2-1))
	  w = w/2
	  x = [x,x(0:(w-1))]
	  X = SMOOTH(X, W)
	  X = X((W/2):(N+W/2-1))
	  x = [x,x(0:(w-1))]
	  X = SMOOTH(X, W)
	  X = X((W/2):(N+W/2-1))
	endif else begin 
	  X = RANDOMU( SEED, N+W+W)
	  seed0 = seed
	  X = SMOOTH2( X, W)
	  X = X(W:(N+W-1))
	endelse
 
	X = X - MEAN(X)
	X = X*SD/SDEV(X) + M

	lseed = seed
 
	RETURN, X
	END

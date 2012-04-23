;+
; NAME:
;       SMOOTH2
; PURPOSE:
;       Do multiple smoothing. Gives near Gaussian smoothing.
; CATEGORY:
; CALLING SEQUENCE:
;       b = smooth2(a, w)
; INPUTS:
;       a = array to smooth (1-d or 2-d).  in 
;       w = smoothing window size.         in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = smoothed array.                out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  8 Jan, 1987.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES  14 Jan, 1987 --- made both 2-d and 1-d.
;       RES 30 Aug, 1989 --- converted to SUN.
;-
 
	FUNCTION SMOOTH2, I, W, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp)  then begin
	  print,' Do multiple smoothing. Gives near Gaussian smoothing.'
	  print,' b = smooth2(a, w)'
	  print,'   a = array to smooth (1-d or 2-d).  in'
	  print,'   w = smoothing window size.         in'
	  print,'   b = smoothed array.                out'
	  return, -1
	endif
 
	W1 = W > 1
	W2 = W/2 > 1
	N1 = FIX(W1+1.)/2.
	N2 = FIX(W2+1.)/2.
	TN = N1 + N1 + N2 + N2
 
	I2 = SMOOTH(I, W1)
	I2 = SMOOTH(I2, W1)
	I2 = SMOOTH(I2, W2)
	I2 = SMOOTH(I2, W2)
 
	RETURN, I2
	END

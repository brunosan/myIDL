;+
; NAME:
;       LS2
; PURPOSE:
;       Scale image between percentiles 1 and 99 (or specified percentiles).
; CATEGORY:
; CALLING SEQUENCE:
;       out = ls2(in, [l, u, alo, ahi])
; INPUTS:
;       in = input image.                           in 
;       l = lower percentile to ignore (def = 1).   in  
;       u = upper percentile to ignore (def = 1).   in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       alo = value scaled to 0.                    out 
;       ahi = value scaled to 255.                  out 
;       out = scaled image.                         out 
; COMMON BLOCKS:
; NOTES:
;       Notes: Uses cumulative histogram. 
; MODIFICATION HISTORY:
;       R. Sterner. 7 Oct, 1987.
;       RES 5 Aug, 1988 --- added lower and upper limits.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION LS2, A, L, U, alo, ahi, help = hlp
 
	NP = N_PARAMS(0)
 
	if (np lt 1) or keyword_set(hlp) then begin
	  print,' Scale image between percentiles 1 and 99 '+$
	    '(or specified percentiles).' 
	  print,' out = ls2(in, [l, u, alo, ahi])' 
	  print,'   in = input image.                           in'
	  print,'   l = lower percentile to ignore (def = 1).   in' 
	  print,'   u = upper percentile to ignore (def = 1).   in'
	  print,'   alo = value scaled to 0.                    out'
	  print,'   ahi = value scaled to 255.                  out'
	  print,'   out = scaled image.                         out'
	  print,' Notes: Uses cumulative histogram.'
	  return, -1
	endif
 
	IF NP LT 2 THEN L = 1
	IF NP LT 3 THEN U = L
 
	CLO = L/100.
	CHI = (100.-U)/100.
	NBINS = 600.
 
	AMN = MIN(A)				; Find array extremes.
	AMX = MAX(A)
	DA = AMX - AMN				; Array range.
	B = (A - AMN)*NBINS/DA			; Force into NBIN bins.
	H = HISTOGRAM(B)			; Histogram.
	C = CUMULATE(H)				; Look at cumulative histogram.
	C = C - C(0)				; Ignore 0s.
	C = FLOAT(C)/MAX(C)			; Normalize.
	W = WHERE((C GT CLO) AND (C LT CHI),count)	; Pick central window.
	if count gt 0 then begin
	  LO = MIN(W)				; Find limits of rescaled data.
	  HI = MAX(W)
	endif else begin
	  LO = 0
	  HI = NBINS
	  print,' LS2 Warning: could not scale array properly.'
	endelse
	ALO = AMN + DA*LO/NBINS			; Limits in original array.
	AHI = AMN + DA*HI/NBINS
	PRINT,' Scaling image from ',ALO,' to ',AHI
	B = BYTSCL(A>ALO<AHI)			; Scale array.
	RETURN, B
	END

;+
; NAME:
;       HIST
; PURPOSE:
;       Compute histogram and corresponding x values.
; CATEGORY:
; CALLING SEQUENCE:
;       h = hist(a, [x, bin])
; INPUTS:
;       a = input array.                             in 
;       bin = optional bin size (def=1).             in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         NBINS = n.  Set max allowed number of bins to n. 
;           Over-rides default max of 1000. 
; OUTPUTS:
;       x = optionally returned array of x values.   out 
;       h = resulting histogram.                     out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. Converted to SUN 11 Dec, 1989.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	FUNCTION HIST, ARR, X, BIN, help=hlp, maxbins=mxb, nbins=nb
 
	IF (N_PARAMS(0) LT 1) or keyword_set(hlp) then begin
	  print,' Compute histogram and corresponding x values.'
	  print,' h = hist(a, [x, bin])'
	  print,'   a = input array.                             in'
	  print,'   x = optionally returned array of x values.   out'
	  print,'   bin = optional bin size.                     in'
	  print,'     Def is a size to give about 30 bins.'
	  print,'     NBINS over-rides bin value and returns value used.'
	  print,'   h = resulting histogram.                     out'
	  print,' Keywords:'
	  print,'   MAXBINS = mx.  Set max allowed number of bins to mx.'
	  print,'     Over-rides default max of 1000.'
	  print,'   NBINS = n.  Set number of bins used to about n.'
	  print,'     Actual bin size is a nice number giving about n bins.'
	  print,'     Over-rides any specified bin size.'
	  return, -1
	endif
 
	if n_params(0) lt 3 then bin = nicenumber((max(arr)-min(arr))/30.)
	if keyword_set(nb) then bin = nicenumber((max(arr)-min(arr))/nb)
	mxbins = 1000				; Def max # of histogram bins.
	if keyword_set(mxb) then mxbins = mxb	; Over-ride max bins.
 
	MN = MIN(ARR, max = mx)			; Min array value.
	n = 2+ceil((mx - mn)/bin)		; Number of hiastogram bins.
	if n gt mxbins then begin
	  print,' Error in HIST: bin size too small, histogram requires '+$
	    strtrim(n,2)+' bins.'
	  print,' Def.max # of bins = 1000.  May over-ride with NBINS keyword.'
	  return, -1
	endif
 
	B2 = BIN/2.0				; Half bin.
	XMN = BIN*FLOOR((MN-B2)/BIN) + B2	; Min centered bin start.
 
	H = HISTOGRAM((ARR - XMN)/BIN)		; Do histogram.
	H = [0.,H,0.]				; Want zeros on ends.
	X = XMN-B2 + BIN*FINDGEN(N_ELEMENTS(H))	; Generate X values.
 
	RETURN, H
	END

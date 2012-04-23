;+
; NAME:
;       NRUNS
; PURPOSE:
;       Return the number of runs of consecutive integers in a given array.
; CATEGORY:
; CALLING SEQUENCE:
;       n = nruns(w)
; INPUTS:
;       w = output from where to process.          in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       n = number of runs in w.                   out 
; COMMON BLOCKS:
; NOTES:
;       Note: see getrun. 
; MODIFICATION HISTORY:
;-
 
	FUNCTION nruns, w, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin

	  print," Return the number of runs of consecutive integers"+$
	    " in a given array.'
	  print,' n = nruns(w)'
	  print,'   w = output from where to process.          in'
	  print,'   n = number of runs in w.                   out'
	  print,' Note: see getrun.'
	  return, -1
	endif
 
	d = w-SHIFT(w,1)			; Distance to next point.
	loc = WHERE(d ne 1)			; Distance ne 1 = run starts.
	loc2 = [loc,n_elements(w)]		; Where next run would start.
	len = (loc2 - shift(loc2,1))(1:*)	; Compute run lengths.
	nwds = n_elements(loc)			; Number of runs.
 
	return, nwds
 
	END

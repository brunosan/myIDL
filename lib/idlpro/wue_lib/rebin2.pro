;+
; NAME:
;       REBIN2
; PURPOSE:
;       Interpolate values between pixels.  Uses rebin but trims end effects.
; CATEGORY:
; CALLING SEQUENCE:
;       b = rebin2(a, n, [n2])
; INPUTS:
;       a = original to interpolate.                                  in 
;       n = number of values to interpolate between original values.  in 
;       n2 = number of interpolation values in Y if different then X. in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = resulting array.                                          out 
; COMMON BLOCKS:
; NOTES:
;       Notes: rebin adds extraneous values beyond last pixel.  This 
;         routine trims those values off. 
; MODIFICATION HISTORY:
;       R. Sterner,  20 Dec, 1990
;-      correct calling sequence -G. Jung, 21 Oct, 1992
 
	function rebin2, a, nx, ny, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Interpolate values between pixels.  Uses rebin but trims'+$
	    ' end effects.'
	  print,' b = rebin2(a, n, [n2])
	  print,'   a = original to interpolate.'+$
	    '                                  in'
	  print,'   n = number of values to interpolate between '+$
	    'original values.  in'
	  print,'   n2 = number of interpolation values in Y if different '+$
	    'then X. in'
	  print,'   b = resulting array.                         '+$
	    '                 out'
	  print,' Notes: rebin adds extraneous values beyond last pixel.  This'
	  print,'   routine trims those values off.'
	  return, -1
	endif
 
	if n_elements(ny) eq 0 then ny = nx
 
	sz = size(a)
	sx = sz(1)
	sy = sz(2)
 
	b = rebin(a,sx*(nx+1), sy*(ny+1))
 
	return, b(0:(sx-1)*(nx+1), 0:(sy-1)*(ny+1))
	end

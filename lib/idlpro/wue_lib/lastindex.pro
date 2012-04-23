;+
; NAME:
;       LASTINDEX
; PURPOSE:
;       Returns the last index for each dimension of the given array.
; CATEGORY:
; CALLING SEQUENCE:
;       lastindex, array, l1, l2, ... l8
; INPUTS:
;       array = given array.                          in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       l1, l2, ... = last index for each dimension.  out 
;         Max of 8 dimensions. 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 5 Jan, 1990
;	R. Sterner, 18 Mar, 1990 --- removed execute (recursion problem).
;-
 
	pro lastindex, a, l1, l2, l3, l4, l5, l6, l7, l8, help=hlp
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Returns last index for each dimension of the given array.'
	  print,' lastindex, array, l1, l2, ... l8'
	  print,'   array = given array.                          in'
	  print,'   l1, l2, ... = last index for each dimension.  out'
	  print,'     Max of 8 dimensions.'
	  return
	endif
 
	sz = size(a)
 
	n = sz(0)
 
	if n ge 1 then l1 = sz(1)
	if n ge 2 then l2 = sz(2)
	if n ge 3 then l3 = sz(3)
	if n ge 4 then l4 = sz(4)
	if n ge 5 then l5 = sz(5)
	if n ge 6 then l6 = sz(6)
	if n ge 7 then l7 = sz(7)
	if n ge 8 then l8 = sz(8)
 
	return
	end

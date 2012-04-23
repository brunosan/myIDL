FUNCTION avx_y,array,ix_from,ix_to
;+
; NAME: 
;       AVX_Y
; PURPOSE: 
;	returns vector of rows averaged over columns ix_from to ix_to 
;	of 2-dim array ("image").
;*CATEGORY:            @CAT-#  0 30@
;       Array Manipulation Routines , Smoothing
; CALLING SEQUENCE:
;       i_y = AVX_Y(array,ix_from,ix_to)
; INPUTS:
;       array   = 2-dim data array ("image").
;	ix_from = 1st column to be averaged.
;	ix_to   = last column to be averaged.
;	(ix_from <= ix_to must be valid indices of 1st dimension of array)
; OUTPUTS:
;	vector (size = size of 2nd dim of array) of array-values
;	averaged from ix_from to ix_to (1st dim of array).
; PROCEDURE:
;       arithmetic mean of array(ix_from:ix_to, j) for each j.
; MODIFICATION HISTORY:
;       nlte, 1989-07-25 
;	nlte, 1992-02-05  on_error, argument check
;-
on_error,1
if n_params() ne 3 then message,'Usage: scan = AVX_Y(array,ix_from,ix_to)'
sz=size(array)
if sz(0) ne 2 then message,'1st argument must be a 2-dim array'
if ix_from lt 0 or ix_to lt ix_from or ix_to ge sz(1) then $
   message,'invalid boundaries for averaging'
;
av=fltarr(sz(2))
fac=1./(ix_to-ix_from+1)
for j=0,sz(2)-1 do av(j)=total(array(ix_from:ix_to,j))*fac
return,av
end

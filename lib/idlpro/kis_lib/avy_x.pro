FUNCTION avy_x,array,iy_from,iy_to
;+
; NAME:
; 	AVY_X
; PURPOSE: 
;       returns vector of columns averaged over rows iy_from to iy_to 
;       of 2-dim array ("image").
;*CATEGORY:            @CAT-#  0 30@
;       Array Manipulation Routines , Smoothing
; CALLING SEQUENCE:
;       i_x = AVY_X(array,iy_from,iy_to)
; INPUTS:
;       array   = 2-dim data array ("image").
;	iy_from = 1st row to be averaged.
;	iy_to   = last row to be averaged.
;	(iy_from <= iy_to must be valid indices of 2nd dimension of array)
; OUTPUTS:
;       vector (size = size of 1st dim of array) of array-values
;       averaged from iy_from to iy_to (2nd dim of array).
; PROCEDURE:
;       arithmetic mean of array(iy_from:iy_to,i) for each i.
; MODIFICATION HISTORY:
;       nlte, 1989-07-25 
;	nlte, 1992-02-05  on_error, argument check
;-
on_error,1
if n_params() ne 3 then message,'Usage: scan = AVY_X(array,iy_from,iy_to)'
sz=size(array)
if sz(0) ne 2 then message,'1st argument must be a 2-dim array'
if iy_from lt 0 or iy_to lt iy_from or iy_to ge sz(2) then $
   message,'invalid boundaries for averaging'
;
av=fltarr(sz(1))
fac=1./(iy_to-iy_from+1)
for i=0,sz(1)-1 do av(i)=total(array(i,iy_from:iy_to))*fac
return,av
end

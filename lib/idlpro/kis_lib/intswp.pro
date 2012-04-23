FUNCTION intswp,byt_arr
;+
; NAME:
;	INTSWP
; PURPOSE:
;	returns short integer (-array) converted from byte-array 
;	with byte-swapping
;*CATEGORY:            @CAT-# 28@
;	Programming
; CALLING SEQUENCE:
;	ishort = INTSWP(byt_arr)
; INPUTS:
;	byt_arr = 1-dim byte-array, size must be a multiple of 2
; OUTPUTS:
;	short integer if byt_arr has size 2 else
;	short integer array with size = (size of byt_arr)/2
; SIDE EFFECTS:
;	error message if invalid argument
; RESTRICTIONS:
;	none
; PROCEDURE:
;	uses IDL routine BYTEORDER
; MODIFICATION HISTORY:
;	nlte, 1990-Oct-26
;-
sz=size(byt_arr)
if sz(0) ne 1 or sz(2) ne 1 then message,'byt_arr not a 1-dim byte-array'
n=sz(1)
k=n/2
if k*2 ne n then message,'size of byt_arr not a multiple of 2:'+string(n)
;

l=intarr(k)
for i=0,k-1 do l(i)=fix(byt_arr,i*2)
;
byteorder,l,/sswap
;
return,l
end

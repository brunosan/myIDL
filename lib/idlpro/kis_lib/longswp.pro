FUNCTION longswp,byt_arr
;+
; NAME:
;	LONGSWP
; PURPOSE:
;	returns long integer (-array) converted from byte-array 
;	with long-swapping
;*CATEGORY:            @CAT-# 28@
;	Programming
; CALLING SEQUENCE:
;	long = LONGSWP(byt_arr)
; INPUTS:
;	byt_arr = 1-dim byte-array, size must be a multiple of 4
; OUTPUTS:
;	long integer if byt_arr has size 4 else 
;	long integer array, size = (size of byt_arr)/4
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
k=n/4
if k*4 ne n then message,'size of byt_arr not a multiple of 4:'+string(n)
;

l=lonarr(k)
for i=0,k-1 do l(i)=long(byt_arr,i*4)
;
byteorder,l,/lswap
;
return,l
end

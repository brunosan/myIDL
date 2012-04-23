FUNCTION a_lt_b,a,b,n,last=ilast
;+
; NAME:
;	A_LT_B
; PURPOSE:
;	returns 1st index where a(k) < b(k) for more than n points
;	in sequence.
;	returns -1 if condition nowhere satisfied.
;*CATEGORY:            @CAT-#  0@
;	Array Manipulation Routines
; CALLING SEQUENCE:
;	result = A_LT_B(a,b,n)
; INPUTS:
;	a,b = Vectors to be compared
; OPTIONAL INPUT PARAMETER:
;       LAST = keyword . If set, return the LAST index where a(k) < b(k)
;	for more than n points in sequence.
; OUTPUTS:
;	result = Index i of 1st (last) element where a(i+j) < b(i+j) , 
; 		 j=0,1,..,n .
;	result = -3 if either a or b is of size <= n or n <= 0
;	result = -2 if a(k) < b(k) is nowhere satisfied
;	result = -1 if a(k) < b(k) is satisfied by only less than n
;		 elements
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;       None.
; RESTRICTIONS:
;       Size of a and b must be gt n
; PROCEDURE:
;       Straightforward.
; MODIFICATION HISTORY:
;	nlte, 1990-03-12 ( keyword last)
;---
if n lt 0 then begin
   print,'A_LT_B(A,B,N): N must be >= 0 . Actual: N=',n
   return,-3
endif
siza=size(a)
sizb=size(b)
m=min([siza(1),sizb(1)])
if m le n then begin
  print,'A_LT_B: min array size',m,' <= ',n
  return,-3
endif
;
ii=where(a lt b,count)
if count le 0 then return,-2
if count le n then return,-1
;
if keyword_set(ilast) then begin  ; search last index:
   if n eq 0 then return,ii(count-1)
   for i=count-n-1,0,-1 do begin
       if ii(i+n) eq (ii(i)+n) then return,ii(i)
   endfor
   return,-1
endif
; search 1st index:
if n eq 0 then return,ii(0)
for i=0,(count-n-1) do begin
    if ii(i+n) eq (ii(i)+n) then return,ii(i)
endfor
return,-1
end

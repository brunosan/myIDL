function banmul,a,x,m1,m2
;+
; NAME:
;	BANMUL
; PURPOSE:
;	Multiply a vector with a compact stored bandmatrix
;*CATEGORY:            @CAT-# 22@
;       Mathematical Procedures :  matrix operations
; CALLING SEQUENCE:
;	result = BANMUL( a, x, m1, m2)
; INPUTS:
;	A   : Compact stored bandmatrix, see descriptipon of routine bandec
;       X   : vector to be multiplied with A
;       M1  : Number of subdiagonals of the bandmatrix
;       M2  : Number of superdiagonals of the bandmatrix
; OUTPUTS:
; 	RESULT: Result of the multiplication
; PROCEDURE:
; 	See Press et al. Numerical Recipes - The art of scientific computing
; MODIFICATION HISTORY:
;	28-02-1993  PS
;-

on_error,2

if n_params() ne 4 then $
  message,'Usage:  result = BANMUL(a,x,m1,m2)'

sa=size(a)
if sa(0) ne 2 then message,'Must be a matrix: A'
n=sa(1)
if (m1+m2+1) ne sa(2) then message,'Check parameters: M1,M2'
sx=size(x)
if (sx(0) ne 1) or ((sx(0) eq 2) and (min(sx(1:2)) ne 1)) then $
  message,'Must be a vector:  X'
if n ne n_elements(x) then message,"Dimensions don't agree: A,X"

b=float(x)
for i=1,n do begin
  k=i-m1-1
  tmploop=min([m1+m2+1,n-k])
  b(i-1)=0.0
  for j=max([1,1-k]),tmploop do b(i-1)=b(i-1)+a(i-1,j-1)*x(j+k-1)
endfor
return,b
end

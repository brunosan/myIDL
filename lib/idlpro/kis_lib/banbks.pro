pro banbks,a,al,indx,m1,m2,b
;+
; NAME:
;	BANBKS
; PURPOSE:
;	Solve a linear equation system A*X=B with a compact stored
;       bandmatrix. 
;*CATEGORY:            @CAT-# 22@
;	Mathematical Procedures :
;          Matrix operations, solution of linear equation systems
; CALLING SEQUENCE:
;	BANBKS,a,al,indx,m1,m1,b
; INPUTS:
;	A    : Upper tridiagonal matrix of LU-decomposition (output from
;              routine BANDEC)
;       AL   : Lower tridiagonal matrix of LU-decomposition (output from
;              routine BANDEC)
;       INDX : Record of row permutations (output from routine BANDEC)
;       M1,M2: Number of sub/superdiagonals
;       B    : righthand side of equation, vector to be solved for
;                   ***  OVERWRITTEN BY BANBKS  ***
; OUTPUTS:
; 	B    : Solution vector
; SIDE EFFECTS:
; 	Input vector B is changed. If you want to keep it for later use,
;       make a copy before calling banbks.
; PROCEDURE:
; 	See Press et al. Numerical Recipes - The art of scientific computing
; MODIFICATION HISTORY:
;	28-02-1993  PS
;-

on_error,2             ;;;  Return to caller

;;;
;;;  Some error checking...
;;;
if n_params() ne 6 then $
  message,'Usage:  BANBKS,a,al,indx,m1,m2,b'
sa=size(a)
if sa(0) ne 2 then message,'1st argument (A) must be a matrix.'
n=sa(1)
if (m1+m2+1) ne sa(2) then message,'Check parameters: M1,M2'
sal=size(al)
if sal(0) ne 2 then message,'2nd argument (AL) must be a matrix.'
if sal(1) ne sa(1) then message,$
   "Dimensions of 1st & 2nd argument (A, AL) don't agree."
if sal(2) ne m1 then message,'Check parameter: M1'
sx=size(b)
if (sx(0) ne 1) or ((sx(0) eq 2) and (min(sx(1:2)) ne 1)) then $
  message,'Must be a vector:  B'
if n ne n_elements(b) then message,"Dimensions don't agree: A,B"

mm=m1+m2
l=m1-1
nm1=n-1
for k=0,nm1 do begin
  i=indx(k)
  if (i ne k) then begin
    dum=b(k)
    b(k)=b(i)
    b(i)=dum
  endif
  if (l lt nm1) then l=l+1
  for i=k+1,l do b(i)=b(i)-al(k,i-k-1)*b(k)
endfor
l=0
for i=nm1,0,-1 do begin
  dum=b(i)
  for k=1,l do dum=dum-a(i,k)*b(k+i)
  b(i)=dum/a(i,0)
  if (l lt mm) then l=l+1
endfor

end

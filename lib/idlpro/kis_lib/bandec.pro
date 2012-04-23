pro bandec,a,al,indx,m1,m2,d
;+
; NAME:
;	BANDEC
; PURPOSE:
;	Compute the LU-Decomposition of a bandmatrix
;*CATEGORY:            @CAT-# 22@
;	Mathematical Procedures :
;       Matrix operations, solution of linear equation systems
; CALLING SEQUENCE:
;	BANDEC,a,al,indx,m1,m2 [,D]
; INPUTS:
;	A   : Array (N,m1+m2+1) with the bandmatrix. Storage scheme see
;             below.  **Changed by the program**
;       m1  : number of subdiagonals of matrix A
;       m2  : number of superdiagonals of matrix A
; OUTPUTS:
; 	A   : Upper triangular matrix of the LU decomposition,dim(N,m1+m2+1
;       AL  : Lower    "         "    "   "   "    "         ,dim(N,m1)
;       indx: Vector of length n recording the row permutations from
;             pivoting.
;       d   : +- 1 depending on the number of permutations: parity
; SIDE EFFECTS:
; 	Matrix A is altered. If you want to keep it for later use, make
;       a copy before calling BANDEC.
; RESTRICTIONS:
; 	
; PROCEDURE:
; 	For a complete description see 
;          Press et al.  Numerical recipes - The art of scientific computing
;       Storage scheme for A:
;       Matrix A holds the non-zero elements of a square bandmatrix (from nowon
;       (from nowon referred as A0). 
;       The dimension of A is ( N , m1 + m2 + 1) with
;       N,m1 and m2 as defined above. The diagonal elements of A0 are
;       stored in A(*,m1), the subdiagonal Elements in A(*,0:m1-1) and
;       the superdiagonal elements in A(*,m1+1:m1+m2). Nondefined
;       Elements are set to zero, so the first rows for a bandmatrix with
;       N=10,m1=2,m2=3 will look like this:
;       
;       [ 0      , 0      , A0(0,0), A0(1,0), A0(2,0), A0(3,0) ]
;       [ 0      , A0(0,1), A0(1,1), A0(2,1), A0(3,1), A0(4,1) ]
;       [ A0(0,2), A0(1,2), A0(2,2), A0(3,2), A0(4,2), A0(5,2) ]
;       [ A0(1,3), A0(2,3), A0(3,3), A0(4,3), A0(5,3), A0(6,3) ]
;            .        .        .        .        .      .
;            .        .        .        .        .      .
;       etc.  Last line would be
;
;       [ A0(7,9), A0(8,9), A0(9,9), 0      , 0      , 0       ]
;       
; MODIFICATION HISTORY:
;	28-02-1993  PS (KIS), adapted from Numerical Recipes in C
;-

on_error,2
;;;
;;;  Some error checking...
;;;
if n_params() lt 5 then $
  message,'Usage:  BANDEC,a,al,indx,m1,m2[,d]'
sa=size(a)
if sa(0) ne 2 then message,'1st argument (A) must be a matrix.'
n=sa(1)
if (m1+m2+1) ne sa(2) then message,'Check parameters: M1,M2'

for i=0,m1-1 do a(i,*)=shift(a(i,*),i-m1)

d=1.0
l=m1-1
nm1=n-1
for k=0,nm1 do begin
  dum=a(k,0)
  i=k
  if (l lt nm1) then l=l+1
  for j=k+1,l do begin
    if abs(a(j,0)) gt abs(dum) then begin
      dum=a(j,0)
      i=j
    endif
  endfor
  indx(k)=i
  if (dum eq 0) then a(k,0)=1e-20
  if (i ne k) then begin
    d=-d
    dum=a(k,*)
    a(k,*)=a(i,*)
    a(i,*)=dum
  endif
  for i=k+1,l do begin
    dum=a(i,0)/a(k,0)
    al(k,i-k-1)=dum
    a(i,*)=[[a(i,1:*)-dum*a(k,1:*)],[0.]]
  endfor
endfor
end

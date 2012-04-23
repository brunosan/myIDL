function smoother,data,p1,p2,smoothdim=sd,double=doub,au=a,al=al, $
                  indx=indx,init=init
;+
; NAME:
;	SMOOTHER
; PURPOSE:
;	Returns a smoothed copy of the input data. 
;*CATEGORY:            @CAT-# 30  5@
;	Smoothing , Curve fitting
; CALLING SEQUENCE:
;	result = SMOOTHER( data [,p1] [,p2] [,keywords] )
; INPUTS:
;	DATA  : (1 or 2-dim) array to smooth. Shoud be
;               ***  EQUIDISTANT  ***
; OPTIONAL INPUT PARAMETER:
;       p1,p2 : smooth-parameters as described below. Default to 10
; KEYWORDS:
;       SMOOTHDIM= 1 | 2  : For 2-dim arrays, the dimension for wich the
;                    smoothing should be performed. Possible values are
;                    1 for (horizontal) x-direction and 2 for (vertical)
;                    y-direction. Default is 1 (horizontal).
;       /DOUBLE    : For 2-dim arrays: Perform a double pass smoothing,
;                    i.e. first in vertical, then in horizontal
;                    direction. Actually, it makes no difference whether
;                    smoothing is applied first in x and then in y or
;                    vice versa. Nevertheless, you can specify both the
;                    DOUBLE and SMOOTHDIM keyword. Smoothing will then
;                    be done first in the direction orthogonal to the
;                    specified one. This is, if you call with
;                    SMOOTHDIM=2 and /DOUBLE, first pass smoothing will
;                    be in horizontal, and second pass in vertical
;                    direction. 
;       /INIT      : must be set if SMOOTHER is called for the 1st time with
;                    NEW data-format, and/or new values for p1, p2, 
;		     AND the result of the LU-decomposition SHALL BE RETURNED
;		     TO THE USER. 
;                    If this is an other call to SMOOTHER with the SAME
;		     data-format and p1, p2, this key should NOT be set
;		     in order to save computing time.
;       AU=au, AL=al, INDX=indx : 
;                    Passes the upper and lower triangular matrices and
;                    the permutation vector index of the LU decomposition
;                    of the bandmatrix A to the user (output!) if keyword 
;		     INIT IS set or (if INIT NOT set) again as input to 
;                    SMOOTHER, resp. This is particularly usefull if the 
;		     user wishes to smooth different datasets of 
;		     ** SAME LENGTH ** and with the same set of parameters 
;		     P1,P2. The main computational work of this routine 
;		     lies in the LU-decomposition of the matrix that 
;		     describes the linear equation system. This matrix 
;		     depends only on the parameters P1, P2 and the length 
;		     of the dataset. Therefore one can call SMOOTHER once 
;		     with keywords AU=au,AL=al and /INIT set. For later use, 
;		     passing AL and AU with INIT NOT set will skip the 
;                    computation of the LU decomposition and will save a 
;		     lot of time.
; OUTPUTS:
; 	result : array of same dimension and type as array data with the
;                smoothed data.
; SIDE EFFECTS:
; 	Temporary diskfiles are created.
; RESTRICTIONS:
; 	
; PROCEDURE:
;       This is an IDL-implementation of a FORTRAN code written by U.
;       Grabowski (Kiepenheuer-Institut fuer Sonnenphysik, FRG). It
;       minimizes the following functional:  
;
;       SUM { (Yi-Fi)^2 + p1*[(F"i-F"i-1)^2 + (F"i-F"i+1)] + p2*(F"i)^2 }
;
;       where i (i=1...n) denotes the index of the point, Y the data
;       values F the points of the smoothed data set and F" the second
;       derivative. 
;       p1 and p2 are parameters the user is free to choose
;       according to his personal requirements. It is recommended to
;       begin with both values equal and of order 1 to 10. Larger values
;       force the routine to generate a smoother approximation.  Both
;       values zero will mainly reproduce the original data set. Setting
;       p1 larger than p2 reduces the variation of the curvature from
;       point to point, p2 greater than p1 forces the routine to find a
;       smoothed set with a small curvature.  
;       Remark: For fitting of spectral data it is recomended NOT to use
;       large values for P2.  This is because a small curvature produces
;       a bad fit of the line center of spectral lines or other features
;       with localy high (true) curvature.
;
; MODIFICATION HISTORY:
;       Dec 1992    Basic idea and FORTRAN-subroutine from U.Grabowski
;	18-02-1993  First IDL-Implementation: Calling an external
;                   Program. FORTRAN main routine by U.Grabowski,
;                   IDL-code P.Suetterlin
;       28-02-1993  Solution of the band-diagonal equation system in
;                   IDL (routines BANDEC and BANBKS from Numerical
;                   Recipes)                                  PS
;-

on_error,2

;;;  
;;;  Default values for P1, P2 and SD if not given
;;;  sd=1 means: smoothing in x-direction
;;;
if n_params() lt 3 then p2=10 
if n_params() lt 2 then p1=10
if not keyword_set(sd) then sd=1

s=size(data)
if (s(0) eq 2) then begin
  if min(s(1:2)) ne 1 then begin             ;;;  'real' 2-dim case
    if sd eq 2 then begin                    ;;;  Smooth in Y:
      sm_dat=transpose(data)                 ;;;  Transpose data, use
      tra=1                                  ;;;  same code
    endif else begin
      sm_dat=data
      tra=0
    endelse
    s=size(sm_dat)
    dim=s(2)
  endif else if s(1) eq 1 then begin         ;;;  Coloumn vector:
    sm_dat=transpose(data)                   ;;;  Transpose
    s=size(sm_dat)
    tra=1
    dim=1
  endif
endif else begin                             ;;;  data is 1-dim row-vector
  sm_dat=data
  dim=1
  tra=0
endelse


;;;
;;;  If a double pass smoothing is requested, now call smoother with
;;;  smoothdim set to 2. SM_DAT holds the (eventually transposed) data,
;;;  so smoothing will in all cases be performed in 2 different
;;;  directions, no matter if smoother was called allready with
;;;  SMOOTHDIM=2. But perform this option ONLY with real 2-dim data
;;;  
if keyword_set(doub) and dim ne 1 then $
   sm_dat=smoother(sm_dat,p1,p2,smoothdim=2)
     
;;; length of array in 1. dimension
n=s(1)
;;;
;;;  Test if a, al and indx are allready computed
;;;
if (keyword_set(a)) and (keyword_set(al)) and (keyword_set(indx)) and $
   (not keyword_set(init)) then goto, go_on


;;;
;;;  Now set up the linear equation system: Init Matrix a
;;;

a =fltarr(n,7)
al=fltarr(n,3)
indx=intarr(n)

dia0=  4.*p1+ 5.*p2+1.           ;;;  These are the non-zero elements
dia1= 38.*p1+30.*p2+1.           ;;;  of the matrix a
dia2= 56.*p1+22.*p2+1.
dia3= 42.*p1+ 7.*p2+1.
diag= 40.*p1+ 6.*p2+1.
sd11=-12.*(p1+p2)
sd12=-6.*(7.*p1+4.*p2)
sd13=-4.*(9.*p1+2.*p2)
sdg1=-30.*p1-4.*p2
sd22=3.*(4.*p1+3.*p2)
sd23=6.*(3.*p1+p2)
sdg2=12.*p1+p2
sd33=-2.*(2.*p1+p2)
sdg3=-2.*p1

;;;
;;;  Now fill the bandmatrix a in the way described in
;;;     [1] Press et al.  Numerical recipes.
;;;
a(0,*) = [0   ,0   ,0   ,dia0,sd11,sd22,sd33]
a(1,*) = [0   ,0   ,sd11,dia1,sd12,sd23,sdg3]
a(2,*) = [0   ,sd22,sd12,dia2,sd13,sdg2,sdg3]
a(3,*) = [sd33,sd23,sd13,dia3,sdg1,sdg2,sdg3]
a(n-1,*)=[sd33,sd22,sd11,dia0,0   ,0   ,0   ]
a(n-2,*)=[sdg3,sd23,sd12,dia1,sd11,0   ,0   ]
a(n-3,*)=[sdg3,sdg2,sd13,dia2,sd12,sd22,0   ]
a(n-4,*)=[sdg3,sdg2,sdg1,dia3,sd13,sd23,sd33]
for i=4,n-5 do $
  a(i,*)=[sdg3,sdg2,sdg1,diag,sdg1,sdg2,sdg3]

;;;
;;;  Now perform LU-decomposition for bandmatrix a 
;;;

bandec,a,al,indx,3,3,d

go_on:

nm1=n-1
for row=0,dim-1 do begin                    ;;;  loop through all rows
  b=float(sm_dat(*,row))
  l=2
  for k=0,nm1 do begin                      ;;;  This is an involved
    i=indx(k)                               ;;;  form of BANBKS to
    if (i ne k) then begin                  ;;;  avoid too much parameter
      dum=b(k)                              ;;;  passing.
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
    if (l lt 6) then l=l+1
  endfor
  sm_dat(*,row)=b
endfor

;;;
;;;  If the data had been transposed (either due to SMOOTHDIM setting 
;;;  or because data was a coloumn vector) now reverse the operation to
;;;  keep the data format on return.
;;;
if tra eq 1 then sm_dat=transpose(sm_dat)

return,sm_dat

end


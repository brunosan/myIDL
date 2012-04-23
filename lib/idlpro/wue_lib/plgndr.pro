FUNCTION PLGNDR,L,M,X
;+
; NAME:
;	PLGNDR
; PURPOSE:
;       Calcutate Legendre-Polynomials.
; CATEGORY:
;       Mathematics.
; CALLING SEQUENCE:
;       y = plgndr(l,m,x)
; INPUTS:
;	l,m  =  Parameters l and m : scalar intergers.
;		Both positive and (m le l).
;	x    =  Abscissa values. Float-array of any dimension and size.
;		Must be in the range [-1.,+1.]
; OUTPUTS:
;	Function result= array of the same type and dimension as x,
;		 containing evaluation of Legendre-polynomials.
; COMMON BLOCKS:
;       None.
; RESTRICTIONS:
;	l and m must be scalars.
;	l must be less than about 28 or 80 if x is single or double precision.
; PROCEDURE:
;	Adapted from FORTRAN-routine in 'Numerical Recipes' , W.H. Press et al.
;	, Cambridge University Press 1986 , page 180 .
; MODIFICATION HISTORY:
;       Written , A. Welz & B. Fleck , Univ. Wuerzburg, Germany, Dec. 1991
;-
  on_error,2
      IF (M LT 0) OR (M GT L) OR (max(ABS(X)) GT 1.) then begin
          print,'bad arguments'
          return,x
      endif
      PMM=1.
      IF M GT 0  THEN begin
        SOMX2=SQRT((1.-X)*(1.+X))
        FACT=1.
        for  I=1,M do begin
          PMM=-PMM*FACT*SOMX2
          FACT=FACT+2.
        endfor
      endif
      IF L EQ M  THEN begin
        PLGNDR=PMM
      endif ELSE begin
        PMMP1=X*(2*M+1)*PMM
        IF L EQ M+1  THEN begin
          PLGNDR=PMMP1
        endif ELSE begin
          for LL=M+2,L do begin
            PLL=(X*(2*LL-1)*PMMP1-(LL+M-1)*PMM)/(LL-M)
            PMM=PMMP1
            PMMP1=PLL
          endfor
          PLGNDR=PLL
        endelse
      endelse
      RETURN,PLGNDR
      END

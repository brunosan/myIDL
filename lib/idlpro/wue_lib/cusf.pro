;+
; NAME:
;       CUSF
; PURPOSE:
;       Cubic spline data smoother
; CATEGORY:
; CALLING SEQUENCE:
;	ynew = CUSF( xold,yold,xnew,smooth [,weights=weights] )
; INPUTS:
;                XOLD   - VECTOR OF LENGTH NX CONTAINING THE ABSCISSAE
;                           OF THE NX DATA POINTS (XOLD(I),YOLD(I)) I=0,...,
;                           NX. (INPUT) XOLD MUST BE ORDERED SO THAT
;                           XOLD(I) .LT. XOLD(I+1).
;                YOLD   - VECTOR OF LENGTH NX CONTAINING THE ORDINATES
;                           (OR FUNCTION VALUES) OF THE NX DATA POINTS.
;                           (INPUT)
;                XNEW   - VECTOR CONTAINING THE ABSCISSAE WHERE THE
;                         SPLINE IS TO BE EVALUATED.
;                SMOOTH - A NON-NEGATIVE NUMBER WHICH CONTROLS THE
;                          EXTENT OF SMOOTHING. (INPUT) THE SPLINE
;                          FUNCTION S IS DETERMINED SUCH THAT THE
;                          SUM FROM 0 TO NX-1 OF
;                          ((S(X(I))-F(I))/DF(I))**2
;                          IS LESS THAN OR EQUAL TO SM,
;                          WHERE EQUALITY HOLDS UNLESS S DESCRIBES
;                          A STRAIGHT LINE.
; KEYWORDS:
;                WEIGHTS- VECTOR OF LENGTH NX . (OPTIONAL INPUT)
;                          WHEIGHTS(I) IS THE RELATIVE WEIGHT OF DATA
;                          POINT I . IF WHEIGHTS IS NOT OF LENGTH NX,
;                          ALL WEIGHTS ARE SET TO ONE.
; OUTPUTS:
;       FUNCTION VALUE YNEW - SPLINE EVALUATED AT LOCATIONS
;                                  CONTAINED IN XNEW.
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
;             XOLD MUST BE MONOTONICALLY INCREASING.
; PROCEDURE:
;        THE PROCEDURES CUSS AND CUSP ARE CALLED TO DO THE JOB.
; MODIFICATION HISTORY:
;       WRITTEN, A. WELZ, UNIV. WUERZBURG, GERMANY, MARCH 1992
;
;-
;
function cusf, xold,yold,xnew,smooth,weights=weights
on_error,2
if n_elements(weights) eq n_elements(xold) then w=weights else w=0.

cuss, xold,yold,w,smooth,coeff,ier 

if ier lt 0 then begin
case ier of
-1:   print,'CUSS: wrong nubmer of parameters'
-2:   print,'CUSS: less than 2 abscissa values'
-3:   print,'CUSS: input abscissae are not ordered'
else: ;
endcase
   return,0
endif

cusp, xnew, ynew, xold, coeff, ier

if ier lt 0 then begin
case ier of
-1:   print,'CUSP: wrong nubmer of parameters'
-2:   print,'CUSP: less than 2 abscissa values'
-3:   print,'CUSP: input abscissae are not ordered'
else: ;
endcase
   return,0
endif

return,ynew
end

;+
; NAME:
;	CUSP
; PURPOSE:
;	Cubic spline evaluation - for use with CUSS
; CATEGORY:
; CALLING SEQUENCE:
;       cusp, in, out, x, coeff, error
; INPUTS:
;                IN     - INPUT VECTOR WITH INDEPENDENT VARIABLES
;   		 X      - VECTOR OF LENGTH NX CONTAINING THE ABSCISSAE  
;                           OF THE NX DATA POINTS (X(I),F(I)) I=0,...,  
;                           NX. (INPUT) X MUST BE ORDERED SO THAT   
;                           X(I) .LT. X(I+1). EXACTLY AS USED IN "CUSS"  
;                COEFF  - SPLINE COEFFICIENTS. (INPUT) 
;                           C IS AN NX BY 4 MATRIX. 
;                           THE VALUE OF THE SPLINE APPROXIMATION   
;                           AT T IS 
;                           S(T) = ((C(I,2)*D+C(I,1))*D+C(I,0))*D+C(I,3)  
;                           WHERE X(I) .LE. T .LT. X(I+1) AND   
;                           D = T-X(I). 
;                           C HAS TO BE EXACTLY AS OUTPUT BY "CUSS"
; OPTIONAL INPUT PARAMETERS:
; KEYWORDS:
; OUTPUTS:
;                OUT    - OUTPUT VECTOR WITH SPLINE VALUES
;                IER    - ERROR PARAMETER. (OUTPUT) 
;                           IER = -1, CALLED WITH WRONG NUMBER OF
;			      PARAMETERS
;                           IER = -2, NX IS LESS THAN 2
;                           IER = -1, INPUT ABSCISSAE ARE NOT ORDERED  
;                             SO THAT X(0) .LT. X(1) ... .LT. X(NX-1) 
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; NOTES:
;		FOR BINARY SEARCH THE PROCEDURE TABINV (ASTROLIB) IS USED.
; MODIFICATION HISTORY:
;	Written July 1991 by Reinhold Kroll
;	Vectorized June 1992 by Alexander Welz
;
;-
;
;   
PRO CUSP, IN,OUT,X,C,IER
;
;                                  CHECK ERROR CONDITIONS  
ON_ERROR,2 
    IF N_PARAMS() NE 5 THEN BEGIN
    PRINT, ' ****  WRONG NUMBER OF PARAMETERS !'
    PRINT, ' ****  CORRECT USE :   CUSP, IN,OUT,X,COEFF,ERR '
    IER=-1
    RETURN
    ENDIF
NIN=N_ELEMENTS(IN)
OUT=FLTARR(NIN)
NX=N_ELEMENTS(X)
  IF  NX LT 2  THEN BEGIN
  IER=-2
  RETURN
  ENDIF 

; Test for monotonicity of X
if min( (shift(x,-1)-x)(0:nx-2) ) le 0 then begin
  IER=-3
  RETURN
  ENDIF

; be sure that IN is within the Range of X
in= x(0) > in < x(nx-1)

TABINV,x,in,indx
indx=fix(indx)
D=in-x(indx)
OUT=( ( C(indx,2)*D + C(indx,1) )*D + C(indx,0) )*D + C(indx,3)

RETURN

END   

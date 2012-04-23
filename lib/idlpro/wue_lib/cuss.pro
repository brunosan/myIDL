;+
; NAME:
;	CUSS
; PURPOSE:
;	Cubic spline data smoother
; CATEGORY:
; CALLING SEQUENCE:
;	cuss, x,y,weights,smooth,c,ier 
; INPUTS:
;   	         X      - VECTOR OF LENGTH NX CONTAINING THE ABSCISSAE  
;                           OF THE NX DATA POINTS (X(I),F(I)) I=0,...,  
;                           NX. (INPUT) X MUST BE ORDERED SO THAT   
;                           X(I) .LT. X(I+1).   
;                Y      - VECTOR OF LENGTH NX CONTAINING THE ORDINATES  
;                           (OR FUNCTION VALUES) OF THE NX DATA POINTS. 
;                           (INPUT) 
;                WEIGHTS- VECTOR OF LENGTH NX OR DUMMY VARIABLE. (INPUT)  
;                           D(I) IS THE RELATIVE WEIGHT OF DATA
;                           POINT I (SEE PARAMETER SM BELOW).   
;			    IF D IS NOT OF LENGTH NX, ALL WEIGHTS
;  			    ARE SET TO ONE
;                SMOOTH- A NON-NEGATIVE NUMBER WHICH CONTROLS THE  
;                           EXTENT OF SMOOTHING. (INPUT) THE SPLINE 
;                           FUNCTION S IS DETERMINED SUCH THAT THE  
;                           SUM FROM 0 TO NX-1 OF 
;                           ((S(X(I))-F(I))/DF(I))**2   
;                           IS LESS THAN OR EQUAL TO SM,
;                           WHERE EQUALITY HOLDS UNLESS S DESCRIBES 
;                           A STRAIGHT LINE.
; OPTIONAL INPUT PARAMETERS:
; KEYWORDS:
; OUTPUTS:
;                C      - SPLINE COEFFICIENTS. 
;                           C IS AN NX BY 4 MATRIX. 
;                           THE VALUE OF THE SPLINE APPROXIMATION   
;                           AT T IS 
;                           S(T) = ((C(I,2)*D+C(I,1))*D+C(I,0))*D+C(I,4)  
;                           WHERE X(I) .LE. T .LT. X(I+1) AND   
;                           D = T-X(I). 
;                IER    - ERROR PARAMETER. (OUTPUT) 
;                           IER = -1, CALLED WITH WRONG NUMBER OF
;			      PARAMETERS
;                           IER = -2, NX IS LESS THAN 2
;                           IER = -3, INPUT ABSCISSAE ARE NOT ORDERED  
;                             SO THAT X(0) .LT. X(1) ... .LT. X(NX-1) 
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; NOTES:
;  	     1.  THE ROUTINE PRODUCES A NATURAL CUBIC SPLINE. HENCE,
;                THE SECOND DERIVATIVE OF THE SPLINE FUNCTION S AT  
;                X(0) AND X(NX-1) IS ZERO.
;            2.  FOR EACH SET OF DATA POINTS THERE EXISTS A MAXIMUM 
;                VALUE FOR THE SMOOTHING PARAMETER. LET US CALL THIS
;                                *  
;                MAXIMUM VALUE SM . IT IS DEFINED BY THE FOLLOWING  
;                FORMULA;   
;                    *  
;                  SM  = THE SUM FROM I EQUAL 0 TO NX-1 OF
;                                           2   
;                        ((Y(I)-F(I))/DF(I))
;                WHERE Y IS THE SET OF FUNCTION VALUES DEFINING THE 
;                STRAIGHT LINE WHICH BEST APPROXIMATES THE DATA IN  
;                THE LEAST SQUARES SENSE (WITH WEIGHTS DF). 
;            3.  USE "CUSP" TO EVALUATE SPLINE VALUES !!!
;   
;
; MODIFICATION HISTORY:
;       Adapted to IDL 1991 from an IMSL source by GentleGiantSoft
;
;-
;   
;   
PRO CUSS, X,F,D,SM,C,IER
;
ON_ERROR,2
    IF N_PARAMS() NE 6 THEN BEGIN
    PRINT, ' ****  WRONG NUMBER OF PARAMETERS !'
    PRINT, ' ****  CORRECT USE :   CUSS, X,Y,WEIGHTS,SMOOTH,COEFF,IER  '
    IER=-1
    RETURN 
    ENDIF
NX=N_ELEMENTS(X)
ND=N_ELEMENTS(D)
DF=FLTARR(NX)
IF ND EQ NX THEN DF=D
IF ND NE NX THEN DF=DF+1.
C=FLTARR(NX,4)
WK=FLTARR(7,NX+2)
TWOD3=.666666667 
ONED3=.333333333  
ZERO=0.0
ONE=1.0 
IER=0
;                                  CHECK ERROR CONDITIONS   
  IF  NX LT 2  THEN BEGIN
  IER=-2
  RETURN
  ENDIF


P = ZERO  
H = X(1)-X(0) 
  IF  H LE ZERO THEN BEGIN
  IER=-3 
  RETURN 
  ENDIF

F2 = -SM  
FF = (F(1)-F(0))/H
  IF  NX LT 3  THEN GOTO, L30   

	 FOR I=2,NX-1  DO BEGIN 
         G = H  
         H = X(I)-X(I-1)
           IF  H LE ZERO THEN BEGIN
           IER=-3
	   RETURN
	   ENDIF
         ONEDH = ONE/H  
         E = FF 
         FF = (F(I)-F(I-1))*ONEDH   
         C(I,3) = FF-E
         WK(3,I) = (G+H)*TWOD3  
         WK(4,I) = H*ONED3  
         WK(2,I) = DF(I-2)/G
         WK(0,I) = DF(I)*ONEDH  
         WK(1,I) = -DF(I-1)/G-DF(I-1)*ONEDH 
	 ENDFOR  

     	 FOR I=2,NX-1  DO BEGIN
         C(I-1,0) = WK(0,I)*WK(0,I)+WK(1,I)*WK(1,I)+WK(2,I)*WK(2,I) 
         C(I-1,1) = WK(0,I)*WK(1,I+1)+WK(1,I)*WK(2,I+1) 
         C(I-1,2) = WK(0,I)*WK(2,I+2)   
	 ENDFOR 
;                                  NEXT ITERATION   
L15:  IF  NX LT 3 THEN GOTO, L30   

	 FOR I=2,NX-1 DO BEGIN 
         WK(1,I-1) = FF*WK(0,I-1)   
         WK(2,I-2) = G*WK(0,I-2)
         WK(0,I) = ONE/(P*C(I-1,0)+WK(3,I)-FF*WK(1,I-1)-G*WK(2,I-2))
         WK(5,I) = C(I,3)-WK(1,I-1)*WK(5,I-1)-WK(2,I-2)*WK(5,I-2) 
         FF = P*C(I-1,1)+WK(4,I)-H*WK(1,I-1)
         G = H  
         H = C(I-1,2)*P 
	 ENDFOR 

NP3 = NX+3

	 FOR I=3,NX DO BEGIN 
         J = NP3-I-1  
         WK(5,J) = WK(0,J)*WK(5,J)-WK(1,J)*WK(5,J+1)-WK(2,J)*WK(5,J+2)  
	 ENDFOR

L30:  E = ZERO  
      H = ZERO  
;                                  COMPUTE U AND ACCUMULATE E   
	 FOR I=1,NX-1 DO BEGIN 
         G = H  
         H = (WK(5,I+1)-WK(5,I))/(X(I)-X(I-1))  
         HMG = H-G  
         WK(6,I) = HMG*DF(I-1)*DF(I-1)  
         E = E+WK(6,I)*HMG  
	 ENDFOR 

G = -H*DF(NX-1)*DF(NX-1)  
WK(6,NX) = G 
E = E-G*H 
G = F2
F2 = E*P*P
IF (F2 GE SM) OR (F2 LE G) THEN GOTO, L50   
FF = ZERO 
H = (WK(6,2)-WK(6,1))/(X(1)-X(0)) 
IF  NX LT 3 THEN  GOTO, L45   


	 FOR I=2,NX-1 DO BEGIN 
         G = H  
         H = (WK(6,I+1)-WK(6,I))/(X(I)-X(I-1))  
         G = H-G-WK(1,I-1)*WK(0,I-1)-WK(2,I-2)*WK(0,I-2)
         FF = FF+G*WK(0,I)*G
         WK(0,I) = G
	 ENDFOR

L45:  H = E-P*FF
      IF  H LE ZERO THEN GOTO, L50 
;                                  UPDATE THE LAGRANGE MULTIPLIER P 
;                                     FOR THE NEXT ITERATION
P = P+(SM-F2)/((SQRT(SM/E)+P)*H)  
GOTO, L15  
;                                  IF E LESS THAN OR EQUAL TO S,
;                                  COMPUTE THE COEFFICIENTS AND RETURN. 
L50:   NP1 = NX-1

	 FOR I=0,NP1-1 DO BEGIN
         C(I,3) = F(I)-P*WK(6,I+1)
         C(I,1) = WK(5,I+1) 
         WK(0,I) = C(I,3) 
	 ENDFOR

WK(0,NX-1) = F(NX-1)-P*WK(6,NX) 
C(NX-1,3) = WK(0,NX-1)  

	 FOR I=1,NX-1  DO BEGIN
         H = X(I)-X(I-1)
         C(I-1,2) = (WK(5,I+1)-C(I-1,1))/(H+H+H)
         C(I-1,0) = (WK(0,I)-C(I-1,3))/H-(H*C(I-1,2)+C(I-1,1))*H  
	 ENDFOR

RETURN

END   

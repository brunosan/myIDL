; $Id: gaussfit.pro,v 1.1 1993/04/02 19:43:31 idl Exp $

PRO	FIT_2GAUSS_F,X,A,F,PDER
;
; NAME:
;	FIT_2GAUSS_FUNCT
;
; PURPOSE:
;	EVALUATE THE SUM OF A GAUSSIAN AND A 2ND ORDER POLYNOMIAL
;	AND OPTIONALLY RETURN THE VALUE OF IT'S PARTIAL DERIVATIVES.
;	NORMALLY, THIS FUNCTION IS USED BY CURVEFIT TO FIT THE
;	SUM OF A LINE AND A VARYING BACKGROUND TO ACTUAL DATA.
;
; CATEGORY:
;	E2 - CURVE AND SURFACE FITTING.
; CALLING SEQUENCE:
;	FUNCT,X,A,F,PDER
; INPUTS:
;	X = VALUES OF INDEPENDENT VARIABLE.
;	A = PARAMETERS OF EQUATION DESCRIBED BELOW.
; OUTPUTS:
;	F = VALUE OF FUNCTION AT EACH X(I).
;
; OPTIONAL OUTPUT PARAMETERS:
;	PDER = (N_ELEMENTS(X),6) ARRAY CONTAINING THE
;		PARTIAL DERIVATIVES.  P(I,J) = DERIVATIVE
;		AT ITH POINT W/RESPECT TO JTH PARAMETER.
; COMMON BLOCKS:
;	NONE.
; SIDE EFFECTS:
;	NONE.
; RESTRICTIONS:
;	NONE.
; PROCEDURE:
;	F = A(0)*EXP(-Z^2/2) + A(3) + A(4)*X + A(5)*X^2
;	Z = (X-A(1))/A(2)
; MODIFICATION HISTORY:
;	WRITTEN, DMS, RSI, SEPT, 1982.
;	Modified, DMS, Oct 1990.  Avoids divide by 0 if A(2) is 0.
;	Added to Gauss_fit, when the variable function name to
;		Curve_fit was implemented.  DMS, Nov, 1990.
;
	ON_ERROR,2                        ;Return to caller if an error occurs
	if a(5) ne 0.0 then Z1 = (X-A(4))/A(5) $	;GET Z
	else z1= 10.
	EZ1 = EXP(-Z1^2/2.)*(ABS(Z1) LE 7.) ;GAUSSIAN PART IGNORE SMALL TERMS
	if a(8) ne 0.0 then Z2 = (X-A(7))/A(8) $	;GET Z
	else z2 = 10.
	EZ2 = EXP(-Z2^2/2.)*(ABS(Z2) LE 7.) ;GAUSSIAN PART IGNORE SMALL TERMS
	F = A(0)+A(1)*X+A(2)*X^2+A(3)*EZ1 + A(6)*EZ2 ;FUNCTIONS.
	IF N_PARAMS(0) LE 3 THEN RETURN ;NEED PARTIAL?
;
	PDER = FLTARR(N_ELEMENTS(X),9) ;YES, MAKE ARRAY.
        PDER(0,0) = 1.
      	PDER(0,1) = X
      	PDER(0,2) = X*X
	PDER(0,3) = EZ1
	IF A(5) NE 0.0 THEN PDER(0,4) = A(3)*EZ1*Z1/A(5) 
	PDER(0,5) = PDER(*,4)*Z1
	PDER(0,6) = EZ2
	IF A(8) NE 0.0 THEN PDER(0,7) = A(6)*EZ2*Z2/A(8) 
	PDER(0,8) = PDER(*,7)*Z2

	RETURN
END



Function FIT_2GAUSS, x, y, a
;+
; NAME:
;	FIT_2GAUSS
;
; PURPOSE:
; 	Fit the curve to two y=f(x) where:
;
; 		F(x) = A0 + A1*X + A2*X^2 + A3*EXP(-z1^2/2) + A6*EXP(-z2^2/2) 
; 			where
;			z1=(x-A4)/A5
;			z2=(x-A7)/A8
;
; CATEGORY:
;	?? - fitting
;
; CALLING SEQUENCE:
;	Result = GAUSSFIT(X, Y [, A])
;
; INPUTS:
;	X:	The independent variable.  X must be a vector.
;	Y:	The dependent variable.  Y must have the same number of points
;		as X.
;
; OUTPUTS:
;	The fitted function is returned.
;
; OPTIONAL OUTPUT PARAMETERS:
;	A:	The coefficients of the fit.  A is a six-element vector as 
;		described under PURPOSE.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	The peak or minimum of the Gaussian must be the largest
;	or smallest point in the Y vector.
;
; PROCEDURE:
;	If the (MAX-AVG) of Y is larger than (AVG-MIN) then it is assumed
;	that the line is an emission line, otherwise it is assumed there
;	is an absorbtion line.  The estimated center is the MAX or MIN
;	element.  The height is (MAX-AVG) or (AVG-MIN) respectively.
;	The width is found by searching out from the extrema until
;	a point is found less than the 1/e value.
;
; MODIFICATION HISTORY:
;	DMS, RSI, Dec, 1983.
;	CHANGE TO TWO COMPONENTS, Z. YI, 1993
;-
;
on_error,2                      ;Return to caller if an error occurs
n = n_elements(y)		;# of points.
c = poly_fit(x,y,1,yf)		;fit a straight line.
yd= y-yf

plot,x,y,charsize=.0000001
PRINT,'USING CURSOR TO GET THE 1ST ELEMENT'
CURSOR,X0,Y0,/DATA
wait,.2
PRINT,'USING CURSOR TO GET THE 2ND ELEMENT'
CURSOR,X1,Y1,/DATA

ymax=max(yd) & xmax=x(!c) & imax=!c	;x,y and subscript of extrema
ymin=min(yd) & xmin=x(!c) & imin=!c

if (y0+y1)/2 gt avg(y) then begin 	;emiss or absorp?
  i0=imax & a0=min(y)
endif else begin
  i0=imin & a0=max(y)
endelse 
i0 = i0 > 1 < (n-2)		;never take edges
dy=yd(i0)			;diff between extreme and mean
del = dy/exp(1.)		;1/e value
i=0
while ((i0+i+1) lt n) and $	;guess at 1/2 width.
	((i0-i) gt 0) and $
	(abs(yd(i0+i)) gt abs(del)) and $
	(abs(yd(i0-i)) gt abs(del)) do i=i+1

W=abs(x(i0)-x(i0+i))

a = [a0,C(1),0,y0,x0,W,y1,X1,W ] ;estimates
!c=0				;reset cursor for plotting

return,curvefit(x,y,replicate(1.,n),a,sigmaa, $
		function_name = "FIT_2GAUSS_F") ;call curvefit
end

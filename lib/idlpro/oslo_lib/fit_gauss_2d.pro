PRO	FIT_GAUSS2D_F,A,F,PDER
; NAME:
;	GAUSS_FUNCT
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
;	GAUSS_FUNCT_2D,X,A,F,PDER
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
; 		F(x,y) = A0+A1*x+A2*y+A3*x^2+A4*y^2+A5*xy+A6*z
; 			and
;		z=( (x-A7)^2 + (y-A8)^2 )/A9^2
; MODIFICATION HISTORY:
;	WRITTEN, DMS, RSI, SEPT, 1982.
;	Modified, DMS, Oct 1990.  Avoids divide by 0 if A(2) is 0.
;	Added to Gauss_fit, when the variable function name to
;		Curve_fit was implemented.  DMS, Nov, 1990.
;	Changed to 2D, Z. Yi, April, 1993
;
	COMMON XY,X,Y
	ON_ERROR,2                        ;Return to caller if an error occurs

	if A(9) ne 0.0 then ZZ = sqrt( (X-A(7))^2+(Y-A(8))^2 ) /A(9) $	;GET Z
	else ZZ= 10.
	EZ = EXP(-ZZ^2)*(abs(zz) le 7.) ;GAUSSIAN PART IGNORE SMALL TERMS
	F = A(0) +A(1)*X + A(2)*Y +A(3)*X*X +A(4)*Y*Y+ A(5)*X*Y + A(6)*EZ
			;FUNCTIONS.

	IF N_PARAMS(0) LE 2 THEN RETURN ;NEED PARTIAL?
;
	s=size(zz)

	PDER = FLTARR(n_elements(zz),10) ;YES, MAKE ARRAY.54

	PDER(0:*,6) = EZ		;COMPUTE PARTIALS
	if A(9) ne 0. then PDER(0:*,7) = 2 * A(6) * EZ * (X-A(7))/A(9)^2
	if A(9) ne 0. then PDER(0:*,8) = 2 * A(6) * EZ * (Y-A(8))/A(9)^2
	PDER(0:*,9) = 2*A(6)*EZ*ZZ^2/A(9)
	PDER(0:*,0) = 1.
	PDER(0:*,1) = 1.*X
	PDER(0:*,2) = 1.*Y
	PDER(0:*,3) = 1.*X*X
	PDER(0:*,4) = 1.*Y*Y
	PDER(0:*,5) = 1.*X*Y
	RETURN
END



Function FIT_GAUSS_2D, z, a
;+
; NAME:
;	FIT_GAUSS_2D
;
; PURPOSE:
; 	Fit the array to y=f(x,y) where:
;
; 		F(x,y) = A0+A1*x+A2*y+A3*x^2+A4*y^2+A5*xy+A6*z
; 			where
;		z=( (x-A7)^2 + (y-A8)^2 )/A9^2
;
;	A6 = height of exp, A7,A8 = center of exp, A9 = sigma (the width).
;	A0 = constant term, A1,A2 = linear term in X and Y, and
;	A3,A4,A5 = quadratic term in X and Y . 
;
; CATEGORY:
;	?? - fitting
;
; CALLING SEQUENCE:
;	Result = GAUSSFIT(Z [, A])
;
; INPUTS:
;	Z:	2D array
;
; OUTPUTS:
;	The fitted function is returned.
;
; OPTIONAL OUTPUT PARAMETERS:
;	A:	The coefficients of the fit.  A is a 10-element vector as 
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
;	CHANGE TO 2D, Z. YI, 1993
;-
;
COMMON XY,X,Y
on_error,2                      ;Return to caller if an error occurs

s = size(z)		;# of points.
X=LINDGEN(S(1),S(2))
Y=X/S(1)	&	X=X MOD S(1)

p=intarr(2,s(4))

p(0,0:*)=x & p(1,0:*)=y
w=replicate(1.,s(4))
c=regress(p,reform(z,s(4)),w,dum,m)
p=0 & w=0 & dum=0

zmax=max(z-m) & xmax=x(!c) & imax=!c	;x,y and subscript of extrema
zmin=min(z-m) & xmin=x(!c) & imin=!c

if abs(zmax) gt abs(zmin) then i0=imax else i0=imin ;emiss or absorp?
iy=i0/s(1) > 1 < (s(2)-2)	&	ix=(i0 mod s(1)) >1 < (s(1)-2)

dz=z(ix,iy)-m			;diff between extreme and mean
del = dz*exp(-1.)+m		;1/e value
i=0

dd=z(*,iy)			;estimate sigma

if i0 eq imax then d=where(dd ge del,n) else d=where(dd le del,n)
d=d > 1 < (s(1)-2)

l=d(0)+(del-dd(d(0))) / (dd(d(0))-dd( (d(0)-1) ))
r=d(n-1)+ (del-dd( d(n-1) ))/( dd( (d(n-1)+1) ) - dd(d(n-1)) )
w=(r-l)/2

a = [m,c(0),c(1),0,0,0,z(ix,iy), x(ix,iy), y(ix,iy), w] ;estimates
!c=0				;reset cursor for plotting
print,a
return,curvefit_2(z,replicate(1.,N_ELEMENTS(Z)),a,sigmaa, $
		function_name = "FIT_GAUSS2D_F") ;call curvefit

end












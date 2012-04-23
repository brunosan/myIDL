FUNCTION poly_extr,coef,x1,x2,xextr,indicator
;+
; NAME:
; 	POLY_EXTR
; PURPOSE:
;  	returns value of polynom and position of 
;	(local) maximum or minimum if found within specified intervall.
;*CATEGORY:            @CAT-# 22@
;  	Mathematical Routines (no Functions)
; CALLING SEQUENCE:
;	y = POLY_EXTR(coef,x1,x2,xextr [,indicator])
; INPUTS:
; 	coef    : 1-dim vector containing the coefficients of polynom:
;		  p_n(x) = coef(0) + coef(1)*x + coef(2)*x^2 + ...
;       x1,x2   : x-intervall ( x1 < x2 ) to be searched for extremum;
;		  if polynom is of degree > 2, the Newton-iteration will
;		  start at 0.5*(x1+x2) and will be stopped if an iteration
;		  is outside this intervall (ignored if degree = 2, but must
;		  be provides formally in any case).
; OUTPUTS:
; 	function-value: the value of polynom at x = xextr
; 	xextr   : x-value where 1st derivative of polynom is zero (as 
;		  found by Newton-iteration). If no root of 1st derivative
;		  was found within x-intervall [x1,x2], xextr will be set
;		  < x1 .
; OPTIONAL OUTPUT PARAMETERS:
;	indicator : if an extremum was found, indicator = +1 if this is a
;		    maximum, = -1 if this is a minimum; =0 if no extremum
;		    was found. Argument must be a variable!
; COMMON BLOCKS:
;	 none
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
; 	computes coefficients of 1st derivative;
;	analytic computation of xextr, yextr if 1st deriv. is linear;
;	Newton-iteration to find a root of 1st derivative within specified
;	x-intervall using KIS_LIB procedure POLY_ROOT.
;	If POLY_EXTR was called with 5 arguments, the 2nd derivative will
;	be computed at x=xextr and checked for it's sign.
; MODIFICATION HISTORY:
;	1991-Nov-18  H.S., KIS
;-
;
on_error,2
npar=n_params()
if npar lt 4 then message,'usage: y=POLY_EXTR(coefs,x1,x2 [,indicator])
deg=n_elements(coef)-1
if deg lt 2 then message,'at least 3 polynomial coefficientas must be provided'
;
cd1=fltarr(deg)
cd1=(1.+findgen(deg))*coef(1:deg)
if deg eq 2 then begin
   xextr= -cd1(0)/cd1(1)
   if cd1(1) lt 0 then indicator=1 else indicator=-1
   goto,jmpret
endif
;
indicator=npar
if deg eq 3 then begin
   a=-0.5*cd1(1)/cd1(2) & aa=a*a & b=cd1(0)/cd1(2)
   if aa lt b then begin 
      xextr=x1-0.1*max([1.,abs(x1)]) & indicator=0
      goto,jmpret
   endif
   if 0.5*(x1+x2) gt a then xextr=a+sqrt(aa-b) else xextr=a-sqrt(aa-b)
endif else begin
   xextr=poly_root(cd1,x1,x2)
   if xextr lt x1 then indicator=0
endelse
;
if indicator eq 5 then begin
   degm1=deg-1 & cd2=fltarr(degm1)
   cd2=(1.+findgen(degm1))*cd1(1:degm1)
   yd2=poly(xextr,cd2)
   if yd2 lt 0 then indicator=1 else indicator=-1
endif
;
jmpret: 
yextr=poly(xextr,coef)
return,yextr
;
end

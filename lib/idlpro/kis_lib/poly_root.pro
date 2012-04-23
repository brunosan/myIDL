FUNCTION poly_root,coef,x1,x2,maxiter=mxiter,crit=epsx
;+
; NAME:
;	POLY_ROOT
; PURPOSE:
;	root of a polynom within a specified intervall
;*CATEGORY:            @CAT-# 22@
;       Mathematical Routines (no Functions)
; CALLING SEQUENCE:
;       x= POLY_ROOT(coef,x1,x2)
; INPUTS:
;       coef = vector of polynom coef(0) + coef(1)*x + coef(2)*x^2 + ...
;	x1, x2 = x-intervall to be searched for root ( x1 < x2 );
;		 Newton-iteration will start at x=(x1+x2)/2 and will
;		 be stopped if an iteration is outside this intervall
;		 (ignored if deg=1).
; OPTIONAL INPUTS:
;	MAXITER=mxiter : Newton-iteration will terminate unsuccessfull
;		         after mxiter iterations (default : mxiter=20).
;	CRIT=epsx :  Newton-iteration will terminate "successfull" if
;		     x-value changes less than (x2-x1)*epsx between two
;		     iterations (default: epsx = 1.E-5).
; OUTPUTS:
;       approximate root if found inside [x1,x2] else a value < x1
;       
; PROCEDURE:
;       straight forward if deg=1, else Newton iteration, terminated
;	if difference between 2 iterations is < (x2-x1)*epsx, or
;	if an iterated x is outside [x1,x2], or after mxiter steps.
; MODIFICATION HISTORY:
;       nlte, 1990-03-28 
;	nlte, 1991-11-18 modified iterat.-crit., keywords MAXITER, CRIT   
;-
;
on_error,2
if n_params() ne 3 then message,$
   'usage: xzero=POLY_ROOT(coefs,xlow,xupp [,MAXITER=mxiter] [CRIT=epsx])'
;
deg=n_elements(coef)-1
;
if deg lt 1 then message,'degree'+string(deg)+' must be >0'
;
if deg eq 1 then return,-coef(0)/coef(1)
;
if x1 ge x2 then message,'lower x-boundary must be < upper boundary'
if not keyword_set(mxiter) then mxiter=20
if not keyword_set(epsx) then epsx=1.e-5
;
dxmax=(x2-x1)*epsx
x=0.5*(x1+x2)
cdev=(1.+findgen(deg))*coef(1:deg)
for i=1,mxiter do begin
 dx=poly(x,coef)/poly(x,cdev)
 x=x-dx
 if abs(dx) lt dxmax then goto,jmp2
 if (x lt x1) or (x gt x2) then goto,jmp1
endfor
;print,'exceeding iterations'
;
jmp1: x=x1-0.1*max([1.,abs(x1)])
;print,'out of range'
;
jmp2: return,x
end

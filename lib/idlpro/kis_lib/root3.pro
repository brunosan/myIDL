function root3,coef,x1,x2
;+
; NAME:
;	ROOT3
; PURPOSE:
;	root of cube within interval [x1,x2]
;*CATEGORY:            @CAT-# 22@
;	Mathematical Routines (no Functions)
; CALLING SEQUENCE:
;	x0 = ROOT3 (coef,x1,x2)
; INPUTS:
;	coef  : 1-dim vectore of size 4 containing the coefficients
;	        of the cube :
;               coef(0) +coef(1)*x +coef(2)*x^2 +coef(3)*x^3
;	x1,x2 : boundaries where root shall be searched (x1 < x2).
; OUTPUTS:
;	x0 = root (if found; else: x-value of final iteration step).
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	Warning message if root not found within intervall
; RESTRICTIONS:
;	Iteration will be stopped after 20 steps.
; PROCEDURE:
;	Newton-iteration
; MODIFICATION HISTORY:
;	nlte, 1990-03-17 
;-

mxiter=20
dxmax=0.1
x=0.5*(x1+x2)
for i=1,mxiter do begin
 p=((coef(3)*x+coef(2))*x+coef(1))*x+coef(0)
 pp=(3.*coef(3)*x+2.*coef(2))*x+coef(1)
 dx=p/pp
 x=x-dx
 if abs(dx) lt dxmax then goto,jmp2
 if (x lt x1) or (x gt x2) then goto,jmp1
endfor
print,'exceeding iterations'
goto,jmp2
jmp1: print,'out of range'
jmp2: return,x
end

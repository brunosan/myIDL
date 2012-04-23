function nphotons,lambda,temp,dtel,ssol,tint,dlambda
; lambda en A
; temp en K
; dtel en cm
; ssol en arcsec cuadrados
; tint en segundos
; dlambda en mA
int=planckc(lambda,temp)

cte=!pi/180./3600.
cte=!pi*cte*cte/4.
h=6.62618e-27
c=2.9979e10
energia=h*c/lambda/1.e-8

;nphot=cte*int*dtel*dtel*ssol*tint*dlambda*1.e-3/energia
nphot=cte*int*dtel*dtel*ssol*tint*dlambda*1.e-3
return,nphot
end

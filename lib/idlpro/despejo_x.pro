function despejo_x,x,tau

;derivada de la matriz de Mueller de un espejo (normalizada!!) con respecto a x.

t=fltarr(4,4)

t(0,0)=2.*x
t(1,0)=2.*x
t(0,1)=t(1,0)
t(1,1)=t(0,0)
t(2,2)=2.*cos(tau*!pi/180.)
t(3,2)=-2.*sin(tau*!pi/180.)
t(2,3)=-t(3,2)
t(3,3)=t(2,2)
return,t/2.

;x2=x^2.+1.
;x2m=x^2.-1.

;t(0,1)=4.*x/(x2*x2)
;t(1,0)=t(0,1)
;t(2,2)=-2.*x2m*cos(tau*!pi/180.)/x2
;t(3,3)=t(2,2)
;t(3,2)=-2.*x2m*sin(tau*!pi/180.)/x2
;t(2,3)=-t(3,2)


;return,t
end

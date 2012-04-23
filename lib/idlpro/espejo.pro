function espejo,x,tau
; Calcula la matriz de Mueller (normalizada!!) de un espejo con 
; cociente de amplitud x y  
; desfase tau. Las derivadas con respecto a x y tau se calculan en 
; despejo_x.pro y despejo_tau.pro
; Seguimos a Capitani et al, 1989, Sol. Phys., 120, 173.

t=fltarr(4,4)

t(0,0)=x^2.+1.
t(1,0)=x^2.-1.
t(0,1)=t(1,0)
t(1,1)=t(0.0)
t(2,2)=2.*x*cos(tau*!pi/180.)
t(3,2)=-2.*x*sin(tau*!pi/180.)
t(2,3)=-t(3,2)
t(3,3)=t(2,2)
t=t/2.

return,t
;return,t/t(0,0)
end

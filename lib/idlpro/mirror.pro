function mirror,n,k,ang,rho,delta

; ENTRADAS:
; N (indice de refraccion = n + i*k
; ang = angulo de incidencia (en grados)

; SALIDAS:
; m = matriz de Mueller
; rho = factor que determina la polarizacion lineal
; delta = defase (en grados)

;rad=ang*!pi/180.
;m=fltarr(4,4)
;p=n*n-k*k-sin(rad)*sin(rad)
;q=2*n*k
;sqrpq=sqrt(p*p+q*q)
;rplus=sqrt(p+sqrpq)/sqrt(2.)
;rminus=sqrt(-p+sqrpq)/sqrt(2.)
;s=sin(rad)*tan(rad)
;
;rho2=(sqrpq+s*s-2*s*rplus)/(sqrpq+s*s+2*s*rplus)
;rho=sqrt(rho2)
;tdelta=2*s*rminus/(sqrpq-s*s)
;delta=atan(tdelta)
;
;m(0,0)= (1+rho2)/2.
;m(0,1)= (1-rho2)/2.
;m(0,2)= 0.
;m(0,3)= 0.

;m(1,0)= (1-rho2)/2.
;m(1,1)= (1+rho2)/2.
;m(1,2)= 0.
;m(1,3)= 0.

;m(2,0)= 0.
;m(2,1)= 0.
;m(2,2)= -rho*cos(delta)
;m(2,3)= -rho*sin(delta)

;m(3,0)= 0.
;m(3,1)= 0.
;m(3,2)= rho*sin(delta)
;m(3,3)= -rho*cos(delta)

;delta=delta*180/!pi

; Calculamos el cociente de amplitud y el desfase de un espejo de
; indice de refraccion n+ik cuando el angulo de incidencia es i=angulo.
; Seguimos a Capitani et al, 1989, Sol. Phys., 120, 173.

;ENTRADAS
; indice de refraccion del espejo: n + i k
; ang:  Angulo de incidencia

;SALIDA
; m: Matriz de Mueller del espejo

rad=ang*!pi/180.

p=n^2.-k^2.-sin(rad)^2.
q=4.*n^2.*k^2.

f2=1./2.*(p+sqrt(p^2.+q))
g2=1./2.*(-p+sqrt(p^2.+q))

r=2.*sqrt(f2)*sin(rad)*tan(rad)
s=sin(rad)^2.*tan(rad)^2.

x2=(f2+g2-r+s)/(f2+g2+r+s)
x=sqrt(x2)

tantau=2.*sqrt(g2)*sin(rad)*tan(rad)/(s-f2-g2)

tau=atan(tantau)*180./!pi
if (tau le 0.) then tau=tau+180.

delta=tau ; por compatiblidad con la rutina anterior
rho=x

m=fltarr(4,4)

m(0,0)=x^2.+1.
m(1,0)=x^2.-1.
m(0,1)=m(1,0)
m(1,1)=m(0.0)
m(2,2)=2.*x*cos(tau*!pi/180.)
m(3,2)=-2.*x*sin(tau*!pi/180.)
m(2,3)=-m(3,2)
m(3,3)=m(2,2)
m=m/2.

return,m
end


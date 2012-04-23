pro xtauespejo,n,k,angulo,x,tau
; Calculamos el cociente de amplitud y el desfase de un espejo de
; indice de refraccion n+ik cuando el angulo de incidencia es i=angulo.
; Seguimos a Capitani et al, 1989, Sol. Phys., 120, 173x.

;ENTRADAS
; indice de refraccion del espejo: n + i k
; angulo:  Angulo de incidencia

;SALIDA
; x: Cociente de amplitudes paralela y perpendicular
; tau: desfase

ang=angulo*!pi/180.


p=n^2.-k^2.-sin(ang)^2.
q=4.*n^2.*k^2.

f2=1./2.*(p+sqrt(p^2.+q))
g2=1./2.*(-p+sqrt(p^2.+q))

r=2.*sqrt(f2)*sin(ang)*tan(ang)
s=sin(ang)^2.*tan(ang)^2.

x2=(f2+g2-r+s)/(f2+g2+r+s)
x=sqrt(x2)

tantau=2.*sqrt(g2)*sin(ang)*tan(ang)/(s-f2-g2)

tau=atan(tantau)*180./!pi
if (tau le 0.) then tau=tau+180.
return
end




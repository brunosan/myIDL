function mirror2,n,k,ang,doverl,nu,costau

s=sin(ang*!pi/180)
c=cos(ang*!pi/180)

b=n*n-k*k-s*s
h=2*n*k
u=sqrt(( b+sqrt(b*b+h*h))/2.)
v=sqrt((-b+sqrt(b*b+h*h))/2.)

nk=complex(n,k)
i=complex(0,1)
iv=i*v
uv=u+iv

rpar =(nk*nk*c-uv)/(nk*nk*c+uv)
rperp=(c-uv)/(c+uv)

ca=sqrt(1-s*s/nu/nu)

spar =(nu*uv-nk*nk*ca)/(nu*uv+nk*nk*ca)
sperp=(uv-nu*ca)/(uv+nu*ca)

expt=4*!pi*i*doverl*uv
r_expt=float(expt)>(-80)
expt=complex(r_expt,imaginary(expt))
t=exp(expt)

R_par = (rpar  + spar *t)/(1+rpar *spar *t)
R_perp= (rperp + sperp*t)/(1+rperp*sperp*t)

x=abs(R_par)/abs(R_perp)
sintau=-imaginary(R_par*conj(R_perp))
costau=float(R_par*conj(R_perp))
tau=atan(sintau,costau)		;*180./!pi

;stop
return,[[x],[tau]]
end

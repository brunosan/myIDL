function xtau2nk2,x_in,tau_in,ang


n_start=1.
k_start=1.
doverl_start=1./50.
nu_start=2.1

s=sin(ang*!pi/180)
c=cos(ang*!pi/180)

sol=[n_start,k_start,doverl_start,nu_start]
free=[1     ,    1 ,     1,    0]
zfree=where(free eq 1)

i=complex(0,1)
eps=1.

maxiter=100
iter=0
while(eps gt 1.e-6 and iter lt maxiter) do begin

   iter=iter+1
   b=sol(0)*sol(0)-sol(1)*sol(1)-s*s
   dbdn=2*sol(0)
   dbdk=-2*sol(1)

   h=2*sol(0)*sol(1)
   dhdn=2*sol(1)
   dhdk=2*sol(0)

   u2=( b+sqrt(b*b+h*h))/2.
   du2dn=(dbdn+(b*dbdn+h*dhdn)/sqrt(b*b+h*h))/2.
   du2dk=(dbdk+(b*dbdk+h*dhdk)/sqrt(b*b+h*h))/2.

   u=sqrt(u2)
   dudn=du2dn/2./u
   dudk=du2dk/2./u

   v2=(-b+sqrt(b*b+h*h))/2.
   dv2dn=(-dbdn+(b*dbdn+h*dhdn)/sqrt(b*b+h*h))/2.
   dv2dk=(-dbdk+(b*dbdk+h*dhdk)/sqrt(b*b+h*h))/2.

   v=sqrt(v2)
   dvdn=dv2dn/2./v
   dvdk=dv2dk/2./v

   nk=complex(sol(0),sol(1))
   dnkdn=1.
   dnkdk=i

   iv=i*v
   divdn=i*dvdn
   divdk=i*dvdk

   uv=u+iv
   duvdn=dudn+divdn
   duvdk=dudk+divdk

   rpar =(nk*nk*c-uv)/(nk*nk*c+uv)
   drpardn=(2*nk*dnkdn*c-duvdn)*(nk*nk*c+uv)-(nk*nk*c-uv)*(2*nk*dnkdn*c+duvdn)
   drpardn=drpardn/(nk*nk*c+uv)/(nk*nk*c+uv)
   drpardk=(2*nk*dnkdk*c-duvdk)*(nk*nk*c+uv)-(nk*nk*c-uv)*(2*nk*dnkdk*c+duvdk)
   drpardk=drpardk/(nk*nk*c+uv)/(nk*nk*c+uv)

   rperp=(c-uv)/(c+uv)
   drperpdn=-duvdn*(c+uv)-(c-uv)*duvdn
   drperpdn=drperpdn/(c+uv)/(c+uv)
   drperpdk=-duvdk*(c+uv)-(c-uv)*duvdk
   drperpdk=drperpdk/(c+uv)/(c+uv)

   ca=sqrt(1-s*s/sol(3)/sol(3))
   dcadnu=2*s*s/sol(3)/sol(3)/sol(3)/2./ca

   spar =(sol(3)*uv-nk*nk*ca)/(sol(3)*uv+nk*nk*ca)
   dspardn=(sol(3)*duvdn-2*nk*dnkdn*ca)*(sol(3)*uv+nk*nk*ca)- $
            (sol(3)*uv-nk*nk*ca)*(sol(3)*duvdn+2*nk*dnkdn*ca)
   dspardn=dspardn/(sol(3)*uv+nk*nk*ca)/(sol(3)*uv+nk*nk*ca)
   dspardk=(sol(3)*duvdk-2*nk*dnkdk*ca)*(sol(3)*uv+nk*nk*ca)- $
            (sol(3)*uv-nk*nk*ca)*(sol(3)*duvdk+2*nk*dnkdk*ca)
   dspardk=dspardk/(sol(3)*uv+nk*nk*ca)/(sol(3)*uv+nk*nk*ca)
   dspardnu=(uv-nk*nk*dcadnu)*(sol(3)*uv+nk*nk*ca)-(sol(3)*uv-nk*nk*ca)*(uv+nk*nk*dcadnu)
   dspardnu=dspardnu/(sol(3)*uv+nk*nk*ca)/(sol(3)*uv+nk*nk*ca)

   sperp=(uv-sol(3)*ca)/(uv+sol(3)*ca)
   dsperpdn=duvdn*(uv+sol(3)*ca)-(uv-sol(3)*ca)*duvdn
   dsperpdn=dsperpdn/(uv+sol(3)*ca)/(uv+sol(3)*ca)
   dsperpdk=duvdk*(uv+sol(3)*ca)-(uv-sol(3)*ca)*duvdk
   dsperpdk=dsperpdk/(uv+sol(3)*ca)/(uv+sol(3)*ca)
   dsperpdnu=(-ca-sol(3)*dcadnu)*(uv+sol(3)*ca)-(uv-sol(3)*ca)*(ca+sol(3)*dcadnu)
   dsperpdnu=dsperpdnu/(uv+sol(3)*ca)/(uv+sol(3)*ca)

   expt=4*!pi*i*sol(2)*uv
   r_expt=float(expt)>(-80)
   expt=complex(r_expt,imaginary(expt))
   t=exp(expt)
   dtdn=4*!pi*i*sol(2)*(duvdn)*t
   dtdk=4*!pi*i*sol(2)*(duvdk)*t
   dtddoverl=4*!pi*i*uv*t

   R_par = (rpar  + spar *t)/(1+rpar *spar *t)
   dR_pardn=(drpardn+dspardn*t+spar*dtdn)*(1+rpar *spar *t) - $
            (rpar  + spar *t)*(drpardn*spar*t+rpar*dspardn*t+rpar*spar*dtdn)
   dR_pardn=dR_pardn/(1+rpar *spar *t)/(1+rpar *spar *t)
   dR_pardk=(drpardk+dspardk*t+spar*dtdk)*(1+rpar *spar *t) - $
            (rpar  + spar *t)*(drpardk*spar*t+rpar*dspardk*t+rpar*spar*dtdk)
   dR_pardk=dR_pardk/(1+rpar *spar *t)/(1+rpar *spar *t)
   dR_parddoverl=spar*dtddoverl*(1+rpar *spar *t) - $
            (rpar  + spar *t)*rpar*spar*dtddoverl
   dR_parddoverl=dR_parddoverl/(1+rpar *spar *t)/(1+rpar *spar *t)
   dR_pardnu=dspardnu*t*(1+rpar *spar *t) - $
            (rpar  + spar *t)*rpar*dspardnu*t
   dR_pardnu=dR_pardnu/(1+rpar *spar *t)/(1+rpar *spar *t)


   R_perp= (rperp + sperp*t)/(1+rperp*sperp*t)
   dR_perpdn=(drperpdn+dsperpdn*t+sperp*dtdn)*(1+rperp *sperp *t) - $
            (rperp  + sperp *t)*(drperpdn*sperp*t+rperp*dsperpdn*t+rperp*sperp*dtdn)
   dR_perpdn=dR_perpdn/(1+rperp *sperp *t)/(1+rperp *sperp *t)
   dR_perpdk=(drperpdk+dsperpdk*t+sperp*dtdk)*(1+rperp *sperp *t) - $
            (rperp  + sperp *t)*(drperpdk*sperp*t+rperp*dsperpdk*t+rperp*sperp*dtdk)
   dR_perpdk=dR_perpdk/(1+rperp *sperp *t)/(1+rperp *sperp *t)
   dR_perpddoverl=sperp*dtddoverl*(1+rperp *sperp *t) - $
            (rperp  + sperp *t)*rperp*sperp*dtddoverl
   dR_perpddoverl=dR_perpddoverl/(1+rperp *sperp *t)/(1+rperp *sperp *t)
   dR_perpdnu=dsperpdnu*t*(1+rperp *sperp *t) - $
            (rperp  + sperp *t)*rperp*dsperpdnu*t
   dR_perpdnu=dR_perpdnu/(1+rperp *sperp *t)/(1+rperp *sperp *t)

   absR_par=sqrt(float(R_par)*float(R_par)+imaginary(R_par)*imaginary(R_par))
   dabsR_pardn=2*float(R_par)*float(dR_pardn)+2*imaginary(R_par)*imaginary(dR_pardn)
   dabsR_pardn=dabsR_pardn/2./absR_par
   dabsR_pardk=2*float(R_par)*float(dR_pardk)+2*imaginary(R_par)*imaginary(dR_pardk)
   dabsR_pardk=dabsR_pardk/2./absR_par
   dabsR_parddoverl=2*float(R_par)*float(dR_parddoverl)+ $
                    2*imaginary(R_par)*imaginary(dR_parddoverl)
   dabsR_parddoverl=dabsR_parddoverl/2./absR_par
   dabsR_pardnu=2*float(R_par)*float(dR_pardnu)+2*imaginary(R_par)*imaginary(dR_pardnu)
   dabsR_pardnu=dabsR_pardnu/2./absR_par

   absR_perp=sqrt(float(R_perp)*float(R_perp)+imaginary(R_perp)*imaginary(R_perp))
   dabsR_perpdn=2*float(R_perp)*float(dR_perpdn)+2*imaginary(R_perp)*imaginary(dR_perpdn)
   dabsR_perpdn=dabsR_perpdn/2./absR_perp
   dabsR_perpdk=2*float(R_perp)*float(dR_perpdk)+2*imaginary(R_perp)*imaginary(dR_perpdk)
   dabsR_perpdk=dabsR_perpdk/2./absR_perp
   dabsR_perpddoverl=2*float(R_perp)*float(dR_perpddoverl)+ $
                    2*imaginary(R_perp)*imaginary(dR_perpddoverl)
   dabsR_perpddoverl=dabsR_perpddoverl/2./absR_perp
   dabsR_perpdnu=2*float(R_perp)*float(dR_perpdnu)+2*imaginary(R_perp)*imaginary(dR_perpdnu)
   dabsR_perpdnu=dabsR_perpdnu/2./absR_perp

   x=absR_par/absR_perp
   dxdn=dabsR_pardn*absR_perp-absR_par*dabsR_perpdn
   dxdn=dxdn/absR_perp/absR_perp
   dxdk=dabsR_pardk*absR_perp-absR_par*dabsR_perpdk
   dxdk=dxdk/absR_perp/absR_perp
   dxddoverl=dabsR_parddoverl*absR_perp-absR_par*dabsR_perpddoverl
   dxddoverl=dxddoverl/absR_perp/absR_perp
   dxdnu=dabsR_pardnu*absR_perp-absR_par*dabsR_perpdnu
   dxdnu=dxdnu/absR_perp/absR_perp

   sintau=-imaginary(R_par*conj(R_perp))
   dsintaudn=-imaginary(dR_pardn*conj(R_perp)+R_par*conj(dR_perpdn))
   dsintaudk=-imaginary(dR_pardk*conj(R_perp)+R_par*conj(dR_perpdk))
   dsintauddoverl=-imaginary(dR_parddoverl*conj(R_perp)+R_par*conj(dR_perpddoverl))
   dsintaudnu=-imaginary(dR_pardnu*conj(R_perp)+R_par*conj(dR_perpdnu))

   costau=float(R_par*conj(R_perp))
   dcostaudn=float(dR_pardn*conj(R_perp)+R_par*conj(dR_perpdn))
   dcostaudk=float(dR_pardk*conj(R_perp)+R_par*conj(dR_perpdk))
   dcostauddoverl=float(dR_parddoverl*conj(R_perp)+R_par*conj(dR_perpddoverl))
   dcostaudnu=float(dR_pardnu*conj(R_perp)+R_par*conj(dR_perpdnu))

   tau=atan(sintau,costau)	;*180./!pi
   dtaudn=(dsintaudn*costau-sintau*dcostaudn)/(sintau*sintau+costau*costau)		;*180./!pi
   dtaudk=(dsintaudk*costau-sintau*dcostaudk)/(sintau*sintau+costau*costau)		;*180./!pi
   dtauddoverl=(dsintauddoverl*costau-sintau*dcostauddoverl)/(sintau*sintau+costau*costau)	;*180./!pi
   dtaudnu=(dsintaudnu*costau-sintau*dcostaudnu)/(sintau*sintau+costau*costau)	;*180./!pi

   xx=[[dxdn,dtaudn],[dxdk,dtaudk],[dxddoverl,dtauddoverl],[dxdnu,dtaudnu]]
   res=[x_in-x,tau_in-tau]
;   stop

   coef=lstsvd(xx(*,zfree),res)
;   stop
   sol(zfree)=sol(zfree)+coef(*,0)
   eps=max(abs(coef(*,0)))
;   print,eps
;   stop
endwhile

print,transpose(xx)
print,' '
print,iter,',',eps
print,' '
return,sol
end

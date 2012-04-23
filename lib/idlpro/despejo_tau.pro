function despejo_tau,x,tau

t=fltarr(4,4)

t(2,2)=-2.*x*!pi/180.*sin(tau*!pi/180.)
t(3,2)=-2.*x*!pi/180.*cos(tau*!pi/180.)
t(2,3)=-t(3,2)
t(3,3)=t(2,2)

return,t/2.

;t(2,2)=-2.*x*!pi/180.*sin(tau*!pi/180.)/(x^2.+1.)
;t(3,2)=2.*x*!pi/180.*cos(tau*!pi/180.)/(x^2.+1.)
;t(2,3)=-t(3,2)
;t(3,3)=t(2,2)
;
;return,t

end

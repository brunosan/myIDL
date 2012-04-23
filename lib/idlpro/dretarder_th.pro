function dretarder_th,theta,delta

fac=!pi/180.
ang=theta*fac
ret=delta*fac

m=fltarr(4,4)

c2=cos(2*ang)
s2=sin(2*ang)

cd=cos(ret)
sd=sin(ret)

m(0,0)=0.
m(0,1)=0.
m(0,2)=0.
m(0,3)=0.

m(1,0)=0.
m(1,1)=4*s2*c2*(cd-1)
m(1,2)=2*(c2*c2-s2*s2)*(1-cd)
m(1,3)=-2*c2*sd

m(2,0)=0.
m(2,1)=2*(c2*c2-s2*s2)*(1-cd)
m(2,2)=4*s2*c2*(1-cd)
m(2,3)=-2*s2*sd

m(3,0)=0.
m(3,1)=2*c2*sd
m(3,2)=2*s2*sd
m(3,3)=0

return,m*fac
end

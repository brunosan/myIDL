function retarder,theta,delta

ang=theta*!pi/180.
ret=delta*!pi/180.

m=fltarr(4,4)

c2=cos(2*ang)
s2=sin(2*ang)

cd=cos(ret)
sd=sin(ret)

m(0,0)=1.
m(0,1)=0.
m(0,2)=0.
m(0,3)=0.

m(1,0)=0.
m(1,1)=c2*c2+s2*s2*cd
m(1,2)=s2*c2*(1-cd)
m(1,3)=-s2*sd

m(2,0)=0.
m(2,1)=s2*c2*(1-cd)
m(2,2)=s2*s2+c2*c2*cd
m(2,3)=c2*sd

m(3,0)=0.
m(3,1)=s2*sd
m(3,2)=-c2*sd
m(3,3)=cd

return,m
end

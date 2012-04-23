function rotacion,theta

ang=theta*!pi/180.

m=fltarr(4,4)

c2=cos(2*ang)
s2=sin(2*ang)

m(0,0)=1.
m(3,3)=1.

m(1,1)=c2
m(1,2)=s2

m(2,1)=-s2
m(2,2)=c2

return,m
end

function drotacion,theta

ang=theta*!pi/180.

m=fltarr(4,4)

c2=cos(2*ang)
s2=sin(2*ang)

m(1,1)=-2*s2
m(1,2)=2*c2

m(2,1)=-2*c2
m(2,2)=-2*s2

return,m*!pi/180.
end

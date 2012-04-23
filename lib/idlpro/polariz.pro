function polariz,theta

ang=theta*!pi/180.

m=fltarr(4,4)

cp=cos(2*ang)
sp=sin(2*ang)


m(0,0)=1.
m(1,0)=cp
m(2,0)=sp
m(3,0)=0.

m(*,1)=cp*m(*,0)
m(*,2)=sp*m(*,0)


return,m
end

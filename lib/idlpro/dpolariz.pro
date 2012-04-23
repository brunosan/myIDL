function dpolariz,theta

fac=!pi/180.
ang=theta*fac

m=fltarr(4,4)

cp=cos(2*ang)
sp=sin(2*ang)


m(1,0)=-2*sp
m(2,0)=2*cp

m(0,1)=m(1,0)
m(1,1)=-4*sp*cp
m(2,1)=2*(cp*cp-sp*sp)

m(0,2)=m(2,0)
m(1,2)=m(2,1)
m(2,2)=4*sp*cp

return,m*fac
end

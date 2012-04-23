function impolariz2,q,theta

ret=0.
m=fltarr(4,4)

m(0,0)=1.+q*q
m(1,0)=1.-q*q
m(0,1)=m(1,0)
m(1,1)=m(0,0)

m(2,2)=2.*q*cos(ret)
m(3,3)=m(2,2)
m(2,3)=2.*q*sin(ret)
m(3,2)=-m(2,3)

m=rotacion(-theta)#m#rotacion(theta)/m(0,0)

return,m
end

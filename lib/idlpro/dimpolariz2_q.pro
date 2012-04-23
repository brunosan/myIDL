function dimpolariz2_q,q,theta

m=impolariz2(q,0)
m=m*(1+q*q)
m0=1+q*q

ret=0.
dm=fltarr(4,4)

dm0=2*q
dm(0,0)=2*q
dm(1,0)=-2*q
dm(0,1)=dm(1,0)
dm(1,1)=dm(0,0)

dm(2,2)=2.*cos(ret)
dm(3,3)=dm(2,2)
dm(2,3)=2.*sin(ret)
dm(3,2)=-dm(2,3)

dm=(dm*m0-m*dm0)/m0/m0
dm=rotacion(-theta)#dm#rotacion(theta)

return,dm
end

function dimpolariz_del,q,delta

ret=delta*!pi/180.
m=fltarr(4,4)


m(2,2)=-2.*q*sin(ret)*!pi/180.
m(3,3)=m(2,2)
m(2,3)=2.*q*cos(ret)*!pi/180.
m(3,2)=-m(2,3)

return,m/2.
end

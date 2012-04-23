pro funcion,x,a,f,pder
f=(a(2)+a(0)*x)/(1+a(1)*x*x)
pder=fltarr(n_elements(x),n_elements(a))
pder(*,0) = x/(1+a(1)*x*x)
pder(*,1)=-f*x*x/(1+a(1)*x*x)
pder(*,2)=1./(1+a(1)*x*x)
end


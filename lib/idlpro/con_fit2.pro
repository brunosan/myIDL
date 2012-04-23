function con_fit2,esp,ngrad,x

n=n_elements(esp)
z=findgen(n)

coef=poly_fit(z(x),esp(x),ngrad,yfit)
cont=poly(z,coef)

;plot,z,esp
;oplot,z,cont,line=2

return,cont
end   

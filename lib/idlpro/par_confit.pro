function par_confit,esp,ngrad,cont

n=n_elements(esp)
z=findgen(n)

x=z
esp2=esp

zgood=where(esp2  gt mean(esp2))
esp2=esp2(zgood)
x=x(zgood)
coef=poly_fit(x,esp2,ngrad,yfit)
cont=poly(z,coef)

nsig=1.5

zbad=where(esp2 lt yfit-nsig*std(esp2-yfit))

while(zbad(0) ne -1) do begin

   zgood=where(esp2  gt yfit-nsig*std(esp2-yfit))
   esp2=esp2(zgood)
   x=x(zgood)
   coef=poly_fit(x,esp2,ngrad,yfit)
   zbad=where(esp2 lt yfit-nsig*std(esp2-yfit))
   cont=poly(z,coef)

endwhile

;plot,z,esp
;oplot,z,cont,line=2

return,x
end   

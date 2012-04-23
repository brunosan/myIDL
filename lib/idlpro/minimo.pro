function minimo,dat,pos,cota,posmin
corte=dat(pos(0):pos(1))
min1=float(where(corte eq min(corte)))
min1=min1(0)
lim=min([corte(min1)+cota,.975])
z=where(corte lt lim)
if(z(0) eq  -1) then z=min1
while(n_elements(z) lt 5) do begin
   z=[z(0)-1,z,z(n_elements(z)-1)+1]
endwhile   
z1=min(z)
z2=max(z)
x=findgen(z2-z1+1)
coef=poly_fit(x,corte(z1:z2),4,yfit)
c=[coef(1),coef(2)*2,coef(3)*3,coef(4)*4]
posmin=poly_root(c,0,z2-z1)
;posmin=-coef(1)/2./coef(2)+z1+pos(0)
imin=poly(posmin,coef)
;loadct,2
xdib=findgen(pos(1)-pos(0)+1)
;plot,x,corte(z1:z2),/ynoz
;plot,xdib,corte,/ynoz
;oplot,x+z1,yfit,color=80
;oplot,[posmin,posmin]+z1,[0,1],lin=3,color=30
;oplot,[x(0),x(n_elements(x)-1)]+z1,[imin,imin],lin=3,color=30
;pause
;stop
return,imin
end

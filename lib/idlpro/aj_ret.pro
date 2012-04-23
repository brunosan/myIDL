function aj_ret,obs

loadct,2
th=findgen(19)*10

q=0.
cte=2*max(obs)

th0=90.
delta=135.

old=[cte,delta,th0]
sold=fltarr(3)

err=1
isin=fltarr(19)
disin=fltarr(19,3)
uno=[1,0,0,0]
tuno=transpose(uno)
while(err gt 1.e-3) do begin
   for j=0,18 do begin
      disin(j,0)=tuno#impolariz(q,0.)#retarder(th(j)-th0,delta)#impolariz(q,0.)#uno
      
      isin(j)=cte*disin(j,0)         
      disin(j,1)=tuno#impolariz(q,0.)#dretarder_del(th(j)-th0,delta)#impolariz(q,0.)#uno
      disin(j,1)=cte*disin(j,1)         
      
      disin(j,2)=-tuno#impolariz(q,0.)#dretarder_th(th(j)-th0,delta)#impolariz(q,0.)#uno
   endfor
   
   res=obs-isin
   coef=lstsqfit(disin,res,yfit)
   
   old=old+coef(*,0)/2.
   sold=coef(*,1)
   
   cte=old(0)
   delta=old(1)
   th0=old(2)
   
   err=max(abs(coef(*,0)/old))
   
   plot,obs,/ynoz
   oplot,isin,color=80
   
   print,old
   print,sold

endwhile

return,[old,sold,std(obs-isin)]
end      

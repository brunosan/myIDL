function lstsqfit,x,y,yfit

d=transpose(x)#x

if(n_elements(d) eq 1) then begin
   coef=total(x*y)/total(x*x)
   yfit=coef*x
   ndat=n_elements(y)
   cov=total((yfit-y)*(yfit-y))/ndat
   coef=[coef,sqrt(cov/total(x*x))]
   return,coef
endif else if(determ(d) ne 0) then begin
   d=invert(d)
   tam=size(d)
   npar=tam(1)
   ndat=n_elements(y)
   sig=fltarr(npar)
   for j=0,npar-1 do sig(j)=d(j,j)
   coef=d#transpose(x)#y
   yfit=x#coef
   cov=total((yfit-y)*(yfit-y)/(ndat-npar+1))
   coef=[[coef],[sqrt(sig*cov)]]
endif else begin
   print,'sistema incompatible'
   coef=0
   yfit=0
endelse

return,coef
end


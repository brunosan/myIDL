function lstsvd,x,y,yfit,tol=tol
if(keyword_set(tol) eq 0) then tol=1.e-6
tam=size(reform(x))
yfit=0
if(tam(0) eq 1) then begin
   coef=total(x*y)/total(x*x)
   yfit=coef*x
   cov=total((yfit-y)*(yfit-y))/(tam(1)-1)
   coef=[coef,sqrt(cov/total(x*x))]
  return,coef
endif else if(tam(0) eq 2) then begin
   ncoef=tam(2)
   mat=fltarr(ncoef,ncoef)
   vec=fltarr(ncoef)
   for i=0,ncoef-1 do begin
      for j=0,ncoef-1 do begin
         mat(i,j)=total(x(*,i)*x(*,j))
      endfor
      vec(i)=total(y*x(*,i))
   endfor
   coef=fltarr(ncoef,2)
   svdc,mat,w,u,v

   z=where(abs(w/max(abs(w))) lt tol) 
   if(z(0) ne -1) then w(z)=0.

   coef(*,0)=svsol(u,w,v,vec)
   invmat=fltarr(ncoef,ncoef)
   for j=0,ncoef-1 do begin
      ss=fltarr(ncoef)
      ss(j)=1.
      invmat(j,*)=svsol(u,w,v,ss)
   endfor
   yfit=x#coef(*,0)
   cov=total((yfit-y)*(yfit-y)/(tam(1)-tam(2)+1))
   for j=0,ncoef-1 do coef(j,1)=sqrt(cov*invmat(j,j))
   return,coef
endif else begin
   print,'este caso no deberia darse'
   return,0
endelse

end

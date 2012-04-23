function lstsqfit2,x,y,sigmay,yfit
tam=size(reform(x))
yfit=0
if(tam(0) eq 1) then begin
   coef=total(x*y/sigmay/sigmay)/total(x*x/sigmay/sigmay)
   yfit=coef*x
   cov=total((yfit-y)*(yfit-y)/sigmay/sigmay)/(tam(1)-1)
   coef=[coef,sqrt(cov/total(x*x)/sigmay/sigmay)]
   return,coef
endif else if(tam(0) eq 2) then begin
   ncoef=tam(2)
   mat=fltarr(ncoef,ncoef)
   vec=fltarr(ncoef)
   for i=0,ncoef-1 do begin
      for j=0,ncoef-1 do begin
         mat(i,j)=total(x(*,i)*x(*,j)/sigmay/sigmay)
      endfor
      vec(i)=total(y*x(*,i)/sigmay/sigmay)
   endfor
   invmat=invert(mat)
   coef=fltarr(ncoef,2)
   coef(*,0)=invmat#vec
   yfit=x#coef(*,0)
   cov=total((yfit-y)*(yfit-y)/sigmay/sigmay/(tam(1)-tam(2)+1))
   for j=0,ncoef-1 do coef(j,1)=sqrt(cov*invmat(j,j))
   return,coef
endif else begin
   print,'este caso no deberia darse'
   return,0
endelse

end
